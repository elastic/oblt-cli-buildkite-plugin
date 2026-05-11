#!/usr/bin/env bash

set -euo pipefail

echo "--- Create cluster"

DRY_RUN_FLAG=${1:-""}

DRY_RUN_ARG=""
if [ "$DRY_RUN_FLAG" = "--dry-run" ]; then
	DRY_RUN_ARG="--dry-run"
fi

oblt-cli cluster create custom \
	--template serverless \
	--cluster-name-prefix=oblt-cli-buildkite-plugin \
	--parameters='{"ProjectType":"observability","Target":"qa","EphemeralCluster":"true"}' \
	--output-file="${PWD}/cluster-info.json" \
	$DRY_RUN_ARG

echo "~~~ Add cluster name to meta-data"
buildkite-agent meta-data set cluster-name "$(jq -r .ClusterName "${PWD}/cluster-info.json")"
