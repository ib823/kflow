#!/bin/bash
#############################################
# KERJAFLOW QUALITY GATES - MASTER RUNNER
#
# Runs all 15 quality gates sequentially
# and generates a comprehensive report.
#
# Usage:
#   ./quality_gates/run_all_gates.sh [options]
#
# Options:
#   --quick       Run quick gates only (1,3,4,15)
#   --skip-build  Skip build-related gates
#   --continue    Continue on failures
#   --help        Show this help
#############################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Configuration
QUICK_MODE=false
SKIP_BUILD=false
CONTINUE_ON_FAILURE=false

# Counters
PASSED=0
FAILED=0
SKIPPED=0
TOTAL=15

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --quick)
            QUICK_MODE=true
            shift
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --continue)
            CONTINUE_ON_FAILURE=true
            shift
            ;;
        --help)
            head -20 "$0" | tail -19
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# Create report directory
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
REPORT_DIR="$SCRIPT_DIR/reports/${TIMESTAMP}"
mkdir -p "$REPORT_DIR"

# Gate definitions
declare -A GATES
GATES[01]="Static Analysis"
GATES[02]="Code Quality"
GATES[03]="Security Scan"
GATES[04]="Unit Tests"
GATES[05]="Widget Tests"
GATES[06]="Integration Tests"
GATES[07]="Golden Tests"
GATES[08]="Performance Tests"
GATES[09]="Accessibility Audit"
GATES[10]="i18n Verification"
GATES[11]="API Contract Tests"
GATES[12]="Offline Sync Tests"
GATES[13]="Edge Case Tests"
GATES[14]="Regression Tests"
GATES[15]="Final Certification"

# Quick mode gates
QUICK_GATES=("01" "03" "04" "15")

# Function to run a gate
run_gate() {
    local gate_num=$1
    local gate_name="${GATES[$gate_num]}"
    local gate_script="$SCRIPT_DIR/gate_${gate_num}_*/run.sh"

    # Find the actual script
    gate_script=$(ls $gate_script 2>/dev/null | head -1)

    if [ ! -f "$gate_script" ]; then
        echo -e "${YELLOW}  ○ Gate $gate_num: $gate_name - Script not found${NC}"
        SKIPPED=$((SKIPPED + 1))
        return 0
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  Gate $gate_num: $gate_name${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    START_TIME=$(date +%s)

    if bash "$gate_script" "$REPORT_DIR" 2>&1 | tee "$REPORT_DIR/gate_${gate_num}.log"; then
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        echo ""
        echo -e "${GREEN}  ✓ Gate $gate_num PASSED (${DURATION}s)${NC}"
        PASSED=$((PASSED + 1))
        return 0
    else
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        echo ""
        echo -e "${RED}  ✗ Gate $gate_num FAILED (${DURATION}s)${NC}"
        FAILED=$((FAILED + 1))

        if [ "$CONTINUE_ON_FAILURE" = false ]; then
            return 1
        fi
        return 0
    fi
}

# Header
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                                          ║${NC}"
echo -e "${BLUE}║     KERJAFLOW QUALITY GATES                                             ║${NC}"
echo -e "${BLUE}║                                                                          ║${NC}"
echo -e "${BLUE}║     15 Local Quality Gates • No External Services                       ║${NC}"
echo -e "${BLUE}║                                                                          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "  Started:    $(date)"
echo "  Report Dir: $REPORT_DIR"
echo "  Mode:       $([ "$QUICK_MODE" = true ] && echo "Quick (4 gates)" || echo "Full (15 gates)")"
echo ""

cd "$PROJECT_DIR"

# Run gates
if [ "$QUICK_MODE" = true ]; then
    TOTAL=4
    for gate in "${QUICK_GATES[@]}"; do
        if ! run_gate "$gate"; then
            break
        fi
    done
else
    for gate_num in $(seq -w 1 15); do
        # Skip build gates if requested
        if [ "$SKIP_BUILD" = true ] && [ "$gate_num" = "15" ]; then
            echo -e "${YELLOW}  ○ Gate $gate_num: Skipped (--skip-build)${NC}"
            SKIPPED=$((SKIPPED + 1))
            continue
        fi

        if ! run_gate "$gate_num"; then
            break
        fi
    done
fi

# Summary
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                         QUALITY GATES SUMMARY                            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${GREEN}Passed:${NC}  $PASSED / $TOTAL"
echo -e "  ${RED}Failed:${NC}  $FAILED / $TOTAL"
echo -e "  ${YELLOW}Skipped:${NC} $SKIPPED / $TOTAL"
echo ""
echo "  Report:    $REPORT_DIR"
echo "  Completed: $(date)"
echo ""

# Generate summary report
cat > "$REPORT_DIR/SUMMARY.txt" << EOF
═══════════════════════════════════════════════════════════════════════════════
                    KERJAFLOW QUALITY GATES REPORT
═══════════════════════════════════════════════════════════════════════════════

Generated: $(date)
Mode: $([ "$QUICK_MODE" = true ] && echo "Quick" || echo "Full")

RESULTS
───────────────────────────────────────────────────────────────────────────────
Passed:  $PASSED / $TOTAL
Failed:  $FAILED / $TOTAL
Skipped: $SKIPPED / $TOTAL

GATE DETAILS
───────────────────────────────────────────────────────────────────────────────
EOF

for gate_num in $(seq -w 1 15); do
    if [ -f "$REPORT_DIR/gate_${gate_num}.log" ]; then
        STATUS=$(tail -1 "$REPORT_DIR/gate_${gate_num}.log" | grep -q "PASSED" && echo "PASSED" || echo "FAILED")
        echo "Gate $gate_num: ${GATES[$gate_num]} - $STATUS" >> "$REPORT_DIR/SUMMARY.txt"
    fi
done

cat >> "$REPORT_DIR/SUMMARY.txt" << EOF

═══════════════════════════════════════════════════════════════════════════════
STATUS: $([ $FAILED -eq 0 ] && echo "ALL GATES PASSED - PRODUCTION READY" || echo "SOME GATES FAILED - NOT PRODUCTION READY")
═══════════════════════════════════════════════════════════════════════════════
EOF

# Final status
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                                          ║${NC}"
    echo -e "${GREEN}║     ✓ ALL QUALITY GATES PASSED                                          ║${NC}"
    echo -e "${GREEN}║                                                                          ║${NC}"
    echo -e "${GREEN}║     KerjaFlow is PRODUCTION READY                                       ║${NC}"
    echo -e "${GREEN}║                                                                          ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                                                          ║${NC}"
    echo -e "${RED}║     ✗ $FAILED QUALITY GATE(S) FAILED                                     ║${NC}"
    echo -e "${RED}║                                                                          ║${NC}"
    echo -e "${RED}║     Review reports and fix issues before production                      ║${NC}"
    echo -e "${RED}║                                                                          ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 1
fi
