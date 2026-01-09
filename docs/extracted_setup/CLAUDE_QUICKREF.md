# Claude Code CLI Quick Reference for KerjaFlow

> **TL;DR: Everything you need to know in one page**

---

## 🚀 START HERE

```bash
# First time setup
cd /path/to/kflow
claude                    # Start Claude Code CLI
```

---

## 🎯 THE RULES (Non-Negotiable)

### Money = Decimal, NEVER float
```python
# ❌ WRONG
amount = 5000.00

# ✅ CORRECT  
from decimal import Decimal
amount = Decimal("5000.00")
```

### Rate Lookup = Payslip Date, NEVER today()
```python
# ❌ WRONG
rate = get_current_rate()

# ✅ CORRECT
rate = get_rate_for_date(payslip_date)
```

### JWT = RS256, NEVER HS256
```python
# ❌ WRONG
jwt.encode(payload, secret, algorithm="HS256")

# ✅ CORRECT
jwt.encode(payload, private_key, algorithm="RS256")
```

### Employee Query = ALWAYS include country_code
```python
# ❌ WRONG
employees = self.env['kf.employee'].search([])

# ✅ CORRECT
employees = self.env['kf.employee'].search([
    ('country_code', '=', country_code),
])
```

---

## 📁 KEY PATHS

| What | Where |
|------|-------|
| Backend Models | `backend/odoo/addons/kerjaflow/models/` |
| Backend Controllers | `backend/odoo/addons/kerjaflow/controllers/` |
| Mobile Screens | `mobile/lib/features/*/presentation/` |
| Translations | `mobile/lib/l10n/app_*.arb` |
| Specifications | `docs/specs/` |
| Build System | `.kbs/kbs.sh` |

---

## 🔧 COMMANDS

### Quality Gates
```bash
.kbs/kbs.sh full         # Run ALL gates
.kbs/kbs.sh quick        # Lint + Security only
.kbs/kbs.sh security     # Security scan
.kbs/kbs.sh release      # Full + create release
```

### Backend
```bash
cd backend
python -m black .        # Format code
python -m flake8 .       # Lint code
python -m pytest         # Run tests
python -m bandit -r .    # Security scan
```

### Mobile
```bash
cd mobile
flutter pub get          # Get dependencies
flutter analyze          # Lint code
flutter test             # Run tests
flutter build apk        # Build APK
flutter gen-l10n         # Generate translations
```

---

## 🌏 ASEAN COUNTRIES

| Code | Country | Statutory | Holiday Count |
|------|---------|-----------|---------------|
| MY | Malaysia | EPF, SOCSO, EIS, PCB | 16 states |
| SG | Singapore | CPF, SDL | 11 |
| ID | Indonesia | BPJS-TK, BPJS-KES | 17+ |
| TH | Thailand | SSO | 19 |
| PH | Philippines | SSS, PhilHealth, Pag-IBIG | 20+ |
| VN | Vietnam | BHXH, BHYT, BHTN | 11 |
| KH | Cambodia | NSSF | 28 |
| MM | Myanmar | SSB | 20+ |
| BN | Brunei | TAP, SCP | 11 |

**Data Residency:**
- 🔴 Indonesia: MUST use local VPS
- 🔴 Vietnam: MUST use local VPS
- 🟢 Others: Can use Malaysia hub

---

## 🌐 LANGUAGES

| Code | Language | Script |
|------|----------|--------|
| en | English | Latin |
| ms | Bahasa Malaysia | Latin |
| id | Bahasa Indonesia | Latin |
| th | Thai | Thai |
| vi | Vietnamese | Latin |
| tl | Filipino | Latin |
| zh | Chinese | Han |
| ta | Tamil | Tamil |
| bn | Bengali | Bengali |
| ne | Nepali | Devanagari |
| km | Khmer | Khmer |
| my | Myanmar | Myanmar Unicode |

**Remember:**
- Malaysian Malay ≠ Indonesian Malay (treat as SEPARATE)
- Myanmar = Unicode ONLY (never Zawgyi)
- Preserve statutory abbreviations (EPF, SOCSO, etc.)

---

## 📊 COVERAGE TARGETS

| Component | Minimum | Target |
|-----------|---------|--------|
| Backend | 70% | 85% |
| Mobile | 70% | 85% |
| Statutory Calculator | 90% | 95% |
| Auth Controller | 85% | 90% |

---

## ⚠️ BLOCKERS TO FIX

1. **JWT Algorithm** → Change HS256 to RS256
2. **Missing Model** → Create `kf_user_device.py`
3. **Mobile Screens** → Implement 10 missing screens
4. **Translation Keys** → Align ZH-CN and KM with EN baseline

---

## 📖 MUST-READ DOCS

| Priority | Document | Location |
|----------|----------|----------|
| 1 | CLAUDE.md | `/CLAUDE.md` |
| 2 | Business Logic | `docs/specs/04_Business_Logic.md` |
| 3 | API Contract | `docs/specs/02_API_Contract.md` |
| 4 | Security | `docs/specs/06_Security_Hardening.md` |
| 5 | Mobile UX | `docs/specs/09_Mobile_UX_Specification.md` |

---

## 💡 QUICK TIPS

### Before Making Changes
1. Read relevant spec in `docs/specs/`
2. Check existing tests
3. Run `.kbs/kbs.sh quick`

### When Writing Code
1. Write tests first
2. Use Decimal for money
3. Include country_code in queries
4. Run quality gates before commit

### Commit Message Format
```
feat(statutory): Add October 2025 foreign worker EPF rates

- Add 2%/2% rates effective Oct 2025
- Update rate lookup logic

Refs: KWSP Circular 2024/05
```

---

## 🆘 HELP

| Need | Action |
|------|--------|
| API format | Check `docs/specs/02_API_Contract.md` |
| Calculation rules | Check `docs/specs/04_Business_Logic.md` |
| Screen design | Check `docs/specs/09_Mobile_UX_Specification.md` |
| Security requirements | Check `docs/specs/06_Security_Hardening.md` |
| Malaysian statutory | Check `docs/statutory/Malaysian_HR_Practitioner_Playbook.md` |

---

*KerjaFlow - Changing the game in ASEAN workforce management.*
