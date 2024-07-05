#!/usr/bin/env bash

set -euo pipefail

# Destroys the cluster
# Globals:
#  OBLT_CLI_OUTPUT_FILE
#  BUILDKITE_PLUGIN_OBLT_CLI_AUTO_DESTROY
# Arguments:
#  None
# Returns:
#  Always 0
function destroy::destroy_cluster() {
	if [[ 
		${BUILDKITE_PLUGIN_OBLT_CLI_AUTO_DESTROY:-false} == "false" ||
		! -f $OBLT_CLI_OUTPUT_FILE ]] \
		; then
		exit 0
	fi
	local -r cluster_name="$(jq -r .ClusterName "$OBLT_CLI_OUTPUT_FILE")"
	if destroy::wait_until_exists "${cluster_name}"; then
		oblt-cli cluster destroy \
			--force \
			--disable-banner \
			--cluster-name="${cluster_name}" || true
	fi
}

# Wait if the cluster exists
# Arguments:
#   $1: cluster name
# Returns:
#   0 if the cluster exists after 10 attempts, 1 otherwise
function destroy::wait_until_exists() {
	local -r cluster_name="$1"
	readonly MAX_ATTEMPTS=10
	attempt=0
	until destroy::cluster_exists "${cluster_name}"; do
		attempt=$((attempt + 1))
		if [[ ${attempt} -gt ${MAX_ATTEMPTS} ]]; then
			>&2 echo "[WARNING] Failed to get cluster secrets after ${MAX_ATTEMPTS} attempts. Exiting."
			return 1
		fi
		sleep 60
		>&2 echo "[INFO] Retrying to check if cluster exists. Attempt ${attempt}/${MAX_ATTEMPTS}"
	done
	return 0
}

# Check if the cluster exists before destroying it
# Arguments:
#   $1: cluster name
# Returns:
#   0 if the cluster exists, 1 otherwise
function destroy::cluster_exists() {
	>&2 echo "[INFO] Checking if cluster exists: $1"
	oblt-cli cluster secrets cluster-state --cluster-name "$1" >/dev/null 2>&1
}
