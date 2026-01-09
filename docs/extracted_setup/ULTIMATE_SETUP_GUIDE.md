# KerjaFlow Claude Code CLI - Ultimate Setup Guide

## PART 1: FILES TO IMPORT INTO REPOSITORY

### Step-by-Step Import Instructions

```bash
# 1. Clone your repo (if not already)
cd ~/projects
git clone https://github.com/ib823/kflow.git
cd kflow

# 2. Create branch for this work
git checkout -b setup/claude-code-infrastructure
```

### File Placement Map

Copy files from this conversation to these EXACT locations:

```
kflow/
│
├── CLAUDE.md                          ← COPY: CLAUDE.md (ROOT - CRITICAL!)
│
├── .gitignore                         ← COPY: gitignore.txt (rename to .gitignore)
│
├── .kbs/                              ← CREATE THIS DIRECTORY
│   ├── kbs.sh                         ← COPY: kbs.sh (chmod +x)
│   ├── config.yaml                    ← COPY: kbs-config.yaml (rename)
│   └── hooks/
│       ├── pre-commit                 ← COPY: kbs-hooks/pre-commit (chmod +x)
│       └── pre-push                   ← COPY: kbs-hooks/pre-push (chmod +x)
│
└── docs/
    ├── CLAUDE_QUICKREF.md             ← COPY: CLAUDE_QUICKREF.md
    ├── KERJAFLOW_FILE_MANIFEST.md     ← COPY: KERJAFLOW_FILE_MANIFEST.md
    └── infrastructure/
        └── INTERNAL_INFRASTRUCTURE_MANIFESTO.md  ← COPY: KerjaFlow_Internal_Infrastructure_Manifesto.md
```

### Exact Commands to Run

```bash
# Navigate to your repo
cd ~/path/to/kflow

# Create directories
mkdir -p .kbs/hooks
mkdir -p docs/infrastructure

# Copy CLAUDE.md to ROOT (CRITICAL - Claude Code reads this automatically)
cp /path/to/downloaded/CLAUDE.md ./CLAUDE.md

# Copy and rename .gitignore
cp /path/to/downloaded/gitignore.txt ./.gitignore

# Copy KBS files
cp /path/to/downloaded/kbs.sh ./.kbs/kbs.sh
cp /path/to/downloaded/kbs-config.yaml ./.kbs/config.yaml

# Copy hooks
cp /path/to/downloaded/kbs-hooks/pre-commit ./.kbs/hooks/pre-commit
cp /path/to/downloaded/kbs-hooks/pre-push ./.kbs/hooks/pre-push

# Copy documentation
cp /path/to/downloaded/CLAUDE_QUICKREF.md ./docs/CLAUDE_QUICKREF.md
cp /path/to/downloaded/KERJAFLOW_FILE_MANIFEST.md ./docs/KERJAFLOW_FILE_MANIFEST.md
cp /path/to/downloaded/KerjaFlow_Internal_Infrastructure_Manifesto.md ./docs/infrastructure/INTERNAL_INFRASTRUCTURE_MANIFESTO.md

# Make scripts executable
chmod +x .kbs/kbs.sh
chmod +x .kbs/hooks/pre-commit
chmod +x .kbs/hooks/pre-push

# Install git hooks
cp .kbs/hooks/pre-commit .git/hooks/pre-commit
cp .kbs/hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/pre-push

# Install Python tools (required for quality gates)
pip install black flake8 isort pytest pytest-cov bandit safety pip-audit

# Verify setup
ls -la CLAUDE.md
ls -la .kbs/
.kbs/kbs.sh help

# Commit
git add -A
git commit -m "feat(infra): Add Claude Code CLI setup and internal CI/CD

- Add CLAUDE.md for Claude Code CLI instructions
- Add KerjaFlow Build System (KBS) for internal CI/CD
- Add quality gate configuration
- Add Git hooks for local enforcement
- Zero external services, 100% internal"

git push -u origin setup/claude-code-infrastructure
```

---

## PART 2: THE ULTIMATE PARANOID PROMPT

### Before Running Claude Code CLI

```bash
# Navigate to repo root
cd ~/path/to/kflow

# Verify CLAUDE.md exists (Claude Code reads this automatically)
cat CLAUDE.md | head -50

# Start Claude Code CLI
claude
```

### THE PROMPT (Copy-Paste This Exactly)

```
I am invoking EXTREME KIASU MODE. You are operating under ZERO TRUST assumptions.

CONTEXT:
- This is the KerjaFlow codebase - an ASEAN Enterprise Workforce Management Platform
- Read CLAUDE.md in the repo root FIRST - it contains all project rules
- You have been given access to potentially fuck things up - I assume you WILL try
- Every claim you make MUST be verified with actual file paths and line numbers
- Every file you say exists MUST be proven with `cat` or `ls`
- Every feature you say is implemented MUST be proven with actual code snippets

YOUR MISSION:
Execute a comprehensive production readiness audit with the following constraints:

1. ANTI-HALLUCINATION PROTOCOL (MANDATORY):
   - You MUST run actual commands to verify EVERYTHING
   - You MUST NOT claim any file exists without `ls` or `cat` proof
   - You MUST NOT claim any feature works without showing the actual code
   - You MUST NOT assume ANYTHING - verify or mark as UNVERIFIED
   - If you cannot verify something, say "UNVERIFIED: [reason]"
   - Every finding MUST have an evidence reference: [EV-XXX]

2. EXHAUSTIVE ENUMERATION (NO SHORTCUTS):
   - List EVERY model file in backend/odoo/addons/kerjaflow/models/
   - List EVERY controller file in backend/odoo/addons/kerjaflow/controllers/
   - List EVERY screen file in mobile/lib/features/*/presentation/
   - List EVERY ARB translation file in mobile/lib/l10n/
   - Count the EXACT number of translation keys in EACH file
   - Verify EVERY file mentioned in docs matches actual implementation

3. SECURITY AUDIT (PARANOID MODE):
   - Find the EXACT line where JWT algorithm is defined - is it HS256 or RS256?
   - Find the EXACT line where PIN hashing is implemented - what algorithm?
   - Find ANY hardcoded secrets, API keys, passwords in the codebase
   - Find ANY use of `http://` instead of `https://` in production code
   - Find ANY use of `float` for money calculations (should be Decimal)
   - Find ANY SQL queries that might be vulnerable to injection
   - Find ANY missing input validation in controllers

4. SPECIFICATION VS IMPLEMENTATION (CONTRADICTION HUNTING):
   - Read docs/specs/ and compare against actual implementation
   - Every screen mentioned in Mobile UX Spec - does it exist?
   - Every API endpoint in API Contract - is it implemented?
   - Every model in Data Foundation - does the file exist?
   - List ALL contradictions between spec and code

5. COMPLIANCE VERIFICATION (ASEAN STATUTORY):
   - Is there a statutory rate table for ALL 9 ASEAN countries?
   - Is the EPF calculation using payslip_date or current date?
   - Are SOCSO ceiling limits correctly implemented?
   - Is country_code included in ALL employee queries?

6. QUALITY GATES (PROVE THEY WORK):
   - Run `python3 -m black --check backend/` and show output
   - Run `python3 -m flake8 backend/` and show output  
   - Run `python3 -m bandit -r backend/ -ll` and show output
   - Run `flutter analyze` in mobile/ and show output (if Flutter available)
   - Show ACTUAL test count and coverage (not assumed)

7. MISSING FILE DETECTION:
   - Is `kf_user_device.py` in models/? (Known missing)
   - Are all 27 screens from UX spec implemented?
   - Are all 12 ARB files present with equal key counts?

8. OUTPUT FORMAT (STRICT):
   For each finding, use this format:
   
   ### F-XXX: [Finding Title]
   
   | Attribute | Value |
   |-----------|-------|
   | Severity | BLOCKER / HIGH / MEDIUM / LOW |
   | Category | Security / Compliance / Quality / Implementation |
   | Status | PROVEN / UNVERIFIED |
   | Evidence | [EV-XXX] |
   
   **Evidence:**
   ```
   [Actual command output or code snippet]
   ```
   
   **Fix Required:**
   [Specific fix with file path and line number]

9. FINAL DELIVERABLES:
   - Findings summary table (sorted by severity)
   - Work items with hour estimates
   - Blockers that MUST be fixed before production
   - Overall READY / NOT READY verdict with justification

10. ZERO TRUST RULES:
    - If you're unsure, say "UNCERTAIN - needs manual verification"
    - If a command fails, document the failure, don't assume success
    - If you can't access a file, mark it as INACCESSIBLE
    - Do NOT make optimistic assumptions
    - Do NOT skip anything because it "probably works"
    - Do NOT trust previous audit results - verify fresh

BEGIN AUDIT NOW.

Start by:
1. Running `pwd` to confirm you're in the repo root
2. Running `ls -la` to show repo structure
3. Running `cat CLAUDE.md | head -100` to confirm you've read project rules
4. Then proceed with systematic verification of EVERYTHING

I expect this audit to take significant time and produce a comprehensive report.
Do NOT rush. Do NOT skip. Do NOT assume.

EVERY. SINGLE. THING. MUST. BE. VERIFIED.
```

---

## PART 3: VERIFICATION CHECKLIST

### After Claude Code CLI Completes

Manually verify Claude's findings:

```bash
# 1. Check JWT algorithm (should be RS256)
grep -rn "HS256\|RS256" backend/

# 2. Check for missing model
ls backend/odoo/addons/kerjaflow/models/kf_user_device.py

# 3. Count translation keys
for f in mobile/lib/l10n/app_*.arb; do
  echo "$f: $(grep -c '"' "$f")"
done

# 4. Check for hardcoded secrets
grep -rn "password\s*=\s*['\"]" backend/ --include="*.py" | grep -v test

# 5. Check for float usage with money
grep -rn "float(" backend/ --include="*.py" | grep -v test

# 6. Run security scan
python3 -m bandit -r backend/ -ll

# 7. Count screens
find mobile/lib/features -name "*_screen.dart" | wc -l
```

---

## PART 4: WHAT TO EXPECT

### Claude Code CLI Will:

1. **Read CLAUDE.md automatically** - This gives it all project context
2. **Run actual commands** - Not just claim things work
3. **Produce evidence-based findings** - With file paths and line numbers
4. **Identify contradictions** - Between spec and implementation
5. **Provide hour estimates** - For fixing each issue

### Red Flags (Claude is Hallucinating If):

- Claims files exist without showing `ls` output
- Claims features work without showing code
- Gives vague answers like "appears to be implemented"
- Skips verification with "based on the structure..."
- Produces findings without [EV-XXX] evidence references

### Expected Findings (Based on Previous Audits):

| Issue | Status | Priority |
|-------|--------|----------|
| JWT uses HS256 not RS256 | Known | BLOCKER |
| `kf_user_device.py` missing | Known | BLOCKER |
| 10 mobile screens not implemented | Known | HIGH |
| Translation key count mismatch | Known | HIGH |
| Test coverage unknown | Verify | HIGH |

---

## PART 5: QUICK REFERENCE

### File Locations After Import

```
kflow/
├── CLAUDE.md                    ← Claude Code reads this FIRST
├── .gitignore
├── .kbs/
│   ├── kbs.sh                   ← Run: .kbs/kbs.sh full
│   ├── config.yaml
│   └── hooks/
│       ├── pre-commit
│       └── pre-push
└── docs/
    ├── CLAUDE_QUICKREF.md
    ├── KERJAFLOW_FILE_MANIFEST.md
    └── infrastructure/
        └── INTERNAL_INFRASTRUCTURE_MANIFESTO.md
```

### Commands

```bash
# Start Claude Code
claude

# Run quality gates manually
.kbs/kbs.sh full

# Run quick check
.kbs/kbs.sh quick

# Run security scan
.kbs/kbs.sh security
```

---

## SUMMARY

1. **Import 8 files** to the exact locations specified
2. **Run `chmod +x`** on all shell scripts
3. **Install Python tools** via pip
4. **Start `claude`** in repo root
5. **Paste the paranoid prompt** exactly as written
6. **Verify findings** with manual checks
7. **Fix blockers** before production

**ZERO TRUST. ZERO ASSUMPTIONS. 100% VERIFIED.**
