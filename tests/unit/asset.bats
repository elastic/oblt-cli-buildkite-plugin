#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"
load "$PWD/lib/asset"

@test "Get asset name should return asset name" {
	# arrange
	local version="7.3.0"

	# act
	run get_asset_name "${version}"

	# assert
	assert_success
	assert_output "oblt-cli_${version}_linux_amd64.tar.gz"
}

@test "Get asset name should fail with unsupported OS" {
	# arrange

	# act
	run get_asset_name 7.3.0 "Windows" "arm64"

	# assert
	assert_failure
	assert_output "Unsupported OS. Exiting."
}

@test "Get asset name should fail with unsupported architecture" {
	# arrange

	# act
	run get_asset_name "7.3.0" "Linux" "i386"

	# assert
	assert_failure
	assert_output "Unsupported architecture. Exiting."
}

@test "Get asset id should return asset id" {
	# arrange
	stub curl "cat $PWD/tests/fixtures/release.json"

	# act
	run get_asset_id "7.3.0" "fake-token"

	# assert
	assert_success
	assert_output "176068054"

	# cleanup
	unstub curl
}

@test "Download asset should download asset" {
	# arrange
	tmp_dir=$(temp_make)
	tar -czf "$tmp_dir/oblt-cli.tar.gz" --directory "$PWD/tests/fixtures" oblt-cli
	stub curl "cat $tmp_dir/oblt-cli.tar.gz"

	# act
	run download_asset "176068054" "$tmp_dir" "fake-token"

	# assert
	assert_success
	assert_file_exist "$tmp_dir/oblt-cli"

	# cleanup
	unstub curl
	temp_del "$tmp_dir"
}
