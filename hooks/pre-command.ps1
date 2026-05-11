$ErrorActionPreference = "Stop"

$DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

$obltCliUsername     = if ($env:BUILDKITE_PLUGIN_OBLT_CLI_USERNAME)       { $env:BUILDKITE_PLUGIN_OBLT_CLI_USERNAME }       else { "obltmachine" }
$obltCliSlackChannel = if ($env:BUILDKITE_PLUGIN_OBLT_CLI_SLACK_CHANNEL)  { $env:BUILDKITE_PLUGIN_OBLT_CLI_SLACK_CHANNEL }  else { "#observablt-bots" }
$obltCliVersion      = if ($env:BUILDKITE_PLUGIN_OBLT_CLI_VERSION)        { $env:BUILDKITE_PLUGIN_OBLT_CLI_VERSION }        else { "" }
$obltCliVersionFile  = if ($env:BUILDKITE_PLUGIN_OBLT_CLI_VERSION_FILE)   { $env:BUILDKITE_PLUGIN_OBLT_CLI_VERSION_FILE }   else { Join-Path $DIR ".." ".default-oblt-cli-version" }
$obltCliOrg          = if ($env:BUILDKITE_PLUGIN_OBLT_CLI_ORG)            { $env:BUILDKITE_PLUGIN_OBLT_CLI_ORG }            else { "" }
$obltCliDivision     = if ($env:BUILDKITE_PLUGIN_OBLT_CLI_DIVISION)       { $env:BUILDKITE_PLUGIN_OBLT_CLI_DIVISION }       else { "" }
$obltCliProject      = if ($env:BUILDKITE_PLUGIN_OBLT_CLI_PROJECT)        { $env:BUILDKITE_PLUGIN_OBLT_CLI_PROJECT }        else { "" }
$obltCliTeam         = if ($env:BUILDKITE_PLUGIN_OBLT_CLI_TEAM)           { $env:BUILDKITE_PLUGIN_OBLT_CLI_TEAM }           else { "" }

if (-not $env:VAULT_GITHUB_TOKEN) {
	Write-Error "The VAULT_GITHUB_TOKEN environment variable must be set."
	exit 1
}

if (-not $obltCliOrg) {
	Write-Error "The 'org' plugin property is required."
	exit 1
}

if (-not $obltCliDivision) {
	Write-Error "The 'division' plugin property is required."
	exit 1
}

if (-not $obltCliProject) {
	Write-Error "The 'project' plugin property is required."
	exit 1
}

if (-not $obltCliTeam) {
	Write-Error "The 'team' plugin property is required."
	exit 1
}

. "$DIR/../lib/setup.ps1"

$gitUser  = if ($env:GIT_USER)  { $env:GIT_USER }  else { $obltCliUsername }
$gitEmail = if ($env:GIT_EMAIL) { $env:GIT_EMAIL } else { "$obltCliUsername@users.noreply.github.com" }

git config --global user.name $gitUser
git config --global user.email $gitEmail

$version = Get-VersionFromInputOrFile $obltCliVersion $obltCliVersionFile
Write-Output "~~~ :elastic-apm: Set up oblt-cli $version"
Invoke-Setup $version $obltCliUsername $obltCliSlackChannel $env:OBLT_CLI_BIN $obltCliOrg $obltCliDivision $obltCliProject $obltCliTeam
