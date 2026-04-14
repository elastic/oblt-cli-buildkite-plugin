$ErrorActionPreference = "Stop"

Write-Output "--- Create cluster"
oblt-cli cluster create custom `
	--dry-run `
	--template serverless `
	--cluster-name-prefix=oblt-cli-buildkite-plugin `
	'--parameters={"ProjectType":"observability","Target":"qa","EphemeralCluster":"true"}' `
	"--output-file=$PWD\cluster-info.json"

Write-Output "~~~ Add cluster name to meta-data"
$clusterName = (Get-Content "$PWD\cluster-info.json" | ConvertFrom-Json).ClusterName
buildkite-agent meta-data set cluster-name $clusterName
