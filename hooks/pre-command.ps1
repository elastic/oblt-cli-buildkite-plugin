$ErrorActionPreference = "Stop"

$DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

$obltCliUsername     = if ($env:BUILDKITE_PLUGIN_OBLT_CLI_USERNAME) { $env:BUILDKITE_PLUGIN_OBLT_CLI_USERNAME } `
                       elseif ($env:BUILDKITE_REPO)                { [System.IO.Path]::GetFileNameWithoutExtension(($env:BUILDKITE_REPO -split '[/:]')[-1]) } `
                       else                                         { "obltmachine" }
$obltCliSlackChannel = if ($env:BUILDKITE_PLUGIN_OBLT_CLI_SLACK_CHANNEL)  { $env:BUILDKITE_PLUGIN_OBLT_CLI_SLACK_CHANNEL }  else { "#observablt-bots" }
$obltCliVersion      = if ($env:BUILDKITE_PLUGIN_OBLT_CLI_VERSION)        { $env:BUILDKITE_PLUGIN_OBLT_CLI_VERSION }        else { "" }
$obltCliVersionFile  = if ($env:BUILDKITE_PLUGIN_OBLT_CLI_VERSION_FILE)   { $env:BUILDKITE_PLUGIN_OBLT_CLI_VERSION_FILE }   else { Join-Path $DIR ".." ".default-oblt-cli-version" }

if (-not $env:VAULT_GITHUB_TOKEN) {
	Write-Error "The VAULT_GITHUB_TOKEN environment variable must be set."
	exit 1
}

. "$DIR/../lib/setup.ps1"

$gitUser  = if ($env:GIT_USER)  { $env:GIT_USER }  else { $obltCliUsername }
$gitEmail = if ($env:GIT_EMAIL) { $env:GIT_EMAIL } else { "$obltCliUsername@users.noreply.github.com" }

git config --global user.name $gitUser
git config --global user.email $gitEmail

$version = Get-VersionFromInputOrFile $obltCliVersion $obltCliVersionFile
Write-Output "~~~ :elastic-apm: Set up oblt-cli $version"
Invoke-Setup $version $obltCliUsername $obltCliSlackChannel $env:OBLT_CLI_BIN
