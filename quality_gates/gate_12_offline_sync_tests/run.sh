#!/bin/bash
#############################################
# GATE 12: OFFLINE SYNC TESTS
#
# Checks:
# - Offline storage implementation
# - Sync queue mechanism
# - Connectivity handling
# - Data persistence
#############################################

set -e

REPORT_DIR="${1:-.}"
GATE_NAME="Gate 12: Offline Sync Tests"
ERRORS=0
WARNINGS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  $GATE_NAME                                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"

cd /workspaces/kflow/mobile

# Local storage check
echo ""
echo "▶ Local Storage Implementation"
echo "───────────────────────────────────────────────────────────────"

# Check for Hive
HIVE_USAGE=$(grep -r "Hive\|hive" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Hive references: $HIVE_USAGE"

# Check for SQLite/Drift
DRIFT_USAGE=$(grep -r "Drift\|drift\|@DriftDatabase" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Drift/SQLite references: $DRIFT_USAGE"

# Check for SharedPreferences
SHARED_PREFS=$(grep -r "SharedPreferences" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  SharedPreferences references: $SHARED_PREFS"

# Check for secure storage
SECURE_STORAGE=$(grep -r "FlutterSecureStorage\|SecureStorage" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  SecureStorage references: $SECURE_STORAGE"

TOTAL_STORAGE=$((HIVE_USAGE + DRIFT_USAGE + SHARED_PREFS + SECURE_STORAGE))
if [ "$TOTAL_STORAGE" -gt 0 ]; then
    echo "  ✓ Local storage implemented"
else
    echo "  ✗ No local storage found"
    ERRORS=$((ERRORS + 1))
fi

# Sync manager check
echo ""
echo "▶ Sync Manager"
echo "───────────────────────────────────────────────────────────────"

SYNC_FILES=$(find lib -name "*sync*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Sync-related files: $SYNC_FILES"

if [ "$SYNC_FILES" -gt 0 ]; then
    echo "  ✓ Sync manager present"
    find lib -name "*sync*.dart" 2>/dev/null | while read -r file; do
        echo "    - $(basename "$file")"
    done
else
    echo "  ⚠ No sync manager found"
    WARNINGS=$((WARNINGS + 1))
fi

# Queue mechanism
echo ""
echo "▶ Offline Queue"
echo "───────────────────────────────────────────────────────────────"

QUEUE_REFS=$(grep -r "queue\|Queue\|pending" lib --include="*.dart" 2>/dev/null | grep -i "sync\|offline" | wc -l || echo "0")
echo "  Queue references: $QUEUE_REFS"

if [ "$QUEUE_REFS" -gt 0 ]; then
    echo "  ✓ Offline queue mechanism present"
else
    echo "  ⚠ No offline queue found"
    WARNINGS=$((WARNINGS + 1))
fi

# Connectivity handling
echo ""
echo "▶ Connectivity Handling"
echo "───────────────────────────────────────────────────────────────"

CONNECTIVITY=$(grep -r "Connectivity\|connectivity_plus\|ConnectivityResult" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Connectivity references: $CONNECTIVITY"

if [ "$CONNECTIVITY" -gt 0 ]; then
    echo "  ✓ Connectivity handling present"
else
    echo "  ⚠ No connectivity handling"
    WARNINGS=$((WARNINGS + 1))
fi

# Check pubspec for offline dependencies
echo ""
echo "▶ Offline Dependencies (pubspec.yaml)"
echo "───────────────────────────────────────────────────────────────"

OFFLINE_DEPS=("hive" "connectivity_plus" "flutter_secure_storage" "shared_preferences")
for dep in "${OFFLINE_DEPS[@]}"; do
    if grep -q "$dep:" pubspec.yaml 2>/dev/null; then
        echo "  ✓ $dep"
    else
        echo "  ⚠ $dep not in pubspec"
    fi
done

# Cache strategy check
echo ""
echo "▶ Cache Strategy"
echo "───────────────────────────────────────────────────────────────"

CACHE_REFS=$(grep -r "cache\|Cache\|ttl\|TTL\|expir" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Cache references: $CACHE_REFS"

# Generate report
cat > "$REPORT_DIR/offline_sync.txt" << EOF
Offline Sync Report
===================
Generated: $(date)

Storage:
- Hive: $HIVE_USAGE
- Drift/SQLite: $DRIFT_USAGE
- SharedPreferences: $SHARED_PREFS
- SecureStorage: $SECURE_STORAGE

Sync:
- Sync files: $SYNC_FILES
- Queue refs: $QUEUE_REFS
- Connectivity: $CONNECTIVITY
- Cache refs: $CACHE_REFS

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
