#!/bin/bash
#############################################
# KERJAFLOW QUICK CHECK
#
# Runs essential gates only for fast feedback:
# - Gate 01: Static Analysis
# - Gate 03: Security Scan
# - Gate 04: Unit Tests
# - Gate 15: Final Certification
#
# Use this for pre-commit checks or quick validation.
#############################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  KERJAFLOW QUICK CHECK                                       ║"
echo "║  Running Gates: 01, 03, 04, 15                               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

exec "$SCRIPT_DIR/run_all_gates.sh" --quick "$@"
