#!/usr/bin/env bash
# System Guardian - Test Suite
# Uses Bats for behavior-driven testing
setup() {
    load 'bats/assert/load'
    load 'bats/support/load'
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    SOURCE_FILE="${SCRIPT_DIR}/../src/guardian.sh"
    export GUARDIAN_LOG="/tmp/guardian-test.log"
    export GUARDIAN_CONFIG="/tmp/guardian-test-config.json"
    export GUARDIAN_STATE="/tmp/guardian-test-state"
    mkdir -p "$GUARDIAN_STATE"
    # Source the script functions only (not run main)
    source "$SOURCE_FILE" --source-only 2>/dev/null || true
}

teardown() {
    rm -rf "$GUARDIAN_STATE" "$GUARDIAN_LOG" 2>/dev/null || true
}

@test "collect_memory returns a numeric percentage" {
    result=$(collect_memory)
    [[ "$result" =~ ^[0-9]+(\.[0-9]+)?$ ]]
}

@test "collect_load returns a numeric value" {
    result=$(collect_load)
    [[ "$result" =~ ^[0-9]+(\.[0-9]+)?$ ]]
}

@test "analyze flags critical CPU above 90" {
    result=$(analyze "95" "50" "50" "1.0")
    [[ "$result" == *"CRITICAL: CPU"* ]]
}

@test "analyze flags warning CPU above 75" {
    result=$(analyze "80" "50" "50" "1.0")
    [[ "$result" == *"WARNING: CPU"* ]]
}

@test "analyze flags critical memory above 85" {
    result=$(analyze "50" "90" "50" "1.0")
    [[ "$result" == *"CRITICAL: Memory"* ]]
}

@test "analyze flags critical disk above 90" {
    result=$(analyze "50" "50" "95" "1.0")
    [[ "$result" == *"CRITICAL: Disk"* ]]
}

@test "analyze returns empty when all metrics nominal" {
    result=$(analyze "30" "40" "50" "0.5")
    [[ -z "$result" ]]
}

@test "report_json produces valid JSON structure" {
    result=$(report_json "50" "60" "70" "1.5" "")
    [[ "$result" == '{"timestamp":'* ]]
    [[ "$result" == *'"cpu_usage":50'* ]]
    [[ "$result" == *'"memory_usage":60'* ]]
    [[ "$result" == *'"disk_usage":70'* ]]
    [[ "$result" == *'"load_average":1.5'* ]]
    [[ "$result" == *'"alerts":[]'} ]]
}

@test "report_json includes alerts when present" {
    result=$(report_json "95" "50" "50" "1.0" $'CRITICAL: CPU usage at 95%')
    [[ "$result" == *'"alerts":['* ]]
    [[ "$result" == *'CRITICAL: CPU'* ]]
}

@test "version flag outputs version string" {
    run bash "$SOURCE_FILE" version
    [[ "$status" -eq 0 ]]
    [[ "$output" == "System Guardian v1.0.0" ]]
}

@test "invalid command returns error" {
    run bash "$SOURCE_FILE" invalid_cmd
    [[ "$status" -ne 0 ]]
}

@test "scan produces JSON output" {
    run bash "$SOURCE_FILE" scan
    [[ "$status" -eq 0 ]]
    [[ "$output" == '{"timestamp":'* ]]
}