#!/usr/bin/env bash

set -euo pipefail

echo "--- Create cluster"
oblt-cli cluster create custom \
	--dry-run \
	--template serverless \
	--cluster-name-prefix=oblt-cli-buildkite-plugin \
	--parameters='{"ProjectType":"observability","Target":"qa","EphemeralCluster":"true"}'

echo "~~~ Add cluster name to meta-data"
buildkite-agent meta-data set cluster-name "$(jq -r .ClusterName "${PWD}/cluster-info.json")"
