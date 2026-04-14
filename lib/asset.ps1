#!/usr/bin/env pwsh

# Get the OS name
# Arguments:
#   $System: The system name (optional). Auto-detects if not provided.
# Returns:
#  The OS name compatible with the asset name
function Get-Os {
	param([string]$System = "")

	$sys = if ($System) {
		$System
	} elseif ($IsWindows) {
		"Windows"
	} elseif ($IsMacOS) {
		"Darwin"
	} elseif ($IsLinux) {
		"Linux"
	} else {
		""
	}

	switch -Wildcard ($sys) {
		"Darwin*"  { return "darwin" }
		"Linux*"   { return "linux" }
		"Windows*" { return "windows" }
		default {
			throw "Unsupported OS. Exiting."
		}
	}
}

# Get the architecture name
# Arguments:
#   $Machine: The machine name (optional). Auto-detects if not provided.
# Returns:
#  The architecture name compatible with the asset name
function Get-Arch {
	param([string]$Machine = "")

	$mach = if ($Machine) {
		$Machine
	} else {
		[System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture.ToString()
	}

	switch ($mach) {
		{ $_ -in @("x86_64", "X64", "AMD64") }  { return "amd64" }
		{ $_ -in @("arm64", "aarch64", "Arm64") } { return "arm64" }
		default {
			throw "Unsupported architecture. Exiting."
		}
	}
}

# Get the asset name
# Arguments:
#   $Version: The oblt-cli version
#   $System: The system name (optional)
#   $Machine: The machine name (optional)
# Returns:
#  The asset name
function Get-AssetName {
	param(
		[Parameter(Mandatory = $true)][string]$Version,
		[string]$System = "",
		[string]$Machine = ""
	)

	$os   = Get-Os $System
	$arch = Get-Arch $Machine
	return "oblt-cli_${Version}_${os}_${arch}.tar.gz"
}

# Get the asset ID
# Globals:
#   $env:VAULT_GITHUB_TOKEN
# Arguments:
#   $Version: The oblt-cli version
# Returns:
#  The asset ID
function Get-AssetId {
	param([Parameter(Mandatory = $true)][string]$Version)

	$assetName = Get-AssetName $Version
	$headers   = @{
		"Accept"               = "application/vnd.github+json"
		"Authorization"        = "Bearer $env:VAULT_GITHUB_TOKEN"
		"X-GitHub-Api-Version" = "2022-11-28"
	}
	$release = Invoke-RestMethod `
		-Uri "https://api.github.com/repos/elastic/observability-test-environments/releases/tags/$Version" `
		-Headers $headers
	$asset = $release.assets | Where-Object { $_.name -eq $assetName }
	return $asset.id
}

# Download the asset
# Globals:
#   $env:VAULT_GITHUB_TOKEN
# Arguments:
#   $AssetId: The asset ID
#   $TargetDir: The target directory to extract the asset
# Returns:
#  None
function Invoke-DownloadAsset {
	param(
		[Parameter(Mandatory = $true)][string]$AssetId,
		[Parameter(Mandatory = $true)][string]$TargetDir
	)

	$headers  = @{
		"Accept"               = "application/octet-stream"
		"Authorization"        = "Bearer $env:VAULT_GITHUB_TOKEN"
		"X-GitHub-Api-Version" = "2022-11-28"
	}
	$tempFile = [System.IO.Path]::GetTempFileName()
	try {
		Invoke-WebRequest `
			-Uri "https://api.github.com/repos/elastic/observability-test-environments/releases/assets/$AssetId" `
			-Headers $headers `
			-OutFile $tempFile
		tar -xzf $tempFile -C $TargetDir
	} finally {
		Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
	}
}
