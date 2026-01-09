import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';

/// User settings notifier
class UserSettingsNotifier extends StateNotifier<UserSettings> {
  UserSettingsNotifier() : super(const UserSettings());

  /// Update language
  void setLanguage(String languageCode) {
    state = state.copyWith(languageCode: languageCode);
    _saveSettings();
  }

  /// Update theme mode
  void setThemeMode(String themeMode) {
    state = state.copyWith(themeMode: themeMode);
    _saveSettings();
  }

  /// Toggle biometrics
  void setBiometricsEnabled(bool enabled) {
    state = state.copyWith(biometricsEnabled: enabled);
    _saveSettings();
  }

  /// Toggle notifications
  void setNotificationsEnabled(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
    _saveSettings();
  }

  /// Toggle auto-lock
  void setAutoLockEnabled(bool enabled) {
    state = state.copyWith(autoLockEnabled: enabled);
    _saveSettings();
  }

  /// Set auto-lock timeout
  void setAutoLockMinutes(int minutes) {
    state = state.copyWith(autoLockMinutes: minutes);
    _saveSettings();
  }

  /// Load settings from storage
  Future<void> loadSettings() async {
    // TODO: Load from Hive/SecureStorage
    // final box = await Hive.openBox('settings');
    // final saved = box.get('userSettings');
    // if (saved != null) {
    //   state = UserSettings.fromJson(Map<String, dynamic>.from(saved));
    // }
  }

  /// Save settings to storage
  Future<void> _saveSettings() async {
    // TODO: Save to Hive/SecureStorage
    // final box = await Hive.openBox('settings');
    // await box.put('userSettings', state.toJson());
  }
}

/// User settings provider
final userSettingsProvider =
    StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
  final notifier = UserSettingsNotifier();
  notifier.loadSettings();
  return notifier;
});

/// Language code provider (derived)
final languageCodeProvider = Provider<String>((ref) {
  return ref.watch(userSettingsProvider).languageCode;
});

/// Theme mode provider (derived)
final themeModeProvider = Provider<String>((ref) {
  return ref.watch(userSettingsProvider).themeMode;
});

/// Biometrics enabled provider (derived)
final biometricsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(userSettingsProvider).biometricsEnabled;
});
