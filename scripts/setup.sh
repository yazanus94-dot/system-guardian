#!/usr/bin/env bash
# System Guardian - Setup Script
# Installs dependencies and configures the environment
set -euo pipefail

echo "=== System Guardian Setup ==="

# Check for required tools
check_tool() {
    if ! command -v "$1" &>/dev/null; then
        echo "ERROR: Required tool '$1' not found" >&2
        exit 1
    fi
}

check_tool "bash"
check_tool "awk"
check_tool "bc"
check_tool "df"
check_tool "top"

# Create directories
INSTALL_PREFIX="${GUARDIAN_PREFIX:-/usr/local}"
BIN_DIR="${INSTALL_PREFIX}/bin"
CONF_DIR="${INSTALL_PREFIX}/etc/guardian"
LOG_DIR="${INSTALL_PREFIX}/var/log/guardian"
STATE_DIR="${INSTALL_PREFIX}/var/lib/guardian"

echo "Creating directories..."
mkdir -p "$BIN_DIR" "$CONF_DIR" "$LOG_DIR" "$STATE_DIR"

# Copy scripts
echo "Installing guardian.sh to ${BIN_DIR}..."
cp "$(dirname "$0")/../src/guardian.sh" "$BIN_DIR/guardian"
chmod +x "$BIN_DIR/guardian"

# Create default config
if [[ ! -f "$CONF_DIR/config.json" ]]; then
    cat > "$CONF_DIR/config.json" <<'EOF'
{
    "version": "1.0.0",
    "thresholds": {
        "cpu_warning": 75,
        "cpu_critical": 90,
        "memory_warning": 70,
        "memory_critical": 85,
        "disk_warning": 80,
        "disk_critical": 90
    },
    "interval": 30,
    "notifications": {
        "slack": null,
        "discord": null,
        "smtp": null
    }
}
EOF
    echo "Default config created at ${CONF_DIR}/config.json"
fi

# Create logrotate config
cat > /etc/logrotate.d/guardian <<EOF
${LOG_DIR}/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}
EOF

echo "=== Setup Complete ==="
echo "Run: guardian scan"
echo "Run: guardian daemon 60"