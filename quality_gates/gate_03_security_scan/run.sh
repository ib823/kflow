#!/bin/bash
#############################################
# GATE 03: SECURITY SCAN
#
# Checks:
# - Hardcoded secrets detection
# - API key exposure
# - Password in code
# - SQL injection patterns
# - XSS vulnerabilities
# - Bandit (Python security)
# - Dependency vulnerabilities
#############################################

set -e

REPORT_DIR="${1:-.}"
GATE_NAME="Gate 03: Security Scan"
ERRORS=0
WARNINGS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  $GATE_NAME                                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"

cd /workspaces/kflow

# Hardcoded secrets detection
echo ""
echo "▶ Hardcoded Secrets Detection"
echo "───────────────────────────────────────────────────────────────"

# Check for API keys
API_KEY_MATCHES=$(grep -rE "(api[_-]?key|apikey)\s*[:=]\s*['\"][^'\"]{10,}" mobile/lib backend --include="*.dart" --include="*.py" 2>/dev/null | grep -v "YOUR_" | grep -v "test" | grep -v "#" || true)
if [ -n "$API_KEY_MATCHES" ]; then
    echo "  ✗ Potential API keys found:"
    echo "$API_KEY_MATCHES" | head -5
    ERRORS=$((ERRORS + 1))
else
    echo "  ✓ No hardcoded API keys detected"
fi

# Check for passwords
PASSWORD_MATCHES=$(grep -rE "password\s*[:=]\s*['\"][^'\"]{3,}" mobile/lib backend --include="*.dart" --include="*.py" 2>/dev/null | grep -vi "password.*field\|passwordcontroller\|password.*hint\|password.*label\|password.*validator" || true)
if [ -n "$PASSWORD_MATCHES" ]; then
    echo "  ⚠ Potential hardcoded passwords:"
    echo "$PASSWORD_MATCHES" | head -5
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✓ No hardcoded passwords detected"
fi

# Check for private keys
PRIVATE_KEY_MATCHES=$(grep -rE "(private[_-]?key|secret[_-]?key)\s*[:=]\s*['\"]" mobile/lib backend --include="*.dart" --include="*.py" 2>/dev/null | grep -v "YOUR_\|example\|test" || true)
if [ -n "$PRIVATE_KEY_MATCHES" ]; then
    echo "  ✗ Potential private keys found:"
    echo "$PRIVATE_KEY_MATCHES" | head -5
    ERRORS=$((ERRORS + 1))
else
    echo "  ✓ No hardcoded private keys detected"
fi

# Check for JWT secrets
JWT_MATCHES=$(grep -rE "jwt[_-]?secret\s*[:=]\s*['\"]" mobile/lib backend --include="*.dart" --include="*.py" 2>/dev/null | grep -v "env\|config\|YOUR_" || true)
if [ -n "$JWT_MATCHES" ]; then
    echo "  ✗ Potential JWT secrets found"
    ERRORS=$((ERRORS + 1))
else
    echo "  ✓ No hardcoded JWT secrets detected"
fi

# SQL Injection patterns
echo ""
echo "▶ SQL Injection Detection"
echo "───────────────────────────────────────────────────────────────"

SQL_CONCAT=$(grep -rE "execute.*\+.*\"|query.*\+.*\"|\"\s*\+\s*.*\+\s*\".*SELECT|INSERT|UPDATE|DELETE" backend --include="*.py" 2>/dev/null || true)
if [ -n "$SQL_CONCAT" ]; then
    echo "  ⚠ Potential SQL string concatenation found"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✓ No obvious SQL injection patterns"
fi

# XSS patterns
echo ""
echo "▶ XSS Vulnerability Detection"
echo "───────────────────────────────────────────────────────────────"

INNERHTML=$(grep -rE "innerHTML\s*=" mobile/lib --include="*.dart" 2>/dev/null || true)
if [ -n "$INNERHTML" ]; then
    echo "  ⚠ innerHTML usage detected - verify sanitization"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✓ No innerHTML usage detected"
fi

# Bandit (Python Security Scanner)
echo ""
echo "▶ Bandit Security Scan (Python)"
echo "───────────────────────────────────────────────────────────────"

cd /workspaces/kflow/backend

if command -v bandit &> /dev/null; then
    BANDIT_OUTPUT=$(bandit -r . -ll --exclude ./tests -f json 2>/dev/null) || true

    HIGH_ISSUES=$(echo "$BANDIT_OUTPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(len([r for r in d.get('results',[]) if r.get('issue_severity')=='HIGH']))" 2>/dev/null || echo "0")
    MEDIUM_ISSUES=$(echo "$BANDIT_OUTPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(len([r for r in d.get('results',[]) if r.get('issue_severity')=='MEDIUM']))" 2>/dev/null || echo "0")

    echo "  High severity:   $HIGH_ISSUES"
    echo "  Medium severity: $MEDIUM_ISSUES"

    echo "$BANDIT_OUTPUT" > "$REPORT_DIR/bandit.json" 2>/dev/null || true

    if [ "$HIGH_ISSUES" -gt 0 ]; then
        echo "  ✗ High severity security issues found"
        ERRORS=$((ERRORS + 1))
    else
        echo "  ✓ No high severity issues"
    fi
else
    echo "  ⚠ bandit not available, skipping"
fi

# Sensitive file check
echo ""
echo "▶ Sensitive File Check"
echo "───────────────────────────────────────────────────────────────"

cd /workspaces/kflow

SENSITIVE_FILES=""
for pattern in ".env" "*.pem" "*.key" "credentials.json" "secrets.yaml" "id_rsa"; do
    FOUND=$(find . -name "$pattern" -not -path "./.git/*" -not -path "./node_modules/*" 2>/dev/null || true)
    if [ -n "$FOUND" ]; then
        SENSITIVE_FILES="$SENSITIVE_FILES$FOUND\n"
    fi
done

if [ -n "$SENSITIVE_FILES" ]; then
    echo "  ⚠ Sensitive files found:"
    echo -e "$SENSITIVE_FILES" | head -5
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✓ No sensitive files in repository"
fi

# Check .gitignore for sensitive patterns
echo ""
echo "▶ .gitignore Security Check"
echo "───────────────────────────────────────────────────────────────"

GITIGNORE_PATTERNS=(".env" "*.pem" "*.key" "credentials" "secrets")
MISSING_PATTERNS=""

for pattern in "${GITIGNORE_PATTERNS[@]}"; do
    if ! grep -q "$pattern" .gitignore 2>/dev/null; then
        MISSING_PATTERNS="$MISSING_PATTERNS $pattern"
    fi
done

if [ -n "$MISSING_PATTERNS" ]; then
    echo "  ⚠ Missing from .gitignore:$MISSING_PATTERNS"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✓ .gitignore covers sensitive patterns"
fi

# Generate report
cat > "$REPORT_DIR/security_scan.txt" << EOF
Security Scan Report
====================
Generated: $(date)

Secrets Detection:
- Hardcoded API keys: $([ -n "$API_KEY_MATCHES" ] && echo "FOUND" || echo "None")
- Hardcoded passwords: $([ -n "$PASSWORD_MATCHES" ] && echo "FOUND" || echo "None")
- Private keys: $([ -n "$PRIVATE_KEY_MATCHES" ] && echo "FOUND" || echo "None")

Code Analysis:
- SQL injection patterns: $([ -n "$SQL_CONCAT" ] && echo "FOUND" || echo "None")
- XSS patterns: $([ -n "$INNERHTML" ] && echo "FOUND" || echo "None")

Bandit Results:
- High severity: ${HIGH_ISSUES:-N/A}
- Medium severity: ${MEDIUM_ISSUES:-N/A}

Errors: $ERRORS
Warnings: $WARNINGS
EOF

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"

if [ $ERRORS -eq 0 ]; then
    echo "✓ $GATE_NAME PASSED"
    exit 0
else
    echo "✗ $GATE_NAME FAILED"
    exit 1
fi
