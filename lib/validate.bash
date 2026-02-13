#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/log.bash"

function require_env() {
	local -r name=$1
	local -r value=${2:-}
	if [[ -z ${value} ]]; then
		log_fail "${name} must be set."
		return 1
	fi
}

function validate_username() {
	local -r username=$1
	if [[ -z ${username} ]]; then
		log_fail "username must not be empty."
		return 1
	fi
	if [[ ${username} =~ [[:space:]] ]]; then
		log_fail "username must not contain spaces."
		return 1
	fi
}

function validate_slack_channel() {
	local -r channel=$1
	if [[ -z ${channel} ]]; then
		log_fail "slack-channel must not be empty."
		return 1
	fi
	if [[ ! ${channel} =~ ^[#@][A-Za-z0-9._-]+$ ]]; then
		log_fail "slack-channel must start with # or @ and contain only letters, numbers, dots, underscores, or dashes."
		return 1
	fi
}

function validate_version_format() {
	local -r version=$1
	if [[ -z ${version} ]]; then
		log_fail "version must not be empty."
		return 1
	fi
	if [[ ! ${version} =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]]; then
		log_fail "version must be a semantic version (e.g., 7.3.0)."
		return 1
	fi
}

function validate_safe_path() {
	local -r path=$1
	local workspace=${2:-$PWD}
	local candidate
	local resolved
	workspace=${workspace%/}
	if [[ -z ${path} ]]; then
		return 0
	fi
	if [[ ${path} == ~* ]]; then
		log_fail "version-file must not use '~' expansion."
		return 1
	fi
	candidate=${path}
	if [[ ${path} != /* ]]; then
		candidate="${workspace}/${path}"
	fi
	if command -v realpath >/dev/null 2>&1; then
		if resolved=$(realpath -m "${candidate}" 2>/dev/null); then
			:
		else
			resolved=""
		fi
	fi
	if [[ -z ${resolved} ]] && command -v readlink >/dev/null 2>&1; then
		resolved=$(readlink -f "${candidate}" 2>/dev/null || true)
	fi
	if [[ -z ${resolved} ]]; then
		local candidate_dir
		local candidate_base
		local resolved_dir
		candidate_dir=$(dirname "${candidate}")
		candidate_base=$(basename "${candidate}")
		if resolved_dir=$(cd "${candidate_dir}" 2>/dev/null && pwd -P); then
			resolved="${resolved_dir}/${candidate_base}"
		else
			if [[ ${path} == *".."* ]]; then
				log_fail "version-file must not contain '..' segments without realpath support."
				return 1
			fi
			resolved=${candidate}
		fi
	fi
	case "${resolved}" in
		"${workspace}" | "${workspace}"/*)
			;;
		*)
			log_fail "version-file must be within the workspace: ${workspace}"
			return 1
			;;
	esac
}
