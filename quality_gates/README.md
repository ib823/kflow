# KerjaFlow Quality Gates

15 local quality gates for production readiness verification. No external CI/CD services required.

## Quick Start

```bash
# Run all 15 gates
./quality_gates/run_all_gates.sh

# Quick check (4 essential gates)
./quality_gates/quick_check.sh

# Run with options
./quality_gates/run_all_gates.sh --continue    # Continue on failures
./quality_gates/run_all_gates.sh --skip-build  # Skip build gates
```

## Gate Overview

| Gate | Name | Purpose |
|------|------|---------|
| 01 | Static Analysis | Flutter analyze, flake8, dart format |
| 02 | Code Quality | Line counts, complexity, TODOs |
| 03 | Security Scan | Secrets, SQL injection, XSS, Bandit |
| 04 | Unit Tests | Dart and Python unit tests |
| 05 | Widget Tests | Flutter widget tests |
| 06 | Integration Tests | User flow tests |
| 07 | Golden Tests | Visual regression tests |
| 08 | Performance Tests | Anti-patterns, memory leaks |
| 09 | Accessibility Audit | Semantics, touch targets |
| 10 | i18n Verification | 12 ASEAN languages |
| 11 | API Contract Tests | Endpoints, models, repositories |
| 12 | Offline Sync Tests | Local storage, sync queue |
| 13 | Edge Case Tests | Null safety, error handling |
| 14 | Regression Tests | Full test suite |
| 15 | Final Certification | Build verification, APK size |

## Gate Details

### Gate 01: Static Analysis
- Flutter analyze (no errors allowed)
- Python flake8 (max line length 120)
- Dart format check

### Gate 02: Code Quality
- Codebase size limits
- Large file detection (>500 lines)
- TODO/FIXME tracking
- Debug print detection

### Gate 03: Security Scan
- Hardcoded secrets detection
- API key exposure check
- SQL injection patterns
- XSS vulnerability detection
- Python Bandit scan

### Gate 04-07: Tests
- Unit tests with coverage
- Widget tests for UI components
- Integration tests for flows
- Golden tests for visual regression

### Gate 08: Performance
- setState in loops detection
- Complex build method detection
- Memory leak patterns
- Large asset detection

### Gate 09: Accessibility
- Semantics widget usage
- Touch target sizes (48x48 minimum)
- Tooltip coverage for icons
- Focus management

### Gate 10: i18n Verification
- All 12 ASEAN languages present
- Key consistency across files
- Hardcoded string detection

### Gate 11-12: API & Offline
- API endpoint definitions
- Repository pattern
- Offline storage implementation
- Sync queue mechanism

### Gate 13: Edge Cases
- Null safety patterns
- Empty state handling
- Error boundaries
- Loading states

### Gate 14: Regression
- Full test suite execution
- Test duration tracking

### Gate 15: Final Certification
- Release build verification
- APK size check (<50MB)
- Signing configuration
- Production checklist

## Reports

Reports are generated in `quality_gates/reports/YYYYMMDD_HHMMSS/`:
- `SUMMARY.txt` - Overall summary
- `gate_XX.log` - Individual gate logs
- Various analysis reports

## Pre-commit Usage

Add to your git hooks:

```bash
# .git/hooks/pre-commit
#!/bin/bash
./quality_gates/quick_check.sh
```

## Exit Codes

- `0` - All gates passed
- `1` - One or more gates failed
