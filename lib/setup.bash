#!/usr/bin/env bash

set -euo pipefail

CURR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
. "${CURR_DIR}/asset.bash"

# shellcheck disable=SC1091
. "${CURR_DIR}/version.bash"

# Downloads oblt-cli and configures it
# Arguments:
#   $1: version
#   $2: username
#   $3: slack_channel
#   $4: bin_dir
# Returns:
#   None
function setup() {
	local -r version=$1
	local -r username=$2
	local -r slack_channel=$3
	local -r bin_dir=$4
	local -r gh_token=$5
	local -r asset_id=$(get_asset_id "$version" "$gh_token")
	mkdir -p "${bin_dir}"
	download_asset "$asset_id" "$bin_dir" "$gh_token"
	"${bin_dir}"/oblt-cli configure \
		--git-http-mode \
		--username="${username}" \
		--slack-channel="${slack_channel}"
}
