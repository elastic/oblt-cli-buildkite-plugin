#!/usr/bin/env bash

set -euo pipefail

echo "--- Create cluster"
output_file="${PWD}/cluster-info.json"
oblt-cli cluster create custom \
	--dry-run \
	--template serverless \
	--cluster-name-prefix=oblt-cli-buildkite-plugin \
	--parameters='{"ProjectType":"observability","Target":"qa","EphemeralCluster":"true"}' \
	--output-file "${output_file}"

echo "~~~ Add cluster name to meta-data"
buildkite-agent meta-data set cluster-name "$(jq -r .ClusterName "${output_file}")"
