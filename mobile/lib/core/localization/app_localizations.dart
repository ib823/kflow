import 'package:flutter/material.dart';

/// App localizations delegate and translations
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'KerjaFlow',
      'login': 'Login',
      'email': 'Email',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'home': 'Home',
      'leave': 'Leave',
      'payslip': 'Payslip',
      'profile': 'Profile',
      'notifications': 'Notifications',
      'apply_leave': 'Apply Leave',
      'leave_balance': 'Leave Balance',
      'leave_history': 'Leave History',
      'pending': 'Pending',
      'approved': 'Approved',
      'rejected': 'Rejected',
      'cancelled': 'Cancelled',
      'submit': 'Submit',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      'error': 'Error',
      'success': 'Success',
      'loading': 'Loading...',
      'no_data': 'No data available',
      'retry': 'Retry',
      'logout': 'Logout',
      'settings': 'Settings',
      'language': 'Language',
      'enter_pin': 'Enter PIN',
      'setup_pin': 'Setup PIN',
      'verify_pin': 'Verify PIN',
      'annual_leave': 'Annual Leave',
      'medical_leave': 'Medical Leave',
      'days': 'days',
      'day': 'day',
    },
    'ms': {
      'app_name': 'KerjaFlow',
      'login': 'Log Masuk',
      'email': 'Emel',
      'password': 'Kata Laluan',
      'forgot_password': 'Lupa Kata Laluan?',
      'home': 'Utama',
      'leave': 'Cuti',
      'payslip': 'Slip Gaji',
      'profile': 'Profil',
      'notifications': 'Pemberitahuan',
      'apply_leave': 'Mohon Cuti',
      'leave_balance': 'Baki Cuti',
      'leave_history': 'Sejarah Cuti',
      'pending': 'Menunggu',
      'approved': 'Diluluskan',
      'rejected': 'Ditolak',
      'cancelled': 'Dibatalkan',
      'submit': 'Hantar',
      'cancel': 'Batal',
      'save': 'Simpan',
      'delete': 'Padam',
      'confirm': 'Sahkan',
      'yes': 'Ya',
      'no': 'Tidak',
      'error': 'Ralat',
      'success': 'Berjaya',
      'loading': 'Memuatkan...',
      'no_data': 'Tiada data',
      'retry': 'Cuba Lagi',
      'logout': 'Log Keluar',
      'settings': 'Tetapan',
      'language': 'Bahasa',
      'enter_pin': 'Masukkan PIN',
      'setup_pin': 'Tetapkan PIN',
      'verify_pin': 'Sahkan PIN',
      'annual_leave': 'Cuti Tahunan',
      'medical_leave': 'Cuti Sakit',
      'days': 'hari',
      'day': 'hari',
    },
    'id': {
      'app_name': 'KerjaFlow',
      'login': 'Masuk',
      'email': 'Email',
      'password': 'Kata Sandi',
      'forgot_password': 'Lupa Kata Sandi?',
      'home': 'Beranda',
      'leave': 'Cuti',
      'payslip': 'Slip Gaji',
      'profile': 'Profil',
      'notifications': 'Notifikasi',
      'apply_leave': 'Ajukan Cuti',
      'leave_balance': 'Saldo Cuti',
      'leave_history': 'Riwayat Cuti',
      'pending': 'Menunggu',
      'approved': 'Disetujui',
      'rejected': 'Ditolak',
      'cancelled': 'Dibatalkan',
      'submit': 'Kirim',
      'cancel': 'Batal',
      'save': 'Simpan',
      'delete': 'Hapus',
      'confirm': 'Konfirmasi',
      'yes': 'Ya',
      'no': 'Tidak',
      'error': 'Kesalahan',
      'success': 'Berhasil',
      'loading': 'Memuat...',
      'no_data': 'Tidak ada data',
      'retry': 'Coba Lagi',
      'logout': 'Keluar',
      'settings': 'Pengaturan',
      'language': 'Bahasa',
      'enter_pin': 'Masukkan PIN',
      'setup_pin': 'Atur PIN',
      'verify_pin': 'Verifikasi PIN',
      'annual_leave': 'Cuti Tahunan',
      'medical_leave': 'Cuti Sakit',
      'days': 'hari',
      'day': 'hari',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
           _localizedValues['en']?[key] ??
           key;
  }

  // Convenience getters
  String get appName => translate('app_name');
  String get login => translate('login');
  String get email => translate('email');
  String get password => translate('password');
  String get forgotPassword => translate('forgot_password');
  String get home => translate('home');
  String get leave => translate('leave');
  String get payslip => translate('payslip');
  String get profile => translate('profile');
  String get notifications => translate('notifications');
  String get applyLeave => translate('apply_leave');
  String get leaveBalance => translate('leave_balance');
  String get leaveHistory => translate('leave_history');
  String get pending => translate('pending');
  String get approved => translate('approved');
  String get rejected => translate('rejected');
  String get cancelled => translate('cancelled');
  String get submit => translate('submit');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get confirm => translate('confirm');
  String get yes => translate('yes');
  String get no => translate('no');
  String get error => translate('error');
  String get success => translate('success');
  String get loading => translate('loading');
  String get noData => translate('no_data');
  String get retry => translate('retry');
  String get logout => translate('logout');
  String get settings => translate('settings');
  String get language => translate('language');
  String get enterPin => translate('enter_pin');
  String get setupPin => translate('setup_pin');
  String get verifyPin => translate('verify_pin');
  String get annualLeave => translate('annual_leave');
  String get medicalLeave => translate('medical_leave');
  String get days => translate('days');
  String get day => translate('day');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ms', 'id'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
