import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/models.dart';

part 'auth_state.freezed.dart';

/// Authentication state
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.authenticated({
    required User user,
    required String accessToken,
    required String refreshToken,
  }) = AuthStateAuthenticated;
  const factory AuthState.unauthenticated({
    String? message,
  }) = AuthStateUnauthenticated;
  const factory AuthState.error({
    required String message,
  }) = AuthStateError;
}

/// PIN state
@freezed
class PinState with _$PinState {
  const factory PinState.notSet() = PinStateNotSet;
  const factory PinState.set() = PinStateSet;
  const factory PinState.verifying() = PinStateVerifying;
  const factory PinState.verified() = PinStateVerified;
  const factory PinState.failed({
    required int attemptsRemaining,
  }) = PinStateFailed;
  const factory PinState.locked({
    required DateTime unlockAt,
  }) = PinStateLocked;
}
