#!/usr/bin/env pwsh

$CURR_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

. "$CURR_DIR/asset.ps1"
. "$CURR_DIR/version.ps1"

# Downloads oblt-cli and configures it
# Arguments:
#   $Version: The oblt-cli version
#   $Username: The oblt-cli username
#   $SlackChannel: The slack channel for notifications
#   $BinDir: The directory to install the binary
#   $Org: The GitHub organization
#   $Division: The division
#   $Project: The project
#   $Team: The team
# Returns:
#   None
function Invoke-Setup {
	param(
		[Parameter(Mandatory = $true)][string]$Version,
		[Parameter(Mandatory = $true)][string]$Username,
		[Parameter(Mandatory = $true)][string]$SlackChannel,
		[Parameter(Mandatory = $true)][string]$BinDir,
		[Parameter(Mandatory = $true)][string]$Org,
		[Parameter(Mandatory = $true)][string]$Division,
		[Parameter(Mandatory = $true)][string]$Project,
		[Parameter(Mandatory = $true)][string]$Team
	)

	$assetId = Get-AssetId $Version
	New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
	Invoke-DownloadAsset $assetId $BinDir
	$binExt = if ($env:OS -eq "Windows_NT") { ".exe" } else { "" }
	& "$BinDir/oblt-cli$binExt" configure `
		--git-http-mode `
		"--username=$Username" `
		"--slack-channel=$SlackChannel" `
		"--org=$Org" `
		"--division=$Division" `
		"--project=$Project" `
		"--team=$Team"
}
