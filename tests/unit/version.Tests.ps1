#!/usr/bin/env pwsh

BeforeAll {
	. "$PSScriptRoot/../../lib/version.ps1"
}

Describe "Get-VersionFromFile" {
	It "Should return version from .tool-versions file" {
		$toolVersionsFile = "$PSScriptRoot/../../tests/fixtures/.tool-versions"

		Get-VersionFromFile $toolVersionsFile | Should -Be "7.2.5"
	}

	It "Should return version from any file" {
		$versionFile = "$PSScriptRoot/../../tests/fixtures/.oblt-cli-version"

		Get-VersionFromFile $versionFile | Should -Be "7.2.2"
	}

	It "Should throw when file does not exist" {
		{ Get-VersionFromFile "$PSScriptRoot/../../non_existent_file" } | Should -Throw "*version-file not found*"
	}
}

Describe "Get-VersionFromInputOrFile" {
	It "Should return input when both version and version-file are provided" {
		$versionFile = "$PSScriptRoot/../../tests/fixtures/.oblt-cli-version"
		Mock Invoke-BuildkiteAnnotate { }

		Get-VersionFromInputOrFile "7.2.5" $versionFile | Should -Be "7.2.5"
		Should -Invoke Invoke-BuildkiteAnnotate -Times 1
	}

	It "Should return version from file when input is empty" {
		$versionFile = "$PSScriptRoot/../../tests/fixtures/.oblt-cli-version"

		Get-VersionFromInputOrFile "" $versionFile | Should -Be "7.2.2"
	}

	It "Should throw when input is empty and file does not exist" {
		{ Get-VersionFromInputOrFile "" "$PSScriptRoot/../../non_existent_file" } | Should -Throw "*version-file not found*"
	}
}
