#!/usr/bin/env bash

set -euo pipefail

# Set up git credentials using G
# Arguments:
#  $1: username
# Returns:
#  None
function setup_git() {
	local -r username="${GIT_USER:-"$1"}"
	local -r email=${GIT_EMAIL:-"${username}@users.noreply.github.com"}

	git config --global user.name "${username}"
	git config --global user.email "${email}"

	git config --global credential.helper store
	echo "protocol=https
    host=github.com
    username=token
    password=$GH_TOKEN" | git credential-store store
}
