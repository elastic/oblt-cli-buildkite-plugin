#!/usr/bin/env bash

set -euo pipefail

CURR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
. "${CURR_DIR}/asset.bash"

# shellcheck disable=SC1091
. "${CURR_DIR}/version.bash"

# Downloads oblt-cli and configures it
# Arguments:
#   $1: The oblt-cli version
#   $2: The oblt-cli username
#   $3: The slack channel for notifications
#   $4: The directory to install the binary
#   $5: The GitHub organization
#   $6: The division
#   $7: The project
#   $8: The team
# Returns:
#   None
function setup() {
	local -r version=$1
	local -r username=$2
	local -r slack_channel=$3
	local -r bin_dir=$4
	local -r org=$5
	local -r division=$6
	local -r project=$7
	local -r team=$8
	local -r asset_id=$(get_asset_id "$version")
	mkdir -p "${bin_dir}"
	download_asset "$asset_id" "$bin_dir"
	"${bin_dir}"/oblt-cli configure \
		--git-http-mode \
		--username="${username}" \
		--slack-channel="${slack_channel}" \
		--org="${org}" \
		--division="${division}" \
		--project="${project}" \
		--team="${team}"
}
