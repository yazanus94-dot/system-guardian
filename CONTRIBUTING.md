# Contributing to System Guardian

Thank you for your interest in contributing! This document outlines the process for contributing to the project.

## Development Setup

```bash
git clone https://github.com/yourusername/system-guardian
cd system-guardian
./scripts/setup.sh
```

## Running Tests

```bash
./scripts/run_tests.sh
```

## Code Style

- Use `set -euo pipefail` at the top of all scripts
- Use `local` for function-scoped variables
- Use `printf` instead of `echo` for portability
- Use `$(...)` instead of backticks
- Use `[[ ]]` for conditional tests
- Use `read -r` to avoid backslash mangling

## Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure all tests pass
5. Submit a pull request with a clear description

## Reporting Issues

Use the issue tracker with:
- Steps to reproduce
- Expected behavior
- Actual behavior
- Environment details (OS, bash version)