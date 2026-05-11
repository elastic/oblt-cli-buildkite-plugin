#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"

export OBLT_CLI_BIN="${HOME}/.oblt-cli/bin"
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
		BUILDKITE_PLUGIN_OBLT_CLI_ORG="elastic" \
		BUILDKITE_PLUGIN_OBLT_CLI_DIVISION="engineering" \
		BUILDKITE_PLUGIN_OBLT_CLI_PROJECT="observability" \
		BUILDKITE_PLUGIN_OBLT_CLI_TEAM="my-team" \
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
		BUILDKITE_PLUGIN_OBLT_CLI_ORG="elastic" \
		BUILDKITE_PLUGIN_OBLT_CLI_DIVISION="engineering" \
		BUILDKITE_PLUGIN_OBLT_CLI_PROJECT="observability" \
		BUILDKITE_PLUGIN_OBLT_CLI_TEAM="my-team" \
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
	run env BUILDKITE_PLUGIN_OBLT_CLI_ORG="elastic" \
		BUILDKITE_PLUGIN_OBLT_CLI_DIVISION="engineering" \
		BUILDKITE_PLUGIN_OBLT_CLI_PROJECT="observability" \
		BUILDKITE_PLUGIN_OBLT_CLI_TEAM="my-team" \
		"$PWD/hooks/pre-command"

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
	run env BUILDKITE_PLUGIN_OBLT_CLI_VERSION_FILE="${PWD}/non-existent" \
		BUILDKITE_PLUGIN_OBLT_CLI_ORG="elastic" \
		BUILDKITE_PLUGIN_OBLT_CLI_DIVISION="engineering" \
		BUILDKITE_PLUGIN_OBLT_CLI_PROJECT="observability" \
		BUILDKITE_PLUGIN_OBLT_CLI_TEAM="my-team" \
		"$PWD/hooks/pre-command"

	# assert
	assert_failure
	assert_output --partial "version-file not found: /plugin/non-existent"

	# cleanup
	unstub git
}

@test "pre-command missing org should fail" {
	# act
	run env BUILDKITE_PLUGIN_OBLT_CLI_DIVISION="engineering" \
		BUILDKITE_PLUGIN_OBLT_CLI_PROJECT="observability" \
		BUILDKITE_PLUGIN_OBLT_CLI_TEAM="my-team" \
		"$PWD/hooks/pre-command"

	# assert
	assert_failure
	assert_output --partial "The 'org' plugin property is required."
}

@test "pre-command missing division should fail" {
	# act
	run env BUILDKITE_PLUGIN_OBLT_CLI_ORG="elastic" \
		BUILDKITE_PLUGIN_OBLT_CLI_PROJECT="observability" \
		BUILDKITE_PLUGIN_OBLT_CLI_TEAM="my-team" \
		"$PWD/hooks/pre-command"

	# assert
	assert_failure
	assert_output --partial "The 'division' plugin property is required."
}

@test "pre-command missing project should fail" {
	# act
	run env BUILDKITE_PLUGIN_OBLT_CLI_ORG="elastic" \
		BUILDKITE_PLUGIN_OBLT_CLI_DIVISION="engineering" \
		BUILDKITE_PLUGIN_OBLT_CLI_TEAM="my-team" \
		"$PWD/hooks/pre-command"

	# assert
	assert_failure
	assert_output --partial "The 'project' plugin property is required."
}

@test "pre-command missing team should fail" {
	# act
	run env BUILDKITE_PLUGIN_OBLT_CLI_ORG="elastic" \
		BUILDKITE_PLUGIN_OBLT_CLI_DIVISION="engineering" \
		BUILDKITE_PLUGIN_OBLT_CLI_PROJECT="observability" \
		"$PWD/hooks/pre-command"

	# assert
	assert_failure
	assert_output --partial "The 'team' plugin property is required."
}
