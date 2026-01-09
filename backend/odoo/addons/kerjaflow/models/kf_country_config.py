# -*- coding: utf-8 -*-
"""
Country Configuration Model
============================

Table: kf_country_config
CENTRAL table (Malaysia Hub Only) - stores configuration for all 9 ASEAN countries.

Per CLAUDE.md: This is a HUB table that defines country-specific settings
for data routing, statutory rates, and localization.
"""

from odoo.exceptions import ValidationError

from odoo import api, fields, models


class KfCountryConfig(models.Model):
    """Country configuration for KerjaFlow ASEAN operations"""

    _name = "kf.country.config"
    _description = "KerjaFlow Country Configuration"
    _order = "sequence, country_code"
    _rec_name = "country_name"

    # Primary identifier
    country_code = fields.Char(
        string="Country Code",
        required=True,
        size=2,
        index=True,
        help="ISO 3166-1 alpha-2 country code (e.g., MY, SG, ID)",
    )
    country_name = fields.Char(
        string="Country Name",
        required=True,
        help="Full country name in English",
    )
    sequence = fields.Integer(
        string="Sequence",
        default=10,
        help="Display order (Malaysia Hub = 1)",
    )

    # Localization
    currency_code = fields.Char(
        string="Currency Code",
        required=True,
        size=3,
        help="ISO 4217 currency code (e.g., MYR, SGD, IDR)",
    )
    currency_id = fields.Many2one(
        comodel_name="res.currency",
        string="Currency",
        help="Odoo currency record",
    )
    default_locale = fields.Char(
        string="Default Locale",
        help="Default locale code (e.g., ms_MY, id_ID)",
    )
    timezone = fields.Char(
        string="Timezone",
        default="Asia/Kuala_Lumpur",
        help="IANA timezone identifier",
    )

    # Data Routing (CRITICAL per CLAUDE.md)
    vps_ip = fields.Char(
        string="VPS IP Address",
        help="WireGuard VPN IP for this country data storage",
    )
    db_alias = fields.Char(
        string="Database Alias",
        help="Database router alias (e.g., default, singapore, indonesia)",
    )
    routes_to = fields.Char(
        string="Routes To",
        help="If shared VPS, which country hosts the data (e.g., LA→TH)",
    )
    data_residency_required = fields.Boolean(
        string="Data Residency Required",
        default=False,
        help="If True, employee data MUST be stored locally (ID, VN mandatory)",
    )

    # Statutory Settings
    ic_format_regex = fields.Char(
        string="IC Format (Regex)",
        help="Regular expression for validating national ID format",
    )
    ic_format_example = fields.Char(
        string="IC Format Example",
        help="Example of valid IC format for user reference",
    )
    has_epf_equivalent = fields.Boolean(
        string="Has EPF Equivalent",
        default=True,
        help="Country has mandatory provident fund",
    )
    has_social_security = fields.Boolean(
        string="Has Social Security",
        default=True,
        help="Country has social security system",
    )

    # Status
    is_active = fields.Boolean(
        string="Active",
        default=True,
        help="If False, country is disabled for new employees",
    )
    is_hub = fields.Boolean(
        string="Is Hub Country",
        default=False,
        help="Malaysia is the hub country",
    )

    # SQL Constraints
    _sql_constraints = [
        ("country_code_unique", "UNIQUE(country_code)", "Country code must be unique!"),
    ]

    @api.constrains("country_code")
    def _check_country_code(self):
        """Validate country code is one of supported ASEAN countries"""
        valid_codes = ["MY", "SG", "ID", "TH", "VN", "PH", "LA", "KH", "BN"]
        for record in self:
            if record.country_code and record.country_code.upper() not in valid_codes:
                raise ValidationError(
                    f"Invalid country code: {record.country_code}. "
                    f'Must be one of: {", ".join(valid_codes)}'
                )

    @api.model
    def get_routing_info(self, country_code):
        """
        Get data routing information for a country.

        Returns dict with VPS IP and database alias for the country.
        Handles shared VPS routing (e.g., Laos → Thailand).
        """
        config = self.search([("country_code", "=", country_code)], limit=1)
        if not config:
            # Default to Malaysia Hub
            return {"vps_ip": "10.10.0.1", "db_alias": "default"}

        # If routes to another country, get that country's config
        if config.routes_to:
            target = self.search([("country_code", "=", config.routes_to)], limit=1)
            if target:
                return {
                    "vps_ip": target.vps_ip or "10.10.0.1",
                    "db_alias": target.db_alias or "default",
                }

        return {"vps_ip": config.vps_ip or "10.10.0.1", "db_alias": config.db_alias or "default"}
