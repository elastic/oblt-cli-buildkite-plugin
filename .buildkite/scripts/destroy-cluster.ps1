$ErrorActionPreference = "Stop"

Write-Output "--- Destroy cluster"
$clusterName = & buildkite-agent meta-data get cluster-name-amd
$env:OBLT_CLI_CLUSTER_NAME = $clusterName
oblt-cli --% cluster destroy "--cluster-name=%OBLT_CLI_CLUSTER_NAME%"
