#!/usr/bin/env bash

set -euo pipefail

echo "~~~ Set up git"
git config --global user.name "obltmachine"
git config --global user.email "obltmachine@users.noreply.github.com"

echo "--- Create cluster"
oblt-cli cluster create custom \
	--dry-run \
	--template serverless \
	--cluster-name-prefix=oblt-cli-buildkite-plugin \
	--parameters='{"ProjectType":"observability","Target":"qa","EphemeralCluster":"true"}' \
	--output-file="${PWD}/cluster-info.json"

echo "~~~ Add cluster name to meta-data"
buildkite-agent meta-data set cluster-name "$(jq -r .ClusterName "${PWD}/cluster-info.json")"
