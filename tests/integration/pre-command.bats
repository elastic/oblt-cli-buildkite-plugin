#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"

# shellcheck source=/dev/null
. "$PWD/hooks/environment"

export VAULT_GITHUB_TOKEN=${GH_TOKEN:-${GITHUB_TOKEN:-$VAULT_GITHUB_TOKEN}}

stub_git() {
	stub git \
		"config --global user.name \* : echo 'git: Set user.name'" \
		"config --global user.email \* : echo 'git: Set user.email'"
}

@test "pre-command version from file" {
	# arrange
	stub_git

	# act
	run env BUILDKITE_PLUGIN_OBLT_CLI_VERSION_FILE="${PWD}/tests/fixtures/.oblt-cli-version" \
		"$PWD/hooks/pre-command"

	# assert
	assert_success
	assert_output --partial "~~~ :elastic-apm: Set up oblt-cli 7.2.2"
	assert_output --partial "Writing configuration file /home/plugin-tester/.oblt-cli/config.yaml"

	# cleanup
	unstub git
}

@test "pre-command version from input" {
	# arrange
	stub_git

	# act
	run env BUILDKITE_PLUGIN_OBLT_CLI_VERSION="7.2.5" \
		"$PWD/hooks/pre-command"

	# assert
	assert_success
	assert_output --partial "~~~ :elastic-apm: Set up oblt-cli 7.2.5"
	assert_output --partial "Writing configuration file /home/plugin-tester/.oblt-cli/config.yaml"

	# cleanup
	unstub git
}

@test "pre-command default version" {
	# arrange
	stub_git

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
	# arrange
	stub_git

	# act
	run env BUILDKITE_PLUGIN_OBLT_CLI_VERSION_FILE="${PWD}/non-existent" "$PWD/hooks/pre-command"

	# assert
	assert_failure
	assert_output --partial "version-file not found: /plugin/non-existent"

	# cleanup
	unstub git
}
