#!/usr/bin/env bash
# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x--------------------------------------------------------------------------x #

set -euo pipefail

REPO_ROOT=$(cd -- $(realpath "$( dirname -- "${BASH_SOURCE[0]}" )/..") &> /dev/null && pwd)
MANIFEST_PATH="${REPO_ROOT}/pixi.toml"
README_PATH="${REPO_ROOT}/README.md"

STABLE_CHANNEL=https://conda.modular.com/max
NIGHTLY_CHANNEL=https://conda.modular.com/max-nightly

# get the correct modular channel
if [ "$1" = "stable" ]; then
    CHANNEL=$STABLE_CHANNEL
    sed -i "s|\"${NIGHTLY_CHANNEL}\"|\"${CHANNEL}\"|" $MANIFEST_PATH
elif [ "$1" = "nightly" ]; then
    CHANNEL=$NIGHTLY_CHANNEL
    sed -i "s|\"${STABLE_CHANNEL}\"|\"${CHANNEL}\"|" $MANIFEST_PATH
else
    echo "use {stable|nightly}"
    return 1
fi

# get the version of mojo that the package currently uses
# TODO: consider unpinning the mojo version
OLD_MOJO_VERSION=$(grep -oPm1 "mojo = \"=*\K[^\"]+" $MANIFEST_PATH)

# get the latest version of mojo from the correct channel
NEW_MOJO_VERSION=$(pixi search mojo=0.* -c $CHANNEL | grep "Version" | head -1 )
NEW_MOJO_VERSION=${NEW_MOJO_VERSION##"Version"* }

# update mojo if a newer version exists
if [ "$OLD_MOJO_VERSION" = "$NEW_MOJO_VERSION" ]; then
    echo -e "no update"
    return 1
else
    sed -i "s:mojo = \".*\":mojo = \"==${NEW_MOJO_VERSION}\":" $MANIFEST_PATH
    sed -i "s:badge/mojo-.*-:badge/mojo-${NEW_MOJO_VERSION}-:" $README_PATH
    echo -e "mojo updated from ${OLD_MOJO_VERSION} to ${NEW_MOJO_VERSION}"
fi
