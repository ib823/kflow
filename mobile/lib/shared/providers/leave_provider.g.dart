// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$leaveBalancesHash() => r'6a77006deb2dd4e66a29008b29e171bfb83e4c3c';

/// Provider for leave balances only (lighter weight)
///
/// Copied from [leaveBalances].
@ProviderFor(leaveBalances)
final leaveBalancesProvider =
    AutoDisposeFutureProvider<List<LeaveBalance>>.internal(
  leaveBalances,
  name: r'leaveBalancesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$leaveBalancesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LeaveBalancesRef = AutoDisposeFutureProviderRef<List<LeaveBalance>>;
String _$leaveRequestsHash() => r'be5a569ffd6141f675a5d5d126d21cc6904e486e';

/// Provider for leave requests only
///
/// Copied from [leaveRequests].
@ProviderFor(leaveRequests)
final leaveRequestsProvider =
    AutoDisposeFutureProvider<List<LeaveRequest>>.internal(
  leaveRequests,
  name: r'leaveRequestsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$leaveRequestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LeaveRequestsRef = AutoDisposeFutureProviderRef<List<LeaveRequest>>;
String _$leaveTypesHash() => r'd474edba375230981ce66c57f55d9465901eb06d';

/// Provider for leave types only
///
/// Copied from [leaveTypes].
@ProviderFor(leaveTypes)
final leaveTypesProvider = AutoDisposeFutureProvider<List<LeaveType>>.internal(
  leaveTypes,
  name: r'leaveTypesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$leaveTypesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LeaveTypesRef = AutoDisposeFutureProviderRef<List<LeaveType>>;
String _$leaveNotifierHash() => r'd7123dfaaaa55248209956e27d94e01aa26450a9';

/// See also [LeaveNotifier].
@ProviderFor(LeaveNotifier)
final leaveNotifierProvider =
    AutoDisposeAsyncNotifierProvider<LeaveNotifier, LeaveState>.internal(
  LeaveNotifier.new,
  name: r'leaveNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$leaveNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LeaveNotifier = AutoDisposeAsyncNotifier<LeaveState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
