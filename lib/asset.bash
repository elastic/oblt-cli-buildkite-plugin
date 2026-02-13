#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/log.bash"

readonly GITHUB_API_BASE_URL="https://api.github.com/repos/elastic/observability-test-environments/releases"

function github_api_get() {
	local -r url=$1
	curl --silent --show-error --fail --location \
		--retry 3 --retry-delay 1 --connect-timeout 10 --retry-connrefused \
		-H "Accept: application/vnd.github+json" \
		-H "Authorization: Bearer ${VAULT_GITHUB_TOKEN}" \
		-H "X-GitHub-Api-Version: 2022-11-28" \
		"${url}"
}

# Get the OS name
# Arguments:
#   $1: The system name - (optional)
# Returns:
#  The OS name compatible with the asset name
function get_os() {
	local -r system=${1:-$(uname -s)}
	case "${system}" in
	Darwin*)
		echo 'darwin'
		;;
	Linux*)
		echo 'linux'
		;;
	*)
		>&2 echo "Unsupported OS. Exiting."
		return 1
		;;
	esac
}

# Get the architecture name
# Arguments:
#   $1: The machine name - (optional)
# Returns:
#  The architecture name compatible with the asset name
function get_arch() {
	local -r machine=${1:-$(uname -m)}
	case "${machine}" in
	x86_64)
		echo 'amd64'
		;;
	arm64 | aarch64)
		echo 'arm64'
		;;
	*)
		>&2 echo "Unsupported architecture. Exiting."
		return 1
		;;
	esac
}

# Get the asset name
# Arguments:
#   $1: The oblt-cli version
#   $2: The system name - (optional)
#   $3: The machine name - (optional)
# Returns:
#  The asset name
function get_asset_name() {
	local -r version=$1
	local -r system=${2:-}
	local -r machine=${3:-}
	local os
	local arch
	if ! os=$(get_os "$system"); then return 1; fi
	if ! arch=$(get_arch "$machine"); then return 1; fi
	echo "oblt-cli_${version}_${os}_${arch}.tar.gz"
}

function get_release_json() {
	local -r version=$1
	local release
	if ! release=$(github_api_get "${GITHUB_API_BASE_URL}/tags/${version}"); then
		log_fail "Failed to fetch release metadata for version ${version}."
		return 1
	fi
	echo "${release}"
}

function get_asset_id_from_release() {
	local -r release_json=$1
	local -r asset_name=$2
	local asset_id
	asset_id=$(echo "${release_json}" | jq -r --arg name "${asset_name}" '.assets[] | select(.name == $name) | .id')
	if [[ -z ${asset_id} || ${asset_id} == "null" ]]; then
		log_fail "Asset not found for ${asset_name}."
		return 1
	fi
	echo "${asset_id}"
}

function get_checksums_asset_id_from_release() {
	local -r release_json=$1
	local checksums_id
	checksums_id=$(echo "${release_json}" | jq -r '.assets[] | select(.name == "checksums.txt") | .id')
	if [[ -z ${checksums_id} || ${checksums_id} == "null" ]]; then
		echo ""
		return 0
	fi
	echo "${checksums_id}"
}

# Get the asset ID
# Globals:
#   VAULT_GITHUB_TOKEN
# Arguments:
#   $1: The oblt-cli version
# Returns:
#  The asset ID
function get_asset_id() {
	local -r version=$1
	local -r asset_name=$(get_asset_name "$version")
	local release
	release=$(get_release_json "${version}")
	get_asset_id_from_release "${release}" "${asset_name}"
}

function get_checksums_asset_id() {
	local -r version=$1
	local release
	release=$(get_release_json "${version}")
	get_checksums_asset_id_from_release "${release}"
}

function get_sha256_tool() {
	if command -v sha256sum >/dev/null 2>&1; then
		echo "sha256sum"
		return 0
	fi
	if command -v shasum >/dev/null 2>&1; then
		echo "shasum"
		return 0
	fi
	return 1
}

function verify_checksum() {
	local -r checksums_file=$1
	local -r asset_file=$2
	local -r asset_name=$3
	local expected
	local actual
	local sha_tool
	if ! sha_tool=$(get_sha256_tool); then
		log_fail "Checksum verification requires sha256sum or shasum."
		return 1
	fi
	expected=$(grep -E " ${asset_name}$" "${checksums_file}" | awk '{ print $1 }')
	if [[ -z ${expected} ]]; then
		log_fail "Checksum entry not found for ${asset_name}."
		return 1
	fi
	if [[ ${sha_tool} == "sha256sum" ]]; then
		actual=$(sha256sum "${asset_file}" | awk '{ print $1 }')
	else
		actual=$(shasum -a 256 "${asset_file}" | awk '{ print $1 }')
	fi
	if [[ ${actual} != "${expected}" ]]; then
		log_fail "Checksum verification failed for ${asset_name}."
		return 1
	fi
}

# Download the asset
# Globals:
#   VAULT_GITHUB_TOKEN
# Arguments:
#   $1: The asset ID
#   $2: The target directory to extract the asset
# Returns:
#  None
function download_asset() {
	local -r asset_id=$1
	local -r asset_name=$2
	local -r target_dir=$3
	local -r checksums_asset_id=${4:-}
	local asset_tmp=""
	local checksums_tmp=""
	cleanup() {
		local tmp_asset="${asset_tmp:-}"
		local tmp_checksums="${checksums_tmp:-}"
		if [[ -n ${tmp_asset} ]]; then
			rm -f "${tmp_asset}"
		fi
		if [[ -n ${tmp_checksums} ]]; then
			rm -f "${tmp_checksums}"
		fi
	}
	trap cleanup RETURN
	asset_tmp=$(mktemp)

	mkdir -p "${target_dir}"

	log_info "Downloading ${asset_name}."
	curl --silent --show-error --fail --location \
		--retry 3 --retry-delay 1 --connect-timeout 10 --retry-connrefused \
		-H "Accept: application/octet-stream" \
		-H "Authorization: Bearer ${VAULT_GITHUB_TOKEN}" \
		-H "X-GitHub-Api-Version: 2022-11-28" \
		"${GITHUB_API_BASE_URL}/assets/${asset_id}" \
		-o "${asset_tmp}"

	if [[ -n ${checksums_asset_id} ]]; then
		log_info "Verifying checksum for ${asset_name}."
		checksums_tmp=$(mktemp)
		curl --silent --show-error --fail --location \
			--retry 3 --retry-delay 1 --connect-timeout 10 --retry-connrefused \
			-H "Accept: application/octet-stream" \
			-H "Authorization: Bearer ${VAULT_GITHUB_TOKEN}" \
			-H "X-GitHub-Api-Version: 2022-11-28" \
			"${GITHUB_API_BASE_URL}/assets/${checksums_asset_id}" \
			-o "${checksums_tmp}"
		verify_checksum "${checksums_tmp}" "${asset_tmp}" "${asset_name}"
	else
		log_warn "Checksums asset not found; skipping checksum verification."
	fi

	if tar -tzf "${asset_tmp}" | grep -E '(^|/)\.\.(/|$)' >/dev/null 2>&1; then
		log_fail "Archive contains unsafe paths."
		return 1
	fi

	tar -xzf "${asset_tmp}" -C "${target_dir}"
}
