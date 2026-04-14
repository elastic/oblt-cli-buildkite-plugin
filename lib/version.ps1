#!/usr/bin/env pwsh

# Get the version from the file
# Also supports .tool-versions file (asdf-vm)
# Arguments:
#   $Filename: The file where the version is stored
# Returns:
#   version
function Get-VersionFromFile {
	param([Parameter(Mandatory = $true)][string]$Filename)

	if (-not (Test-Path $Filename)) {
		throw "version-file not found: $Filename"
	}

	$basename = [System.IO.Path]::GetFileName($Filename)
	if ($basename -eq ".tool-versions") {
		$line = Get-Content $Filename | Where-Object { $_ -match "^oblt-cli" }
		return ($line -split '\s+')[1]
	} else {
		return (Get-Content $Filename -Raw).Trim()
	}
}

# Emit a Buildkite annotation warning
# Arguments:
#   $Message: The annotation message
function Invoke-BuildkiteAnnotate {
	param([Parameter(Mandatory = $true)][string]$Message)
	& buildkite-agent annotate $Message --style=warning --context=ctx-version
}

# Get the version from the input or file
# If the input is not empty, it will return the input
# Otherwise, it will return the version from the file
# Arguments:
#   $InputVersion: The version provided as plugin property
#   $VersionFile: The file where the version is stored
# Returns:
#   version
function Get-VersionFromInputOrFile {
	param(
		[Parameter(Mandatory = $true)][AllowEmptyString()][string]$InputVersion,
		[Parameter(Mandatory = $true)][string]$VersionFile
	)

	if ($InputVersion -and $VersionFile) {
		Invoke-BuildkiteAnnotate "elastic/oblt-cli plugin: Both version and version-file are provided. Using version: $InputVersion."
	}

	if ($InputVersion) {
		return $InputVersion
	}

	return Get-VersionFromFile $VersionFile
}
