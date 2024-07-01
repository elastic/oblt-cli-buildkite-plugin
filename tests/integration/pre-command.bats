#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"

@test "pre-command version from file" {
	# arrange
	local tmp_dir
	local gh_token=${GH_TOKEN:-${GITHUB_TOKEN}}

	if [[ -z ${gh_token} ]]; then
		tmp_dir=$(temp_make)
		tar -czf "$tmp_dir/oblt-cli.tar.gz" --directory "$PWD/tests/fixtures" oblt-cli
		version=$(jq -r '.tag_name' "$PWD/tests/fixtures/release.json")
		asset_id=$(jq -r '.assets | .[] | select(.name == "oblt-cli_7.3.0_linux_amd64.tar.gz") | .id' "$PWD/tests/fixtures/release.json")
		echo "$asset_id"
		stub curl \
			"-sL -H \* -H \* -H \* https://api.github.com/repos/elastic/observability-test-environments/releases/tags/${version} : cat $PWD/tests/fixtures/release.json" \
			"-sL -H \* -H \* -H \* https://api.github.com/repos/elastic/observability-test-environments/releases/assets/${asset_id} : cat $tmp_dir/oblt-cli.tar.gz"
	fi
	# act
	run env BUILDKITE_PLUGIN_OBLT_CLI_USERNAME="obltmachine" \
		BUILDKITE_PLUGIN_OBLT_CLI_SLACK_CHANNEL="#observablt-bots" \
		BUILDKITE_PLUGIN_OBLT_CLI_VERSION="" \
		BUILDKITE_PLUGIN_OBLT_CLI_VERSION_FILE="${PWD}/tests/fixtures/.oblt-cli-version" \
		BUILDKITE_PLUGIN_OBLT_CLI_GITHUB_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN}}" \
		"$PWD/hooks/pre-command"

	# assert
	assert_success
	if [[ -z ${gh_token} ]]; then
		assert_output --partial "~~~ :elastic-apm: Set up oblt-cli 7.3.0"
		assert_output --partial "mocked oblt-cli output"
	else
		assert_output --partial "~~~ :elastic-apm: Set up oblt-cli 7.3.0"
		assert_output --partial "Writing configuration file /home/plugin-tester/.oblt-cli/config.yaml"
	fi
	# cleanup
	if [[ -z ${gh_token} ]]; then
		unstub curl
		temp_del "$tmp_dir"
	fi
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
	# act
	run env BUILDKITE_PLUGIN_OBLT_CLI_USERNAME="obltmachine" \
		BUILDKITE_PLUGIN_OBLT_CLI_SLACK_CHANNEL="#observablt-bots" \
		BUILDKITE_PLUGIN_OBLT_CLI_VERSION="${version}" \
		BUILDKITE_PLUGIN_OBLT_CLI_VERSION_FILE="" \
		BUILDKITE_PLUGIN_OBLT_CLI_GITHUB_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN}}" \
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
}
