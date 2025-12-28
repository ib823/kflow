/// Statutory contribution terms for ASEAN countries.
///
/// CRITICAL: These terms are preserved as official acronyms and should NOT
/// be translated or localized. The English acronym is always displayed,
/// with the local language description in parentheses.
///
/// Example: "EPF (Kumpulan Wang Simpanan Pekerja)"
///
/// This approach ensures:
/// 1. Legal compliance - official government terminology
/// 2. Payslip accuracy - matches official documents
/// 3. User recognition - workers familiar with official acronyms
/// 4. Cross-border clarity - migrant workers recognize home country terms
class StatutoryTerms {
  StatutoryTerms._();

  // ==========================================================================
  // MALAYSIA (MY)
  // ==========================================================================

  /// EPF - Employees Provident Fund / KWSP - Kumpulan Wang Simpanan Pekerja
  static const String epfAcronym = 'EPF';
  static const String kwspAcronym = 'KWSP';

  /// SOCSO - Social Security Organization / PERKESO - Pertubuhan Keselamatan Sosial
  static const String socsoAcronym = 'SOCSO';
  static const String perkesoAcronym = 'PERKESO';

  /// EIS - Employment Insurance System / SIP - Sistem Insurans Pekerjaan
  static const String eisAcronym = 'EIS';
  static const String sipAcronym = 'SIP';

  /// PCB - Potongan Cukai Bulanan / MTD - Monthly Tax Deduction
  static const String pcbAcronym = 'PCB';
  static const String mtdAcronym = 'MTD';

  /// HRDF - Human Resources Development Fund
  static const String hrdfAcronym = 'HRDF';

  // ==========================================================================
  // SINGAPORE (SG)
  // ==========================================================================

  /// CPF - Central Provident Fund
  static const String cpfAcronym = 'CPF';

  /// CPF OA - Ordinary Account
  static const String cpfOaAcronym = 'CPF-OA';

  /// CPF SA - Special Account
  static const String cpfSaAcronym = 'CPF-SA';

  /// CPF MA - Medisave Account
  static const String cpfMaAcronym = 'CPF-MA';

  /// SDL - Skills Development Levy
  static const String sdlAcronym = 'SDL';

  /// FWL - Foreign Worker Levy
  static const String fwlAcronym = 'FWL';

  // ==========================================================================
  // INDONESIA (ID)
  // ==========================================================================

  /// BPJS - Badan Penyelenggara Jaminan Sosial
  static const String bpjsAcronym = 'BPJS';

  /// BPJS TK - BPJS Ketenagakerjaan (Employment)
  static const String bpjsTkAcronym = 'BPJS-TK';

  /// BPJS Kesehatan (Health)
  static const String bpjsKesAcronym = 'BPJS-Kes';

  /// JHT - Jaminan Hari Tua (Old Age Security)
  static const String jhtAcronym = 'JHT';

  /// JKK - Jaminan Kecelakaan Kerja (Work Accident Insurance)
  static const String jkkAcronym = 'JKK';

  /// JKM - Jaminan Kematian (Death Insurance)
  static const String jkmAcronym = 'JKM';

  /// JP - Jaminan Pensiun (Pension)
  static const String jpAcronym = 'JP';

  /// PPh 21 - Income Tax
  static const String pph21Acronym = 'PPh 21';

  // ==========================================================================
  // THAILAND (TH)
  // ==========================================================================

  /// SSF - Social Security Fund
  static const String ssfAcronym = 'SSF';

  /// PVD - Provident Fund (optional)
  static const String pvdAcronym = 'PVD';

  /// PIT - Personal Income Tax
  static const String pitAcronym = 'PIT';

  // ==========================================================================
  // PHILIPPINES (PH)
  // ==========================================================================

  /// SSS - Social Security System
  static const String sssAcronym = 'SSS';

  /// GSIS - Government Service Insurance System
  static const String gsisAcronym = 'GSIS';

  /// PhilHealth - Philippine Health Insurance Corporation
  static const String philHealthAcronym = 'PhilHealth';

  /// Pag-IBIG - HDMF (Home Development Mutual Fund)
  static const String pagIbigAcronym = 'Pag-IBIG';
  static const String hdmfAcronym = 'HDMF';

  /// BIR - Bureau of Internal Revenue (Tax)
  static const String birAcronym = 'BIR';

  // ==========================================================================
  // VIETNAM (VN)
  // ==========================================================================

  /// BHXH - Social Insurance (Bao Hiem Xa Hoi)
  static const String bhxhAcronym = 'BHXH';

  /// BHYT - Health Insurance (Bao Hiem Y Te)
  static const String bhytAcronym = 'BHYT';

  /// BHTN - Unemployment Insurance (Bao Hiem That Nghiep)
  static const String bhtnAcronym = 'BHTN';

  /// KPCD - Trade Union Fee (Kinh Phi Cong Doan)
  static const String kpcdAcronym = 'KPCD';

  /// PIT - Personal Income Tax (Thue TNCN)
  static const String vnPitAcronym = 'PIT';

  // ==========================================================================
  // CAMBODIA (KH)
  // ==========================================================================

  /// NSSF - National Social Security Fund
  static const String nssfAcronym = 'NSSF';

  // ==========================================================================
  // MYANMAR (MM)
  // ==========================================================================

  /// SSB - Social Security Board
  static const String ssbAcronym = 'SSB';

  // ==========================================================================
  // BRUNEI (BN)
  // ==========================================================================

  /// TAP - Tabung Amanah Pekerja (Employees Trust Fund)
  static const String tapAcronym = 'TAP';

  /// SCP - Supplemental Contributory Pension
  static const String scpAcronym = 'SCP';

  // ==========================================================================
  // LAOS (LA)
  // ==========================================================================

  /// LSSO - Lao Social Security Organization
  static const String lssoAcronym = 'LSSO';

  // ==========================================================================
  // STATUTORY TERM MAPPINGS BY COUNTRY
  // ==========================================================================

  /// Get all statutory contribution types for a country
  static List<StatutoryContribution> getContributionsForCountry(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'MY':
        return [
          const StatutoryContribution(
            acronym: 'EPF',
            localAcronym: 'KWSP',
            type: ContributionType.providentFund,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
          const StatutoryContribution(
            acronym: 'SOCSO',
            localAcronym: 'PERKESO',
            type: ContributionType.socialSecurity,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
          const StatutoryContribution(
            acronym: 'EIS',
            localAcronym: 'SIP',
            type: ContributionType.employmentInsurance,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
          const StatutoryContribution(
            acronym: 'PCB',
            localAcronym: 'MTD',
            type: ContributionType.incomeTax,
            hasEmployeeContribution: true,
            hasEmployerContribution: false,
          ),
        ];

      case 'SG':
        return [
          const StatutoryContribution(
            acronym: 'CPF',
            type: ContributionType.providentFund,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
          const StatutoryContribution(
            acronym: 'SDL',
            type: ContributionType.skillsLevy,
            hasEmployeeContribution: false,
            hasEmployerContribution: true,
          ),
        ];

      case 'ID':
        return [
          const StatutoryContribution(
            acronym: 'BPJS-TK',
            type: ContributionType.socialSecurity,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
          const StatutoryContribution(
            acronym: 'BPJS-Kes',
            type: ContributionType.healthInsurance,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
          const StatutoryContribution(
            acronym: 'PPh 21',
            type: ContributionType.incomeTax,
            hasEmployeeContribution: true,
            hasEmployerContribution: false,
          ),
        ];

      case 'TH':
        return [
          const StatutoryContribution(
            acronym: 'SSF',
            type: ContributionType.socialSecurity,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
        ];

      case 'PH':
        return [
          const StatutoryContribution(
            acronym: 'SSS',
            type: ContributionType.socialSecurity,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
          const StatutoryContribution(
            acronym: 'PhilHealth',
            type: ContributionType.healthInsurance,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
          const StatutoryContribution(
            acronym: 'Pag-IBIG',
            localAcronym: 'HDMF',
            type: ContributionType.providentFund,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
        ];

      case 'VN':
        return [
          const StatutoryContribution(
            acronym: 'BHXH',
            type: ContributionType.socialSecurity,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
          const StatutoryContribution(
            acronym: 'BHYT',
            type: ContributionType.healthInsurance,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
          const StatutoryContribution(
            acronym: 'BHTN',
            type: ContributionType.employmentInsurance,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
        ];

      case 'KH':
        return [
          const StatutoryContribution(
            acronym: 'NSSF',
            type: ContributionType.socialSecurity,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
        ];

      case 'MM':
        return [
          const StatutoryContribution(
            acronym: 'SSB',
            type: ContributionType.socialSecurity,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
        ];

      case 'BN':
        return [
          const StatutoryContribution(
            acronym: 'TAP',
            type: ContributionType.providentFund,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
          const StatutoryContribution(
            acronym: 'SCP',
            type: ContributionType.pension,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
        ];

      case 'LA':
        return [
          const StatutoryContribution(
            acronym: 'LSSO',
            type: ContributionType.socialSecurity,
            hasEmployeeContribution: true,
            hasEmployerContribution: true,
          ),
        ];

      default:
        return [];
    }
  }

  /// Get display label for a statutory contribution
  ///
  /// Format: "ACRONYM (Local Description)"
  /// Example: "EPF (Caruman KWSP)" for Malay
  static String getDisplayLabel(
    String acronym, {
    String? localAcronym,
    String? localDescription,
  }) {
    final buffer = StringBuffer(acronym);

    if (localAcronym != null && localAcronym.isNotEmpty) {
      buffer.write(' / $localAcronym');
    }

    if (localDescription != null && localDescription.isNotEmpty) {
      buffer.write(' ($localDescription)');
    }

    return buffer.toString();
  }
}

/// Type of statutory contribution
enum ContributionType {
  providentFund,        // EPF, CPF, TAP, Pag-IBIG
  socialSecurity,       // SOCSO, SSS, SSF, NSSF, BPJS-TK
  healthInsurance,      // PhilHealth, BPJS-Kes
  employmentInsurance,  // EIS, BHTN
  pension,              // SCP, JP
  incomeTax,            // PCB, PPh 21, PIT
  skillsLevy,           // SDL, HRDF
}

/// Represents a statutory contribution type
class StatutoryContribution {
  final String acronym;
  final String? localAcronym;
  final ContributionType type;
  final bool hasEmployeeContribution;
  final bool hasEmployerContribution;

  const StatutoryContribution({
    required this.acronym,
    this.localAcronym,
    required this.type,
    required this.hasEmployeeContribution,
    required this.hasEmployerContribution,
  });

  /// Primary display acronym
  String get displayAcronym => localAcronym ?? acronym;

  /// Full display with both acronyms if available
  String get fullAcronym {
    if (localAcronym != null && localAcronym!.isNotEmpty) {
      return '$acronym / $localAcronym';
    }
    return acronym;
  }
}

/// Localized descriptions for statutory contributions
///
/// These are the translated descriptions that appear after the acronym.
/// The acronym itself is NEVER translated.
class StatutoryDescriptions {
  StatutoryDescriptions._();

  // Malaysia EPF descriptions by language
  static const Map<String, String> epfDescriptions = {
    'en': 'Employees Provident Fund',
    'ms': 'Kumpulan Wang Simpanan Pekerja',
    'zh': '雇员公积金',
    'ta': 'தொழிலாளர் வருங்கால வைப்பு நிதி',
    'bn': 'কর্মচারী ভবিষ্য তহবিল',
    'ne': 'कर्मचारी भविष्य निधि',
  };

  // Malaysia SOCSO descriptions by language
  static const Map<String, String> socsoDescriptions = {
    'en': 'Social Security Organization',
    'ms': 'Pertubuhan Keselamatan Sosial',
    'zh': '社会保障机构',
    'ta': 'சமூக பாதுகாப்பு அமைப்பு',
    'bn': 'সামাজিক নিরাপত্তা সংস্থা',
    'ne': 'सामाजिक सुरक्षा संगठन',
  };

  // Malaysia EIS descriptions by language
  static const Map<String, String> eisDescriptions = {
    'en': 'Employment Insurance System',
    'ms': 'Sistem Insurans Pekerjaan',
    'zh': '就业保险制度',
    'ta': 'வேலைவாய்ப்பு காப்பீட்டு அமைப்பு',
    'bn': 'কর্মসংস্থান বীমা ব্যবস্থা',
    'ne': 'रोजगार बीमा प्रणाली',
  };

  // Singapore CPF descriptions by language
  static const Map<String, String> cpfDescriptions = {
    'en': 'Central Provident Fund',
    'zh': '中央公积金',
    'ta': 'மத்திய சேம நிதி',
    'ms': 'Kumpulan Wang Simpanan Pusat',
  };

  // Indonesia BPJS descriptions by language
  static const Map<String, String> bpjsDescriptions = {
    'en': 'Social Security Administrator',
    'id': 'Badan Penyelenggara Jaminan Sosial',
  };

  // Philippines SSS descriptions by language
  static const Map<String, String> sssDescriptions = {
    'en': 'Social Security System',
    'tl': 'Sistemang Panlipunang Seguridad',
  };

  // Philippines PhilHealth descriptions by language
  static const Map<String, String> philHealthDescriptions = {
    'en': 'Philippine Health Insurance Corporation',
    'tl': 'Korporasyon ng Segurong Pangkalusugan ng Pilipinas',
  };

  // Philippines Pag-IBIG descriptions by language
  static const Map<String, String> pagIbigDescriptions = {
    'en': 'Home Development Mutual Fund',
    'tl': 'Pondo sa Pagtitipid ng mga Manggagawa',
  };

  // Thailand SSF descriptions by language
  static const Map<String, String> ssfDescriptions = {
    'en': 'Social Security Fund',
    'th': 'กองทุนประกันสังคม',
  };

  // Vietnam BHXH descriptions by language
  static const Map<String, String> bhxhDescriptions = {
    'en': 'Social Insurance',
    'vi': 'Bảo hiểm xã hội',
  };

  // Cambodia NSSF descriptions by language
  static const Map<String, String> nssfDescriptions = {
    'en': 'National Social Security Fund',
    'km': 'មូលនិធិជាតិសន្តិសុខសង្គម',
  };

  // Myanmar SSB descriptions by language
  static const Map<String, String> ssbDescriptions = {
    'en': 'Social Security Board',
    'my': 'လူမှုဖူလုံရေးအဖွဲ့',
  };

  // Brunei TAP descriptions by language
  static const Map<String, String> tapDescriptions = {
    'en': 'Employees Trust Fund',
    'ms': 'Tabung Amanah Pekerja',
  };

  // Laos LSSO descriptions by language
  static const Map<String, String> lssoDescriptions = {
    'en': 'Lao Social Security Organization',
    'lo': 'ອົງການປະກັນສັງຄົມລາວ',
  };

  /// Get localized description for a statutory term
  static String? getDescription(String acronym, String languageCode) {
    switch (acronym.toUpperCase()) {
      case 'EPF':
      case 'KWSP':
        return epfDescriptions[languageCode];
      case 'SOCSO':
      case 'PERKESO':
        return socsoDescriptions[languageCode];
      case 'EIS':
      case 'SIP':
        return eisDescriptions[languageCode];
      case 'CPF':
        return cpfDescriptions[languageCode];
      case 'BPJS':
      case 'BPJS-TK':
      case 'BPJS-KES':
        return bpjsDescriptions[languageCode];
      case 'SSS':
        return sssDescriptions[languageCode];
      case 'PHILHEALTH':
        return philHealthDescriptions[languageCode];
      case 'PAG-IBIG':
      case 'HDMF':
        return pagIbigDescriptions[languageCode];
      case 'SSF':
        return ssfDescriptions[languageCode];
      case 'BHXH':
        return bhxhDescriptions[languageCode];
      case 'NSSF':
        return nssfDescriptions[languageCode];
      case 'SSB':
        return ssbDescriptions[languageCode];
      case 'TAP':
        return tapDescriptions[languageCode];
      case 'LSSO':
        return lssoDescriptions[languageCode];
      default:
        return null;
    }
  }
}
