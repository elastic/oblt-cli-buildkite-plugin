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
	if [[ ! -f ${filename} ]]; then
		>&2 echo "version-file not found: ${filename}"
		return 1
	fi
	case $(basename "$filename") in
	".tool-versions")
		grep "^oblt-cli" "${filename}" | awk '{ printf $2 }'
		;;
	*)
		tr -d '[:space:]' <"${filename}"
		;;
	esac
}

# Get the version from the input or file
# If the input is not empty, it will return the input
# Otherwise, it will return the version from the file
# Arguments:
#   $1: input_version
#   $2: version_file
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
