$ErrorActionPreference = "Stop"

Write-Output "--- Create cluster"
# Use --% (stop-parsing token) so that PowerShell passes the rest of the line
# verbatim to the process, with \"...\" honoured by the Win32 C-runtime argument
# parser.  This is required for PowerShell 5.1 (Windows PowerShell), which does
# not escape embedded double-quotes when building the native-process command
# line.  $PWD cannot be used after --%, so export it as an env-var first.
$env:OBLT_CLI_OUTPUT_FILE = "$PWD\cluster-info.json"
oblt-cli --% cluster create custom --dry-run --template serverless --cluster-name-prefix=oblt-cli-buildkite-plugin "--parameters={\"ProjectType\":\"observability\",\"Target\":\"qa\",\"EphemeralCluster\":\"true\"}" "--output-file=%OBLT_CLI_OUTPUT_FILE%"

Write-Output "~~~ Add cluster name to meta-data"
$clusterName = (Get-Content "$env:OBLT_CLI_OUTPUT_FILE" | ConvertFrom-Json).ClusterName
buildkite-agent meta-data set cluster-name $clusterName
