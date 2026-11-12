#!/usr/bin/env bash
# System Guardian - Test Runner
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SCRIPT_DIR"
echo "=== Running System Guardian Tests ==="
if command -v bats &>/dev/null; then
    bats tests/
else
    echo "Bats not installed. Installing..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y bats
    else
        echo "Please install bats: https://bats-core.readthedocs.io/"
        exit 1
    fi
    bats tests/
fi
echo "=== Tests Complete ==="