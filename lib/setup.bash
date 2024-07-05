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
# Returns:
#   None
function setup() {
	local -r version=$1
	local -r username=$2
	local -r slack_channel=$3
	local -r bin_dir=$4
	local -r asset_id=$(get_asset_id "$version")
	mkdir -p "${bin_dir}"
	temp_dir=$(mktemp -d)
	download_asset "$asset_id" "$temp_dir"
	cat <<EOF >"${bin_dir}/oblt-cli"
#!/usr/bin/env bash
OBLT_CLI_BINARY="${temp_dir}/oblt-cli" "${CURR_DIR}/../bin/oblt-cli-wrapper" "\$@"
EOF
	chmod +x "${bin_dir}/oblt-cli"
	oblt-cli configure \
		--git-http-mode \
		--username="${username}" \
		--slack-channel="${slack_channel}"
}
