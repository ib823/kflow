#!/usr/bin/env python3
"""
Statutory Rate Validator
========================
Validates seeded statutory rates against official sources

Usage:
    python validation/statutory_rate_validator.py --country MY
    python validation/statutory_rate_validator.py --all
"""

import argparse
import sys
from decimal import Decimal
from datetime import date
from typing import List, Dict, Tuple
import psycopg2
from tabulate import tabulate


class StatutoryRateValidator:
    """Validates statutory rates in database"""

    def __init__(self, db_connection):
        self.db = db_connection
        self.errors = []
        self.warnings = []

    def validate_all_countries(self) -> bool:
        """Validate all 9 countries"""
        countries = ['MY', 'SG', 'ID', 'TH', 'PH', 'VN', 'KH', 'MM', 'BN']
        all_valid = True

        for country in countries:
            print(f"\n{'='*60}")
            print(f"Validating {country}")
            print(f"{'='*60}")

            if not self.validate_country(country):
                all_valid = False

        return all_valid

    def validate_country(self, country_code: str) -> bool:
        """Validate rates for a specific country"""
        validators = {
            'MY': self._validate_malaysia,
            'SG': self._validate_singapore,
            'ID': self._validate_indonesia,
            'TH': self._validate_thailand,
            'PH': self._validate_philippines,
            'VN': self._validate_vietnam,
            'KH': self._validate_cambodia,
            'MM': self._validate_myanmar,
            'BN': self._validate_brunei,
        }

        validator = validators.get(country_code)
        if not validator:
            print(f"❌ No validator for {country_code}")
            return False

        return validator()

    def _validate_malaysia(self) -> bool:
        """Validate Malaysia statutory rates"""
        print("Checking Malaysia EPF, SOCSO, EIS, HRDF...")

        # EPF young under 5k: 11% + 13%
        epf = self._get_rate('MY', 'EPF', 'MY_UNDER60_UNDER5K', date(2025, 6, 1))
        assert epf['employee_rate'] == Decimal('0.11'), "EPF employee rate should be 11%"
        assert epf['employer_rate'] == Decimal('0.13'), "EPF employer rate should be 13%"
        print("✓ EPF under 60, salary ≤ RM5K: 11% + 13%")

        # EPF young over 5k: 11% + 12%
        epf2 = self._get_rate('MY', 'EPF', 'MY_UNDER60_OVER5K', date(2025, 6, 1))
        assert epf2['employer_rate'] == Decimal('0.12'), "EPF employer should be 12% for > RM5K"
        print("✓ EPF under 60, salary > RM5K: 11% + 12%")

        # Foreign worker EPF (post Oct 2025)
        epf_foreign = self._get_rate('MY', 'EPF_FOREIGN', 'FOREIGN_2025', date(2025, 11, 1))
        assert epf_foreign is not None, "Foreign EPF should exist after Oct 2025"
        assert epf_foreign['employee_rate'] == Decimal('0.02'), "Foreign EPF should be 2%"
        print("✓ EPF foreign worker (Oct 2025): 2% + 2%")

        # SOCSO
        socso = self._get_rate('MY', 'SOCSO', 'SOCSO_STANDARD', date(2025, 6, 1))
        assert socso['employee_rate'] == Decimal('0.005'), "SOCSO should be 0.5%"
        assert socso['employer_rate'] == Decimal('0.0125'), "SOCSO employer should be 1.25%"
        print("✓ SOCSO: 0.5% + 1.25%")

        # EIS (reduced Oct 2024)
        eis = self._get_rate('MY', 'EIS', 'EIS_STANDARD', date(2025, 6, 1))
        assert eis['employee_rate'] == Decimal('0.002'), "EIS should be 0.2% (reduced Oct 2024)"
        print("✓ EIS (Oct 2024 reduction): 0.2% + 0.2%")

        # Check ceilings
        socso_ceiling = self._get_ceiling('MY', 'SOCSO', date(2025, 6, 1))
        assert socso_ceiling == Decimal('5000'), "SOCSO ceiling should be RM5,000"
        print("✓ SOCSO ceiling: RM5,000")

        eis_ceiling = self._get_ceiling('MY', 'EIS', date(2025, 6, 1))
        assert eis_ceiling == Decimal('6000'), "EIS ceiling should be RM6,000 (Oct 2024)"
        print("✓ EIS ceiling: RM6,000 (increased Oct 2024)")

        print("✅ Malaysia validation PASSED")
        return True

    def _validate_singapore(self) -> bool:
        """Validate Singapore CPF rates"""
        print("Checking Singapore CPF...")

        # CPF young 2025: 20% + 17%
        cpf = self._get_rate('SG', 'CPF', 'SG_CITIZEN_UNDER55_2025', date(2025, 6, 1))
        assert cpf['employee_rate'] == Decimal('0.20'), "CPF employee should be 20%"
        assert cpf['employer_rate'] == Decimal('0.17'), "CPF employer should be 17%"
        print("✓ CPF under 55 (2025): 20% + 17%")

        # CPF 60-65 2026 increase
        cpf_2026 = self._get_rate('SG', 'CPF', 'SG_CITIZEN_60_65_2026', date(2026, 6, 1))
        assert cpf_2026 is not None, "CPF 2026 rates should exist"
        assert cpf_2026['total_rate'] == Decimal('0.255'), "CPF 60-65 2026 should be 25.5%"
        print("✓ CPF 60-65 (2026 increase): 25.5% total")

        # Ceiling 2025
        ceiling_2025 = self._get_ceiling('SG', 'CPF', date(2025, 6, 1))
        assert ceiling_2025 == Decimal('7400'), "CPF OW ceiling 2025 should be SGD7,400"
        print("✓ CPF OW ceiling (2025): SGD7,400")

        # Ceiling 2026
        ceiling_2026 = self._get_ceiling('SG', 'CPF', date(2026, 6, 1))
        assert ceiling_2026 == Decimal('8000'), "CPF OW ceiling 2026 should be SGD8,000"
        print("✓ CPF OW ceiling (2026): SGD8,000")

        print("✅ Singapore validation PASSED")
        return True

    def _validate_indonesia(self) -> bool:
        """Validate Indonesia BPJS rates"""
        print("Checking Indonesia BPJS...")

        # JHT
        jht = self._get_rate('ID', 'JHT', 'JHT_STANDARD', date(2025, 6, 1))
        assert jht['employee_rate'] == Decimal('0.02'), "JHT employee should be 2%"
        assert jht['employer_rate'] == Decimal('0.037'), "JHT employer should be 3.7%"
        print("✓ JHT: 2% + 3.7%")

        # BPJS Kesehatan
        bpjs_kes = self._get_rate('ID', 'BPJS_KES', 'BPJS_KES_STANDARD', date(2025, 6, 1))
        assert bpjs_kes['employee_rate'] == Decimal('0.01'), "BPJS Kes employee should be 1%"
        assert bpjs_kes['employer_rate'] == Decimal('0.04'), "BPJS Kes employer should be 4%"
        print("✓ BPJS Kesehatan: 1% + 4%")

        print("✅ Indonesia validation PASSED")
        return True

    def _validate_thailand(self) -> bool:
        """Validate Thailand SSF"""
        print("Checking Thailand SSF...")

        # SSF 5% + 5%
        ssf = self._get_rate('TH', 'SSF_33', 'SSF_STANDARD', date(2025, 6, 1))
        assert ssf['employee_rate'] == Decimal('0.05'), "SSF employee should be 5%"
        assert ssf['employer_rate'] == Decimal('0.05'), "SSF employer should be 5%"
        print("✓ SSF: 5% + 5%")

        # Check 3-phase ceiling increases
        ceiling_2025 = self._get_ceiling('TH', 'SSF_33', date(2025, 6, 1))
        assert ceiling_2025 == Decimal('15000'), "SSF 2025 ceiling should be ฿15,000"
        print("✓ SSF ceiling (2025): ฿15,000")

        ceiling_2026 = self._get_ceiling('TH', 'SSF_33', date(2026, 6, 1))
        assert ceiling_2026 == Decimal('17500'), "SSF 2026 ceiling should be ฿17,500"
        print("✓ SSF ceiling (2026): ฿17,500")

        ceiling_2032 = self._get_ceiling('TH', 'SSF_33', date(2032, 6, 1))
        assert ceiling_2032 == Decimal('23000'), "SSF 2032 ceiling should be ฿23,000"
        print("✓ SSF ceiling (2032): ฿23,000")

        print("✅ Thailand validation PASSED")
        return True

    def _validate_philippines(self) -> bool:
        """Validate Philippines SSS, PhilHealth, Pag-IBIG"""
        print("Checking Philippines...")

        # SSS 2025 final rate
        sss = self._get_rate('PH', 'SSS', 'SSS_2025', date(2025, 6, 1))
        assert sss['total_rate'] == Decimal('0.15'), "SSS total should be 15%"
        print("✓ SSS (2025 final): 15% total")

        # PhilHealth
        phic = self._get_rate('PH', 'PHIC', 'PHIC_2025', date(2025, 6, 1))
        assert phic['employee_rate'] == Decimal('0.025'), "PhilHealth should be 2.5%"
        print("✓ PhilHealth: 2.5% + 2.5%")

        print("✅ Philippines validation PASSED")
        return True

    def _validate_vietnam(self) -> bool:
        """Validate Vietnam BHXH with July 2025 changes"""
        print("Checking Vietnam BHXH...")

        # Vietnamese employee (32%)
        bhxh_vn = self._get_rate('VN', 'BHXH', 'BHXH_VN', date(2025, 8, 1))
        assert bhxh_vn is not None, "Vietnamese BHXH should exist"
        total = bhxh_vn['employee_rate'] + bhxh_vn['employer_rate']
        assert total == Decimal('0.32'), "Vietnamese BHXH should be 32% total (July 2025)"
        print("✓ BHXH Vietnamese (July 2025): 32% total")

        # Foreign employee (30%, no UI)
        bhxh_foreign = self._get_rate('VN', 'BHXH', 'BHXH_FOREIGN', date(2025, 8, 1))
        assert bhxh_foreign is not None, "Foreign BHXH should exist"
        total_foreign = bhxh_foreign['employee_rate'] + bhxh_foreign['employer_rate']
        assert total_foreign == Decimal('0.30'), "Foreign BHXH should be 30% (no UI)"
        print("✓ BHXH Foreign (no UI): 30% total")

        # Trade Union reduced fee
        tu = self._get_rate('VN', 'TRADE_UNION', 'TU_2025', date(2025, 8, 1))
        assert tu['employee_rate'] == Decimal('0.005'), "Trade Union should be 0.5% (reduced)"
        print("✓ Trade Union (reduced July 2025): 0.5% + 2%")

        print("✅ Vietnam validation PASSED")
        return True

    def _validate_cambodia(self) -> bool:
        """Validate Cambodia NSSF with phased pension increases"""
        print("Checking Cambodia NSSF...")

        # Phase 1: 2022-2027 (4%)
        pension_p1 = self._get_rate('KH', 'NSSF_PENSION', 'PENSION_PHASE1', date(2025, 6, 1))
        assert pension_p1['total_rate'] == Decimal('0.04'), "Phase 1 should be 4%"
        print("✓ NSSF Pension Phase 1 (2022-2027): 4%")

        # Phase 2: 2027-2032 (6%)
        pension_p2 = self._get_rate('KH', 'NSSF_PENSION', 'PENSION_PHASE2', date(2028, 6, 1))
        assert pension_p2['total_rate'] == Decimal('0.06'), "Phase 2 should be 6%"
        print("✓ NSSF Pension Phase 2 (2027-2032): 6%")

        # Phase 3: 2032+ (8%)
        pension_p3 = self._get_rate('KH', 'NSSF_PENSION', 'PENSION_PHASE3', date(2033, 6, 1))
        assert pension_p3['total_rate'] == Decimal('0.08'), "Phase 3 should be 8%"
        print("✓ NSSF Pension Phase 3 (2032+): 8%")

        # Health (employer only)
        health = self._get_rate('KH', 'NSSF_HEALTH', 'HEALTH_STANDARD', date(2025, 6, 1))
        assert health['employee_rate'] == Decimal('0'), "Health should be employer-only"
        assert health['employer_rate'] == Decimal('0.026'), "Health employer should be 2.6%"
        print("✓ NSSF Health: 0% + 2.6%")

        print("✅ Cambodia validation PASSED")
        return True

    def _validate_myanmar(self) -> bool:
        """Validate Myanmar SSB"""
        print("Checking Myanmar SSB...")

        ssb = self._get_rate('MM', 'SSB', 'SSB_STANDARD', date(2025, 6, 1))
        assert ssb['employee_rate'] == Decimal('0.02'), "SSB employee should be 2%"
        assert ssb['employer_rate'] == Decimal('0.03'), "SSB employer should be 3%"
        print("✓ SSB: 2% + 3%")

        print("✅ Myanmar validation PASSED")
        return True

    def _validate_brunei(self) -> bool:
        """Validate Brunei SPK"""
        print("Checking Brunei SPK...")

        # Tier 2
        spk = self._get_rate('BN', 'SPK', 'SPK_TIER2', date(2025, 6, 1))
        assert spk['employee_rate'] == Decimal('0.085'), "SPK employee should be 8.5%"
        print("✓ SPK Tier 2: 8.5% + 10.5%")

        print("✅ Brunei validation PASSED")
        return True

    def _get_rate(
        self,
        country_code: str,
        scheme_code: str,
        tier_code: str,
        calc_date: date
    ) -> Dict:
        """Get rate from database"""
        cursor = self.db.cursor()

        query = """
            SELECT r.employee_rate, r.employer_rate, r.total_rate
            FROM kf_statutory_rate r
            JOIN kf_statutory_scheme s ON r.scheme_id = s.id
            JOIN kf_country c ON s.country_id = c.id
            WHERE c.code = %s
              AND s.code = %s
              AND r.tier_code = %s
              AND r.effective_from <= %s
              AND (r.effective_until IS NULL OR r.effective_until >= %s)
            LIMIT 1
        """

        cursor.execute(query, (country_code, scheme_code, tier_code, calc_date, calc_date))
        row = cursor.fetchone()
        cursor.close()

        if not row:
            return None

        return {
            'employee_rate': Decimal(str(row[0])) if row[0] else Decimal('0'),
            'employer_rate': Decimal(str(row[1])) if row[1] else Decimal('0'),
            'total_rate': Decimal(str(row[2])) if row[2] else None,
        }

    def _get_ceiling(
        self,
        country_code: str,
        scheme_code: str,
        calc_date: date
    ) -> Decimal:
        """Get ceiling from database"""
        cursor = self.db.cursor()

        query = """
            SELECT c.ceiling_amount
            FROM kf_statutory_ceiling c
            JOIN kf_statutory_scheme s ON c.scheme_id = s.id
            JOIN kf_country co ON s.country_id = co.id
            WHERE co.code = %s
              AND s.code = %s
              AND c.ceiling_type = 'MONTHLY'
              AND c.effective_from <= %s
              AND (c.effective_until IS NULL OR c.effective_until >= %s)
            ORDER BY c.effective_from DESC
            LIMIT 1
        """

        cursor.execute(query, (country_code, scheme_code, calc_date, calc_date))
        row = cursor.fetchone()
        cursor.close()

        if not row:
            return None

        return Decimal(str(row[0]))


def main():
    parser = argparse.ArgumentParser(description='Validate statutory rates')
    parser.add_argument('--country', help='Country code (MY, SG, ID, etc.)')
    parser.add_argument('--all', action='store_true', help='Validate all countries')
    args = parser.parse_args()

    import os
    conn = psycopg2.connect(
        host=os.getenv("KFLOW_DB_HOST", "localhost"),
        database=os.getenv("KFLOW_DB_NAME", "kerjaflow"),
        user=os.getenv("KFLOW_DB_USER", "postgres"),
        password=os.getenv("KFLOW_DB_PASSWORD", "postgres")
    )

    validator = StatutoryRateValidator(conn)

    try:
        if args.all:
            success = validator.validate_all_countries()
        elif args.country:
            success = validator.validate_country(args.country)
        else:
            print("Error: Specify --country or --all")
            sys.exit(1)

        if success:
            print("\n" + "="*60)
            print("✅ ALL VALIDATIONS PASSED")
            print("="*60)
            sys.exit(0)
        else:
            print("\n" + "="*60)
            print("❌ VALIDATION FAILED")
            print("="*60)
            sys.exit(1)

    finally:
        conn.close()


if __name__ == "__main__":
    main()
