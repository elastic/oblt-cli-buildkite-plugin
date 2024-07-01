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

@test "Get version from or fallback should return version from file" {
	# arrange
	local -r version_file="$PWD/tests/fixtures/.oblt-cli-version"

	# act
	run get_version_from_file_or_fallback "$version_file" "7.2.5"

	# assert
	assert_success
	assert_output "7.3.0"
}

@test "Get version from input or fallback should return fallback" {
	# arrange
	local -r version_file="$PWD/non_existent_file"

	# act
	run get_version_from_file_or_fallback "$version_file" "7.2.5"

	# assert
	assert_success
	assert_output "7.2.5"
}
