Write-Output "--- Create cluster"
oblt-cli cluster create custom `
	--dry-run `
	--template serverless `
	--cluster-name-prefix=oblt-cli-buildkite-plugin `
	--parameters='{"ProjectType":"observability","Target":"qa","EphemeralCluster":"true"}' `
	--output-file="cluster-info.json"

Write-Output "~~~ Add cluster name to meta-data"
$ClusterName = (Get-Content -Path "cluster-info.json" | ConvertFrom-Json).ClusterName
if (-not $ClusterName) {
	Write-Error "Error: Failed to retrieve cluster name from cluster-info.json"
	return 1
}
buildkite-agent meta-data set cluster-name-windows "$ClusterName"
