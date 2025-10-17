#!/usr/bin/env bash
# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x--------------------------------------------------------------------------x #

set -euo pipefail

REPO_NAME="blade"

REPO_ROOT=$(cd -- $(realpath "$( dirname -- "${BASH_SOURCE[0]}" )/..") &> /dev/null && pwd)
BUILD_DIR="${REPO_ROOT}/test"
SRC_DIR="${REPO_ROOT}/src"

PACKAGE_NAME=${REPO_NAME}".mojopkg"
PACKAGE_PATH=${BUILD_DIR}"/"${PACKAGE_NAME}

echo "╓───  Packaging "${REPO_NAME}
mojo package "${SRC_DIR}" -o "${PACKAGE_PATH}"
echo Successfully created "${PACKAGE_PATH}"
