#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"
load "$PWD/lib/version"

@test "Get version from .tool-versions file should return version from file" {
	# arrange
	local tool_versions_file="$PWD/tests/fixtures/.tool-versions"

	# act
	run get_version_from_file "$tool_versions_file"

	# assert
	assert_success
	assert_output "7.2.5"
}

@test "Get version from any file should return version from file" {
	# arrange
	local version_file="$PWD/tests/fixtures/.oblt-cli-version"

	# act
	run get_version_from_file "$version_file"

	# assert
	assert_success
	assert_output "7.3.0"
}

@test "Get version from input or file should return input when both are provided" {
	# arrange
	local -r version_file="$PWD/tests/fixtures/.oblt-cli-version"
	stub buildkite-agent \
		"annotate \* --style=warning --context=ctx-version : >&2 echo 'warning'"

	# act
	run get_version_from_input_or_file "7.2.5" "$version_file"

	# assert
	assert_success
	assert_line --index 0 'warning'
	assert_line --index 1 "7.2.5"
}

@test "Get version from input or file should return version from file when input is empty" {
	# arrange
	local -r version_file="$PWD/tests/fixtures/.oblt-cli-version"

	# act
	run get_version_from_input_or_file "" "$version_file"

	# assert
	assert_success
	assert_output "7.3.0"
}

@test "Get version from input or or file should fail if file does not exist and when input is empty" {
	# arrange
	local -r version_file="$PWD/non_existent_file"

	# act
	run get_version_from_input_or_file "" "$version_file"

	# assert
	assert_failure
	assert_output "version-file not found: /plugin/non_existent_file"
}
