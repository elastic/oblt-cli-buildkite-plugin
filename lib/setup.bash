#!/usr/bin/env bash

set -euo pipefail

CURR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
. "${CURR_DIR}/asset.bash"

# shellcheck disable=SC1091
. "${CURR_DIR}/version.bash"

# Compares two semantic versions to determine if the first version is greater than or equal to the second.
# Arguments:
#   $1: version_a - The first version to compare (e.g., "7.19.0").
#   $2: version_b - The second version to compare (e.g., "7.19.1").
# Returns:
#   0 if version_a is greater than or equal to version_b.
#   1 if version_a is less than version_b.
function is_version_greater_or_equal() {
	local version_a=$1
	local version_b=$2

	# Split versions into components
	IFS='.' read -r -a version_a_parts <<< "$version_a"
	IFS='.' read -r -a version_b_parts <<< "$version_b"

	# Compare each part numerically
	for i in {0..2}; do
		local part_a=${version_a_parts[i]:-0}
		local part_b=${version_b_parts[i]:-0}

		if (( part_a > part_b )); then
			return 0 # version_a is greater
		elif (( part_a < part_b )); then
			return 1 # version_a is not greater or equal
		fi
	done

	return 0
}

# Downloads oblt-cli and configures it
# Arguments:
#   $1: The oblt-cli version
#   $2: The oblt-cli username
#   $3: The slack channel for notifications
#   $4: The directory to install the binary
#   $5: The GCP project (default elastic-observability)
# Returns:
#   None
function setup() {
	local -r version=$1
	local -r username=$2
	local -r slack_channel=$3
	local -r bin_dir=$4
	local -r project=${5:-elastic-observability}
	local -r asset_id=$(get_asset_id "$version")
	mkdir -p "${bin_dir}"
	download_asset "$asset_id" "$bin_dir"

	if is_version_greater_or_equal "$version" "7.19.0"; then
		GCP_PROJECT_FLAG="--gcp-project=${project}"
	fi

	"${bin_dir}"/oblt-cli configure \
		--git-http-mode \
		--username="${username}" \
		--slack-channel="${slack_channel}" ${GCP_PROJECT_FLAG:-}
}
