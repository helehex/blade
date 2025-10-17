#!/usr/bin/env bash
# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #

set -euo pipefail

REPO_ROOT=$(cd -- $(realpath "$( dirname -- "${BASH_SOURCE[0]}" )/..") &> /dev/null && pwd)
MANIFEST_PATH="${REPO_ROOT}/mojoproject.toml"
README_PATH="${REPO_ROOT}/README.md"

OLD_MAX_VERSION=$(grep "max =" ${MANIFEST_PATH})
OLD_MAX_VERSION=${OLD_MAX_VERSION%%'"'}
OLD_MAX_VERSION=${OLD_MAX_VERSION##'max = "=='}

NEW_MAX_VERSION=$(magic search max | grep "Version")
NEW_MAX_VERSION=${NEW_MAX_VERSION##"Version"* }

if [ "$OLD_MAX_VERSION" = "$NEW_MAX_VERSION" ]; then
    echo -e "no update"
    return 1
else
    magic add "max==${NEW_MAX_VERSION}"
    sed -i "s/Mojo version: \`.*\`/Mojo version: \`${NEW_MAX_VERSION}\`/" ${README_PATH}
    echo -e "version bumped"
fi
