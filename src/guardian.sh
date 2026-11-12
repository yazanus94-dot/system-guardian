#!/usr/bin/env bash
# System Guardian - Core Monitoring Engine
# Real-time resource monitoring with threshold-based alerting
set -euo pipefail

GUARDIAN_VERSION="1.0.0"
CONFIG_FILE="${GUARDIAN_CONFIG:-/etc/guardian/config.json}"
LOG_FILE="${GUARDIAN_LOG:-/var/log/guardian/guardian.log}"
STATE_DIR="${GUARDIAN_STATE:-/var/lib/guardian}"

# --- Logging ---
log() {
    local level="$1"; shift
    local msg="$*"
    local ts
    ts=$(date '+%Y-%m-%dT%H:%M:%S%z')
    printf '[%s] [%s] %s\n' "$ts" "$level" "$msg" | tee -a "$LOG_FILE"
}

# --- Resource Collectors ---
collect_cpu() {
    local idle total used
    read -r _ _ _ _ _ _ idle _ < <(top -bn1 | grep 'Cpu(s)')
    idle=$(echo "$idle" | cut -d' ' -f1 | tr -d '%')
    used=$(awk "BEGIN {printf \"%.1f\", 100 - $idle}")
    echo "$used"
}

collect_memory() {
    local total available used percent
    total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    used=$((total - available))
    percent=$(awk "BEGIN {printf \"%.1f\", ($used / $total) * 100}")
    echo "$percent"
}

collect_disk() {
    local mount usage_percent
    mount="$1"
    usage_percent=$(df -h "$mount" | tail -1 | awk '{print $5}' | tr -d '%')
    echo "$usage_percent"
}

collect_load() {
    awk '{print $1}' /proc/loadavg
}

# --- Analyzer ---
analyze() {
    local cpu mem disk load
    cpu="$1"; mem="$2"; disk="$3"; load="$4"
    local alerts=()

    if (( $(echo "$cpu > 90" | bc -l) )); then
        alerts+=("CRITICAL: CPU usage at ${cpu}%")
    elif (( $(echo "$cpu > 75" | bc -l) )); then
        alerts+=("WARNING: CPU usage at ${cpu}%")
    fi

    if (( $(echo "$mem > 85" | bc -l) )); then
        alerts+=("CRITICAL: Memory usage at ${mem}%")
    elif (( $(echo "$mem > 70" | bc -l) )); then
        alerts+=("WARNING: Memory usage at ${mem}%")
    fi

    if (( disk > 90 )); then
        alerts+=("CRITICAL: Disk usage at ${disk}% on ${MOUNT:-/}")
    fi

    if (( $(echo "$load > $(nproc)" | bc -l) )); then
        alerts+=("WARNING: Load average ${load} exceeds core count $(nproc)")
    fi

    printf '%s\n' "${alerts[@]:-}"
}

# --- Reporter ---
report_json() {
    local cpu mem disk load alerts ts
    cpu="$1"; mem="$2"; disk="$3"; load="$4"
    alerts="$5"
    ts=$(date '+%Y-%m-%dT%H:%M:%S%z')

    printf '{'
    printf '"timestamp":"%s",' "$ts"
    printf '"cpu_usage":%s,' "$cpu"
    printf '"memory_usage":%s,' "$mem"
    printf '"disk_usage":%s,' "$disk"
    printf '"load_average":%s,' "$load"
    printf '"alerts":['
    local first=1
    IFS=$'\n'
    for alert in $alerts; do
        [[ -z "$alert" ]] && continue
        [[ $first -eq 0 ]] && printf ','
        printf '"%s"' "$alert"
        first=0
    done
    unset IFS
    printf ']}\n'
}

# --- Main Scan ---
scan() {
    local mount="${MOUNT:-/}"
    log INFO "Starting system scan"
    local cpu mem disk load alerts
    cpu=$(collect_cpu)
    mem=$(collect_memory)
    disk=$(collect_disk "$mount")
    load=$(collect_load)
    alerts=$(analyze "$cpu" "$mem" "$disk" "$load")

    local report
    report=$(report_json "$cpu" "$mem" "$disk" "$load" "$alerts")
    printf '%s\n' "$report"

    if [[ -n "$alerts" ]]; then
        log WARN "Alerts detected: ${alerts}"
    else
        log INFO "All systems nominal"
    fi
}

# --- Daemon ---
daemon() {
    local interval="${1:-30}"
    log INFO "Starting guardian daemon (interval=${interval}s)"
    while true; do
        scan
        sleep "$interval"
    done
}

# --- CLI ---
case "${1:-}" in
    scan) scan ;;
    daemon) daemon "${2:-30}" ;;
    version) echo "System Guardian v${GUARDIAN_VERSION}" ;;
    *) echo "Usage: $0 {scan|daemon|version}" >&2; exit 1 ;;
esac