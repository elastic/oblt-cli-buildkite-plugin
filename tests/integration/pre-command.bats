#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"

export OBLT_CLI_BIN="${HOME}/.oblt-cli/bin"
export VAULT_GITHUB_TOKEN=${GH_TOKEN:-${GITHUB_TOKEN:-$VAULT_GITHUB_TOKEN}}

stub_git() {
	stub git \
		"config --global user.name \* : echo 'git: Set user.name'" \
		"config --global user.email \* : echo 'git: Set user.email'"
}

stub_buildkite_agent() {
	stub buildkite-agent \
		"redactor add \* : true" \
		"annotate \* : true"
}

create_curl_stub() {
	local -r bin_dir=$1
	cat >"${bin_dir}/curl" <<'EOF'
#!/usr/bin/env bash

set -euo pipefail

output=""
url=""
while [[ $# -gt 0 ]]; do
	case "$1" in
		-o)
			output=$2
			shift 2
			;;
		http*)
			url=$1
			shift
			;;
		*)
			shift
			;;
	esac
done

if [[ ${url} == *"/tags/"* ]]; then
	# Extract version from URL (e.g., /tags/7.2.2 -> 7.2.2)
	version=$(echo "${url}" | sed -n 's|.*/tags/\([^/]*\).*|\1|p')
	# Generate dynamic release JSON with the requested version
	cat <<JSON
{
  "assets": [
    {
      "id": 176068054,
      "name": "oblt-cli_${version}_linux_amd64.tar.gz"
    }
  ]
}
JSON
	exit 0
fi

if [[ ${url} == *"/assets/"* ]]; then
	if [[ -z ${output} ]]; then
		cat "${CURL_STUB_ASSET_FILE}"
	else
		cat "${CURL_STUB_ASSET_FILE}" >"${output}"
	fi
	exit 0
fi

exit 1
EOF
	chmod +x "${bin_dir}/curl"
}

setup_curl_stub() {
	local -r asset_dir=$1
	local -r bin_dir=$2
	tar -czf "${asset_dir}/oblt-cli.tar.gz" --directory "$PWD/tests/fixtures" oblt-cli
	create_curl_stub "${bin_dir}"
	PATH="${bin_dir}:${PATH}"
	export CURL_STUB_ASSET_FILE="${asset_dir}/oblt-cli.tar.gz"
}

cleanup_curl_stub() {
	local -r bin_dir=$1
	unset CURL_STUB_ASSET_FILE
	PATH="${PATH#${bin_dir}:}"
}

@test "pre-command version from file" {
	# arrange
	stub_git
	stub_buildkite_agent
	asset_dir=$(temp_make)
	bin_dir=$(temp_make)
	setup_curl_stub "${asset_dir}" "${bin_dir}"

	# act
	run env BUILDKITE_PLUGIN_OBLT_CLI_VERSION_FILE="${PWD}/tests/fixtures/.oblt-cli-version" \
		"$PWD/hooks/pre-command"

	# assert
	assert_success
	assert_output --partial "~~~ :elastic-apm: Set up oblt-cli 7.2.2"
	assert_output --partial "Writing configuration file /home/plugin-tester/.oblt-cli/config.yaml"

	# cleanup
	unstub git
	unstub buildkite-agent || true
	cleanup_curl_stub "${bin_dir}"
	temp_del "${asset_dir}"
	temp_del "${bin_dir}"
}

@test "pre-command version from input" {
	# arrange
	stub_git
	stub_buildkite_agent
	asset_dir=$(temp_make)
	bin_dir=$(temp_make)
	setup_curl_stub "${asset_dir}" "${bin_dir}"

	# act
	run env BUILDKITE_PLUGIN_OBLT_CLI_VERSION="7.2.5" \
		"$PWD/hooks/pre-command"

	# assert
	assert_success
	assert_output --partial "~~~ :elastic-apm: Set up oblt-cli 7.2.5"
	assert_output --partial "Writing configuration file /home/plugin-tester/.oblt-cli/config.yaml"

	# cleanup
	unstub git
	unstub buildkite-agent || true
	cleanup_curl_stub "${bin_dir}"
	temp_del "${asset_dir}"
	temp_del "${bin_dir}"
}

@test "pre-command default version" {
	# arrange
	stub_git
	stub_buildkite_agent
	asset_dir=$(temp_make)
	bin_dir=$(temp_make)
	setup_curl_stub "${asset_dir}" "${bin_dir}"

	# act
	run "$PWD/hooks/pre-command"

	# assert
	version=$(cat "${PWD}/.default-oblt-cli-version")
	assert_success
	assert_output --partial "~~~ :elastic-apm: Set up oblt-cli ${version}"
	assert_output --partial "Writing configuration file /home/plugin-tester/.oblt-cli/config.yaml"

	# cleanup
	unstub git
	unstub buildkite-agent || true
	cleanup_curl_stub "${bin_dir}"
	temp_del "${asset_dir}"
	temp_del "${bin_dir}"
}

@test "pre-command non-existent version file should fail" {
	# arrange
	stub_git
	stub_buildkite_agent
	asset_dir=$(temp_make)
	bin_dir=$(temp_make)
	setup_curl_stub "${asset_dir}" "${bin_dir}"

	# act
	run env BUILDKITE_PLUGIN_OBLT_CLI_VERSION_FILE="${PWD}/non-existent" "$PWD/hooks/pre-command"

	# assert
	assert_failure
	assert_output --partial "+++ :x: version-file not found: /plugin/non-existent"

	# cleanup
	unstub git
	unstub buildkite-agent || true
	cleanup_curl_stub "${bin_dir}"
	temp_del "${asset_dir}"
	temp_del "${bin_dir}"
}
