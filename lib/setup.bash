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
	local -r asset_id=$(get_asset_id "$version")
	mkdir -p "${bin_dir}"
	download_asset "$asset_id" "$bin_dir"

	git config --global user.name "${GIT_USER:-"${username}"}"
	git config --global user.email "${GIT_EMAIL:-"${username}@users.noreply.github.com"}"

	git config --global credential.helper store
	echo "https://${GITHUB_TOKEN}:@github.com" >"${HOME}"/.git-credentials

	"${bin_dir}"/oblt-cli configure \
		--git-http-mode \
		--username="${username}" \
		--slack-channel="${slack_channel}"
}
