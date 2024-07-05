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

  if [[ \$1 == "cluster" && \$2 == "create" ]]; then
      POSITIONAL_ARGS=()
      while [[ $# -gt 0 ]]; do
        case \$1 in
          --output-file)
            OUTPUT_FILE="\$2"
            shift
            shift
            ;;
          --output-file=*)
            OUTPUT_FILE="\${1#*=}"
            shift
            ;;
          *)
            POSITIONAL_ARGS+=("\$1")
            shift # past argument
            ;;
        esac
      done

      set -- "\${POSITIONAL_ARGS[@]}"
      echo "\$OUTPUT_FILE"
      echo "\${POSITIONAL_ARGS[@]}"

      "${temp_dir}/oblt-cli" "\${POSITIONAL_ARGS[@]}" --output-file="\$OUTPUT_FILE"

      cp "\$OUTPUT_FILE" "\$OBLT_CLI_OUTPUT_FILE"
  else
      "${temp_dir}/oblt-cli" "\$@"
  fi
EOF
	chmod +x "${bin_dir}/oblt-cli"
	oblt-cli configure \
		--git-http-mode \
		--username="${username}" \
		--slack-channel="${slack_channel}"
}
