#!/usr/bin/env python3
"""
KerjaFlow Translation Synchronization Utility
=============================================

Ensures all ARB translation files have the same keys as the English baseline.
Missing keys are added with English text marked as [NEEDS_TRANSLATION].

Usage:
    python translation_sync.py [--check-only]

Options:
    --check-only    Only report missing keys, don't modify files
"""

import json
import os
import sys
from pathlib import Path


# Configuration
L10N_DIR = Path(__file__).parent.parent / "lib" / "l10n"
BASELINE_FILE = "app_en.arb"
LANGUAGES = ["bn", "id", "km", "ms", "my", "ne", "ta", "th", "tl", "vi", "zh"]

# Placeholder prefix for untranslated strings
NEEDS_TRANSLATION_PREFIX = "[TRANSLATE] "


def load_arb(filepath):
    """Load ARB file and return dict."""
    with open(filepath, "r", encoding="utf-8") as f:
        return json.load(f)


def save_arb(filepath, data):
    """Save dict to ARB file with proper formatting."""
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")


def get_translatable_keys(arb_data):
    """Extract only translatable keys (not metadata starting with @)."""
    return {k for k in arb_data.keys() if not k.startswith("@") and k != "@@locale"}


def sync_translations(check_only=False):
    """Synchronize all translation files with baseline."""
    baseline_path = L10N_DIR / BASELINE_FILE

    if not baseline_path.exists():
        print(f"ERROR: Baseline file not found: {baseline_path}")
        sys.exit(1)

    baseline = load_arb(baseline_path)
    baseline_keys = get_translatable_keys(baseline)

    print(f"Baseline (EN): {len(baseline_keys)} translatable keys")
    print("=" * 60)

    total_missing = 0
    total_added = 0

    for lang in LANGUAGES:
        lang_file = L10N_DIR / f"app_{lang}.arb"

        if not lang_file.exists():
            print(f"WARNING: {lang_file.name} not found, creating...")
            lang_data = {"@@locale": lang}
        else:
            lang_data = load_arb(lang_file)

        lang_keys = get_translatable_keys(lang_data)
        missing_keys = baseline_keys - lang_keys

        if missing_keys:
            print(f"\n{lang.upper()}: {len(lang_keys)} keys, MISSING: {len(missing_keys)}")
            total_missing += len(missing_keys)

            if check_only:
                # Show first 10 missing keys
                print(f"  Sample missing keys:")
                for key in sorted(missing_keys)[:10]:
                    print(f"    - {key}")
                if len(missing_keys) > 10:
                    print(f"    ... and {len(missing_keys) - 10} more")
            else:
                # Add missing keys with placeholder translations
                for key in sorted(missing_keys):
                    en_value = baseline.get(key, key)
                    # Add placeholder prefix
                    lang_data[key] = f"{NEEDS_TRANSLATION_PREFIX}{en_value}"
                    # Copy metadata if exists
                    meta_key = f"@{key}"
                    if meta_key in baseline:
                        lang_data[meta_key] = baseline[meta_key]

                # Sort keys for consistency
                sorted_data = {"@@locale": lang}
                for key in sorted(lang_data.keys()):
                    if key != "@@locale":
                        sorted_data[key] = lang_data[key]

                save_arb(lang_file, sorted_data)
                total_added += len(missing_keys)
                print(f"  Added {len(missing_keys)} placeholder translations")
        else:
            print(f"\n{lang.upper()}: {len(lang_keys)} keys - COMPLETE ✓")

    print("\n" + "=" * 60)

    if check_only:
        print(f"TOTAL MISSING: {total_missing} keys across {len(LANGUAGES)} languages")
        if total_missing > 0:
            print("\nRun without --check-only to add placeholder translations.")
            return 1
    else:
        print(f"TOTAL ADDED: {total_added} placeholder translations")
        if total_added > 0:
            print(f"\nPlaceholder translations start with '{NEEDS_TRANSLATION_PREFIX}'")
            print("Search your ARB files for this prefix to find strings needing translation.")

    return 0


def main():
    check_only = "--check-only" in sys.argv

    print("KerjaFlow Translation Synchronization")
    print("=" * 60)
    print(f"Mode: {'Check Only' if check_only else 'Sync Missing Keys'}")
    print(f"Baseline: {BASELINE_FILE}")
    print(f"Languages: {', '.join(LANGUAGES)}")
    print()

    return sync_translations(check_only)


if __name__ == "__main__":
    sys.exit(main())
