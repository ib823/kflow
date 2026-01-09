import 'package:huawei_hmsavailability/huawei_hmsavailability.dart';
import 'package:logger/logger.dart';

/// HMS availability check service
/// Determines if Huawei Mobile Services are available on the device
class HmsAvailability {
  final Logger _logger = Logger();
  final HmsApiAvailability _hmsApiAvailability = HmsApiAvailability();

  bool _isHmsAvailable = false;
  int _errorCode = -1;

  /// Whether HMS is available on this device
  bool get isHmsAvailable => _isHmsAvailable;

  /// Error code from availability check (0 = available)
  int get errorCode => _errorCode;

  /// Check if HMS services are available
  Future<bool> checkAvailability() async {
    try {
      _errorCode = await _hmsApiAvailability.isHMSAvailable();
      _isHmsAvailable = _errorCode == 0;

      if (_isHmsAvailable) {
        _logger.i('HMS services available');
      } else {
        _logger.w('HMS services not available, error code: $_errorCode');
      }

      return _isHmsAvailable;
    } catch (e) {
      _logger.e('Error checking HMS availability: $e');
      _isHmsAvailable = false;
      _errorCode = -1;
      return false;
    }
  }

  /// Get readable error message for HMS availability status
  String getErrorMessage() {
    switch (_errorCode) {
      case 0:
        return 'HMS services available';
      case 1:
        return 'HMS services missing';
      case 2:
        return 'HMS services update required';
      case 3:
        return 'HMS services disabled';
      case 9:
        return 'HMS services invalid';
      case 21:
        return 'Device not supported';
      default:
        return 'Unknown error: $_errorCode';
    }
  }

  /// Prompt user to resolve HMS availability issues
  Future<void> resolveAvailabilityIssue() async {
    if (_errorCode != 0) {
      try {
        await _hmsApiAvailability.getErrorDialog(_errorCode);
      } catch (e) {
        _logger.e('Error showing HMS resolution dialog: $e');
      }
    }
  }
}
