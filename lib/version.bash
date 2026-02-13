#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/log.bash"

# Get the version from the file
# Also supports .tool-versions file (asdf-vm)
# Arguments:
#   $1: The file where the version is stored
# Returns:
#   version
function get_version_from_file() {
	local -r filename=$1
	local version
	if [[ ! -f ${filename} ]]; then
		log_fail "version-file not found: ${filename}"
		return 1
	fi
	case $(basename "$filename") in
	".tool-versions")
		version=$(grep "^oblt-cli" "${filename}" | awk '{ printf $2 }')
		;;
	*)
		version=$(tr -d '[:space:]' <"${filename}")
		;;
	esac
	if [[ -z ${version} ]]; then
		log_fail "version-file is empty or missing oblt-cli entry: ${filename}"
		return 1
	fi
	echo "${version}"
}

# Get the version from the input or file
# If the input is not empty, it will return the input
# Otherwise, it will return the version from the file
# Arguments:
#   $1: The version provided as plugin property
#   $2: The file where the version is stored
# Returns:
#   version
function get_version_from_input_or_file() {
	local -r input_version=$1
	local -r version_file=$2
	if [[ -n ${input_version} && -n ${version_file} ]]; then
		buildkite-agent annotate "elastic/oblt-cli plugin: Both version and version-file are provided. Using version: ${input_version}." --style=warning --context=ctx-version
	fi
	if [[ -n ${input_version} ]]; then
		echo "${input_version}"
		return
	fi
	get_version_from_file "${version_file}"
}
