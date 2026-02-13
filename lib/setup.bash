#!/usr/bin/env bash

set -euo pipefail

CURR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
. "${CURR_DIR}/log.bash"

# shellcheck disable=SC1091
. "${CURR_DIR}/validate.bash"

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
# Returns:
#   None
function setup() {
	local -r version=$1
	local -r username=$2
	local -r slack_channel=$3
	local -r bin_dir=$4
	local release
	local asset_name
	local asset_id
	local checksums_asset_id
	require_env "OBLT_CLI_BIN" "${bin_dir}"
	validate_version_format "${version}"
	validate_username "${username}"
	validate_slack_channel "${slack_channel}"
	release=$(get_release_json "${version}")
	asset_name=$(get_asset_name "${version}")
	asset_id=$(get_asset_id_from_release "${release}" "${asset_name}")
	checksums_asset_id=$(get_checksums_asset_id_from_release "${release}")
	download_asset "${asset_id}" "${asset_name}" "${bin_dir}" "${checksums_asset_id}"
	log_info "Configuring oblt-cli."
	"${bin_dir}"/oblt-cli configure \
		--git-http-mode \
		--username="${username}" \
		--slack-channel="${slack_channel}"
}
