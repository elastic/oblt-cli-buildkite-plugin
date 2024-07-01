#!/usr/bin/env bash

set -euo pipefail

# Get the version from the file
# Also supports .tool-versions file (asdf-vm)
# Arguments:
#   $1: filename
# Returns:
#   version
function get_version_from_file() {
	local -r filename=$1
	case $(basename "$filename") in
	".tool-versions")
		grep "^oblt-cli" "${filename}" | awk '{ printf $2 }'
		;;
	*)
		tr -d '[:space:]' <"${filename}"
		;;
	esac
}

# Get version from file or fallback
# Arguments:
#   $1: filename
#   $2: fallback
# Returns:
#   version
function get_version_from_file_or_fallback() {
	local -r filename="$1"
	local -r fallback="$2"
	if [[ -f ${filename} ]]; then
		get_version_from_file "${filename}"
		return
	fi
	echo "${fallback}"
}
