#!/usr/bin/env bash

set -euo pipefail

function log_info() {
	echo "+++ :information_source: $*"
}

function log_warn() {
	>&2 echo "+++ :warning: $*"
}

function log_error() {
	>&2 echo "+++ :x: $*"
}

function log_fail() {
	local -r message=${1:-"Unknown error"}
	log_error "${message}"
	return 1
}

function redact_secret() {
	local -r secret_value=${1:-}
	if [[ -z ${secret_value} ]]; then
		return 0
	fi
	if command -v buildkite-agent >/dev/null 2>&1; then
		if buildkite-agent redactor add "${secret_value}" >/dev/null 2>&1; then
			return 0
		fi
	fi
	log_warn "Secret redaction is unavailable; avoid printing sensitive values."
}
