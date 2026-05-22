#!/usr/bin/env pwsh

BeforeAll {
	. "$PSScriptRoot/../../lib/asset.ps1"
	$env:VAULT_GITHUB_TOKEN = "mock-token"
}

Describe "Get-Os" {
	It "Should return 'windows' for Windows" {
		Get-Os "Windows" | Should -Be "windows"
	}

	It "Should return 'linux' for Linux" {
		Get-Os "Linux" | Should -Be "linux"
	}

	It "Should return 'darwin' for Darwin" {
		Get-Os "Darwin" | Should -Be "darwin"
	}

	It "Should return 'linux' for Linux with extra text" {
		Get-Os "Linux-5.4" | Should -Be "linux"
	}

	It "Should detect Windows via env:OS Windows_NT when no argument is given" {
		$oldOs = $env:OS
		try {
			$env:OS = "Windows_NT"
			Get-Os | Should -Be "windows"
		} finally {
			$env:OS = $oldOs
		}
	}

	It "Should throw for unsupported OS" {
		{ Get-Os "FreeBSD" } | Should -Throw "*Unsupported OS*"
	}
}

Describe "Get-Arch" {
	It "Should return 'amd64' for x86_64" {
		Get-Arch "x86_64" | Should -Be "amd64"
	}

	It "Should return 'amd64' for X64" {
		Get-Arch "X64" | Should -Be "amd64"
	}

	It "Should return 'arm64' for arm64" {
		Get-Arch "arm64" | Should -Be "arm64"
	}

	It "Should return 'arm64' for aarch64" {
		Get-Arch "aarch64" | Should -Be "arm64"
	}

	It "Should throw for unsupported architecture" {
		{ Get-Arch "i386" } | Should -Throw "*Unsupported architecture*"
	}
}

Describe "Get-AssetName" {
	It "Should return correct asset name for Windows AMD64" {
		Get-AssetName "7.3.0" "Windows" "x86_64" | Should -Be "oblt-cli_7.3.0_windows_amd64.tar.gz"
	}

	It "Should return correct asset name for Linux AMD64" {
		Get-AssetName "7.3.0" "Linux" "x86_64" | Should -Be "oblt-cli_7.3.0_linux_amd64.tar.gz"
	}

	It "Should return correct asset name for Darwin ARM64" {
		Get-AssetName "7.3.0" "Darwin" "arm64" | Should -Be "oblt-cli_7.3.0_darwin_arm64.tar.gz"
	}

	It "Should throw for unsupported OS" {
		{ Get-AssetName "7.3.0" "FreeBSD" "x86_64" } | Should -Throw "*Unsupported OS*"
	}

	It "Should throw for unsupported architecture" {
		{ Get-AssetName "7.3.0" "Linux" "i386" } | Should -Throw "*Unsupported architecture*"
	}
}

Describe "Get-AssetId" {
	It "Should return asset id" {
		Mock Enable-Tls12 {}
		Mock Invoke-RestMethod {
			Get-Content "$PSScriptRoot/../../tests/fixtures/release.json" -Raw | ConvertFrom-Json
		}

		# On Linux, auto-detected OS is linux/amd64 → id 176068054
		Get-AssetId "7.3.0" | Should -Be 176068054
		Assert-MockCalled Enable-Tls12 -Times 1 -Exactly
	}

	It "Should return Windows asset id when OS is Windows" {
		Mock Enable-Tls12 {}
		Mock Invoke-RestMethod {
			Get-Content "$PSScriptRoot/../../tests/fixtures/release.json" -Raw | ConvertFrom-Json
		}
		Mock Get-Os { return "windows" }
		Mock Get-Arch { return "amd64" }

		Get-AssetId "7.3.0" | Should -Be 176068057
		Assert-MockCalled Enable-Tls12 -Times 1 -Exactly
	}
}

Describe "Invoke-DownloadAsset" {
	It "Should download and extract asset" {
		$tmpDir = New-Item -ItemType Directory -Path (Join-Path ([System.IO.Path]::GetTempPath()) "oblt-cli-test-$([System.Guid]::NewGuid().ToString())")
		$fixtureDir = "$PSScriptRoot/../../tests/fixtures"
		$script:tarFile = Join-Path ([System.IO.Path]::GetTempPath()) "oblt-cli-test-$([System.Guid]::NewGuid().ToString()).tar.gz"
		& tar -czf $script:tarFile -C $fixtureDir "oblt-cli"

		Mock Invoke-WebRequest {
			param($Uri, $Headers, $OutFile)
			Copy-Item $script:tarFile $OutFile
		}
		Mock Enable-Tls12 {}

		$output = Invoke-DownloadAsset "176068054" $tmpDir.FullName

		Test-Path (Join-Path $tmpDir.FullName "oblt-cli") | Should -BeTrue
		$output | Should -Contain "Downloading oblt-cli asset URL: https://api.github.com/repos/elastic/observability-test-environments/releases/assets/176068054"
		Assert-MockCalled Enable-Tls12 -Times 1 -Exactly
		Assert-MockCalled Invoke-WebRequest -Times 1 -Exactly -ParameterFilter { $Uri -eq "https://api.github.com/repos/elastic/observability-test-environments/releases/assets/176068054" }

		Remove-Item $tmpDir -Recurse -Force
		Remove-Item $script:tarFile -Force
	}

	It "Should use --force-local when tar supports it" {
		$tmpDir = New-Item -ItemType Directory -Path (Join-Path ([System.IO.Path]::GetTempPath()) "oblt-cli-test-$([System.Guid]::NewGuid().ToString())")
		Mock Invoke-WebRequest { param($Uri, $Headers, $OutFile) Set-Content -Path $OutFile -Value "mock" }
		Mock Enable-Tls12 {}
		Mock Test-TarSupportsForceLocal { $true }
		Mock tar {}

		Invoke-DownloadAsset "176068054" $tmpDir.FullName

		Assert-MockCalled tar -Times 1 -Exactly -ParameterFilter { $args[0] -eq "--force-local" }
		Remove-Item $tmpDir -Recurse -Force
	}

	It "Should not use --force-local when tar does not support it" {
		$tmpDir = New-Item -ItemType Directory -Path (Join-Path ([System.IO.Path]::GetTempPath()) "oblt-cli-test-$([System.Guid]::NewGuid().ToString())")
		Mock Invoke-WebRequest { param($Uri, $Headers, $OutFile) Set-Content -Path $OutFile -Value "mock" }
		Mock Enable-Tls12 {}
		Mock Test-TarSupportsForceLocal { $false }
		Mock tar {}

		Invoke-DownloadAsset "176068054" $tmpDir.FullName

		Assert-MockCalled tar -Times 1 -Exactly -ParameterFilter { $args[0] -eq "-xzf" }
		Remove-Item $tmpDir -Recurse -Force
	}
}
