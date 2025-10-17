#!/usr/bin/env bash
# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x--------------------------------------------------------------------------x #

set -euo pipefail

REPO_ROOT=$(cd -- $(realpath "$( dirname -- "${BASH_SOURCE[0]}" )/..") &> /dev/null && pwd)
MANIFEST_PATH="${REPO_ROOT}/pixi.toml"
README_PATH="${REPO_ROOT}/README.md"

# get the correct modular channel
if [ "$1" = "stable" ]; then
    CHANNEL=https://conda.modular.com/max
elif [ "$1" = "nightly" ]; then
    CHANNEL=https://conda.modular.com/max-nightly
else
    echo "use {stable|nightly}"
    return 1
fi

# get the version of max that the package currently uses
# TODO: consider unpinning the mojo version
OLD_MAX_VERSION=$(grep "mojo =" $MANIFEST_PATH)
OLD_MAX_VERSION=${OLD_MAX_VERSION%%'"'}
OLD_MAX_VERSION=${OLD_MAX_VERSION##'max = "=='}

# get the latest version of max from the correct channel
NEW_MAX_VERSION=$(pixi search max -c $CHANNEL | grep "Version" | head -1 )
NEW_MAX_VERSION=${NEW_MAX_VERSION##"Version"* }

# update max if a newer version exists
if [ "$OLD_MAX_VERSION" = "$NEW_MAX_VERSION" ]; then
    echo -e "no update"
    return 1
else
    pixi add "max==${NEW_MAX_VERSION}"
    sed -i "s:badge/mojo-.*-:badge/mojo-${NEW_MAX_VERSION}-:" $README_PATH
    echo -e "max updated to ${NEW_MAX_VERSION}"
fi
