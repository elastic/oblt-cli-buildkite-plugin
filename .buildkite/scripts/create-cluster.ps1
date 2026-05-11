$ErrorActionPreference = "Stop"

param(
    [string]$Flag = ""
)

Write-Output "--- Create cluster"
$env:OBLT_CLI_OUTPUT_FILE = "$PWD\cluster-info.json"

$parametersJson = @{
    ProjectType = "observability"
    Target = "qa"
    EphemeralCluster = "true"
} | ConvertTo-Json -Compress

$parametersString = $parametersJson -replace '"', '\"'

$dryRunFlag = ""
if ($Flag -eq "--dry-run") {
    $dryRunFlag = "--dry-run"
}

# Use --% (stop-parsing token) so that PowerShell passes the rest of the line
# verbatim to the process, with \"...\" honoured by the Win32 C-runtime argument
# parser.  This is required for PowerShell 5.1 (Windows PowerShell), which does
# not escape embedded double-quotes when building the native-process command
# line.  $PWD cannot be used after --%, so export it as an env-var first.
$command = "oblt-cli --% cluster create custom $dryRunFlag --template serverless --cluster-name-prefix=oblt-cli-buildkite-plugin ""--parameters=$parametersString"" ""--output-file=%OBLT_CLI_OUTPUT_FILE%"""
Invoke-Expression $command

Write-Output "~~~ Add cluster name to meta-data"
$clusterName = (Get-Content "$env:OBLT_CLI_OUTPUT_FILE" | ConvertFrom-Json).ClusterName
buildkite-agent meta-data set cluster-name-amd $clusterName
