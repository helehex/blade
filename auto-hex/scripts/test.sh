#!/usr/bin/env bash
# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #

set -euo pipefail

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
UNCOLOR='\033[0m'

REPO_ROOT=$(cd -- $(realpath "$( dirname -- "${BASH_SOURCE[0]}" )/..") &> /dev/null && pwd)
TEST_DIR="${REPO_ROOT}/test"
FAILED_COUNT=0

for test in ${TEST_DIR}/test_*.mojo; do
    echo -e "\n╓─── Testing: $(basename $test)"
    if mojo $test; then
        echo -e ${GREEN}╙─── Test Successful!${UNCOLOR}
    else
        ((FAILED_COUNT+=1))
        echo -e ${RED}╙─── Test Failed!${UNCOLOR}
    fi
done

echo

if [ "$FAILED_COUNT" -eq 0 ]; then
    echo -e "${GREEN}───╖\n   ║ All Successful!\n───╜${UNCOLOR}"
else
    echo -e "${RED}───╖\n   ║ ${FAILED_COUNT} Failed!\n───╜${UNCOLOR}"
    exit 1
fi
