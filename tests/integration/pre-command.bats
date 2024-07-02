#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"

export OBLT_CLI_BIN="${HOME}/.oblt-cli/bin"

@test "pre-command version from file" {
	# arrange
	local tmp_dir
	local gh_token=${GH_TOKEN:-${GITHUB_TOKEN}}

	if [[ -z ${gh_token} ]]; then
		tmp_dir=$(temp_make)
		tar -czf "$tmp_dir/oblt-cli.tar.gz" --directory "$PWD/tests/fixtures" oblt-cli
		version="${PWD}/tests/fixtures/.oblt-cli-version"
		asset_id=$(jq -r '.assets | .[] | select(.name == "oblt-cli_7.3.0_linux_amd64.tar.gz") | .id' "$PWD/tests/fixtures/release.json")
		echo "$asset_id"
		stub curl \
			"cat $PWD/tests/fixtures/release.json" \
			"cat $tmp_dir/oblt-cli.tar.gz"
	fi

	stub git \
		"config --global user.name \* : echo 'Setup git user.name'" \
		"config --global user.email \* : echo 'Setup git user.email'"

	# act
	run env BUILDKITE_PLUGIN_OBLT_CLI_VERSION_FILE="${PWD}/tests/fixtures/.oblt-cli-version" \
		"$PWD/hooks/pre-command"

	# assert
	assert_success
	if [[ -z ${gh_token} ]]; then
		assert_output --partial "~~~ :elastic-apm: Set up oblt-cli 7.2.2"
		assert_output --partial "mocked oblt-cli output"
	else
		assert_output --partial "~~~ :elastic-apm: Set up oblt-cli 7.2.2"
		assert_output --partial "Writing configuration file /home/plugin-tester/.oblt-cli/config.yaml"
	fi
	# cleanup
	if [[ -z ${gh_token} ]]; then
		unstub curl
		temp_del "$tmp_dir"
	fi
	unstub git
}

@test "pre-command version from input" {
	# arrange
	local tmp_dir
	local gh_token=${GH_TOKEN:-${GITHUB_TOKEN}}
	local version
	if [[ -z ${gh_token} ]]; then
		tmp_dir=$(temp_make)
		tar -czf "$tmp_dir/oblt-cli.tar.gz" --directory "$PWD/tests/fixtures" oblt-cli
		version=$(jq -r '.tag_name' "$PWD/tests/fixtures/release.json")
		asset_id=$(jq -r '.assets | .[] | select(.name == "oblt-cli_7.3.0_linux_amd64.tar.gz") | .id' "$PWD/tests/fixtures/release.json")
		echo "$asset_id"
		stub curl \
			"-sL -H \* -H \* -H \* https://api.github.com/repos/elastic/observability-test-environments/releases/tags/${version} : cat $PWD/tests/fixtures/release.json" \
			"-sL -H \* -H \* -H \* https://api.github.com/repos/elastic/observability-test-environments/releases/assets/${asset_id} : cat $tmp_dir/oblt-cli.tar.gz"
	else
		version="7.2.5"
	fi
	stub git \
		"config --global user.name \* : echo 'Setup git user.name'" \
		"config --global user.email \* : echo 'Setup git user.email'"

	# act
	run env BUILDKITE_PLUGIN_OBLT_CLI_VERSION="${version}" \
		"$PWD/hooks/pre-command"

	# assert
	assert_success

	if [[ -z ${gh_token} ]]; then
		assert_output --partial "~~~ :elastic-apm: Set up oblt-cli 7.3.0"
		assert_output --partial "mocked oblt-cli output"
	else
		assert_output --partial "~~~ :elastic-apm: Set up oblt-cli 7.2.5"
		assert_output --partial "Writing configuration file /home/plugin-tester/.oblt-cli/config.yaml"
	fi

	# cleanup
	if [[ -z ${gh_token} ]]; then
		unstub curl
		temp_del "$tmp_dir"
	fi
	unstub git
}

@test "pre-command default version" {
	local gh_token=${GH_TOKEN:-${GITHUB_TOKEN}}
	if [[ -z ${gh_token} ]]; then
		skip
	fi
	# arrange
	stub git \
		"config --global user.name \* : echo 'Setup git user.name'" \
		"config --global user.email \* : echo 'Setup git user.email'"

	# act
	run "$PWD/hooks/pre-command"

	# assert
	version=$(cat "${PWD}/.default-oblt-cli-version")
	assert_success
	assert_output --partial "~~~ :elastic-apm: Set up oblt-cli ${version}"
	assert_output --partial "Writing configuration file /home/plugin-tester/.oblt-cli/config.yaml"

	# cleanup
	unstub git
}

@test "pre-command non-existent version file should fail" {
	local gh_token=${GH_TOKEN:-${GITHUB_TOKEN}}
	if [[ -z ${gh_token} ]]; then
		skip
	fi

	# arrange

	# act
	run env BUILDKITE_PLUGIN_OBLT_CLI_VERSION_FILE="${PWD}/non-existent" "$PWD/hooks/pre-command"

	# assert
	assert_failure
	assert_output "version-file not found: /plugin/non-existent"
}
