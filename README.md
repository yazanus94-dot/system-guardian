# System Guardian

A professional system monitoring and alerting toolkit with real-time resource tracking, threshold-based alerting, and multi-format reporting.

![Bash](https://img.shields.io/badge/Bash-5.1-blue)
![Testing](https://img.shields.io/badge/Tests-Bats-green)
![License](https://img.shields.io/badge/License-MIT-green)

## Overview

System Guardian is a production-grade shell toolkit that monitors CPU, memory, disk, network, and process health in real-time. It provides configurable alert thresholds, JSON and CSV export, log rotation, and integration with external notification services (Slack, Discord, Email). Designed for Linux server environments, it runs as a daemon or on-demand scanner.

## Key Features

- Real-time resource monitoring (CPU, memory, disk, network, I/O)
- Configurable alert thresholds with severity levels
- Multi-format output (JSON, CSV, syslog)
- External notification integration (Slack, Discord, SMTP)
- Log rotation and compression
- Process health tracking with automatic restart recommendations
- systemd service integration
- Bash strict mode (`set -euo pipefail`)

## Architecture

The system follows a modular pipeline design:

```
Config → Collector → Analyzer → Reporter → Notifier
```

Each stage is independently testable and can be extended with custom plugins.

## Installation

```bash
git clone https://github.com/yourusername/system-guardian
cd system-guardian
chmod +x scripts/*.sh
./scripts/setup.sh
```

## Usage

```bash
# One-time scan
./src/guardian.sh scan

# Daemon mode (continuous monitoring)
./src/guardian.sh daemon --interval 30

# Check specific resources
./src/guardian.sh check --cpu --memory --disk
```

## Testing

```bash
bats tests/
```

## License

MIT