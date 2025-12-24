// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payslip_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isPinVerifiedHash() => r'66dcffb4d7c61823f0f357f6abc295d564326127';

/// Provider for checking PIN verification status
///
/// Copied from [isPinVerified].
@ProviderFor(isPinVerified)
final isPinVerifiedProvider = AutoDisposeFutureProvider<bool>.internal(
  isPinVerified,
  name: r'isPinVerifiedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isPinVerifiedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsPinVerifiedRef = AutoDisposeFutureProviderRef<bool>;
String _$payslipNotifierHash() => r'c933031757ac5eab659de6b49e9783bf2d3f5550';

/// See also [PayslipNotifier].
@ProviderFor(PayslipNotifier)
final payslipNotifierProvider =
    AutoDisposeAsyncNotifierProvider<PayslipNotifier, PayslipState>.internal(
  PayslipNotifier.new,
  name: r'payslipNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$payslipNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PayslipNotifier = AutoDisposeAsyncNotifier<PayslipState>;
String _$payslipDetailNotifierHash() =>
    r'709c937ce3284718465430723373370212f0d96d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$PayslipDetailNotifier
    extends BuildlessAutoDisposeAsyncNotifier<PayslipDetail?> {
  late final int payslipId;

  FutureOr<PayslipDetail?> build(
    int payslipId,
  );
}

/// Provider for fetching a single payslip detail
///
/// Copied from [PayslipDetailNotifier].
@ProviderFor(PayslipDetailNotifier)
const payslipDetailNotifierProvider = PayslipDetailNotifierFamily();

/// Provider for fetching a single payslip detail
///
/// Copied from [PayslipDetailNotifier].
class PayslipDetailNotifierFamily extends Family<AsyncValue<PayslipDetail?>> {
  /// Provider for fetching a single payslip detail
  ///
  /// Copied from [PayslipDetailNotifier].
  const PayslipDetailNotifierFamily();

  /// Provider for fetching a single payslip detail
  ///
  /// Copied from [PayslipDetailNotifier].
  PayslipDetailNotifierProvider call(
    int payslipId,
  ) {
    return PayslipDetailNotifierProvider(
      payslipId,
    );
  }

  @override
  PayslipDetailNotifierProvider getProviderOverride(
    covariant PayslipDetailNotifierProvider provider,
  ) {
    return call(
      provider.payslipId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'payslipDetailNotifierProvider';
}

/// Provider for fetching a single payslip detail
///
/// Copied from [PayslipDetailNotifier].
class PayslipDetailNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<PayslipDetailNotifier,
        PayslipDetail?> {
  /// Provider for fetching a single payslip detail
  ///
  /// Copied from [PayslipDetailNotifier].
  PayslipDetailNotifierProvider(
    int payslipId,
  ) : this._internal(
          () => PayslipDetailNotifier()..payslipId = payslipId,
          from: payslipDetailNotifierProvider,
          name: r'payslipDetailNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$payslipDetailNotifierHash,
          dependencies: PayslipDetailNotifierFamily._dependencies,
          allTransitiveDependencies:
              PayslipDetailNotifierFamily._allTransitiveDependencies,
          payslipId: payslipId,
        );

  PayslipDetailNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.payslipId,
  }) : super.internal();

  final int payslipId;

  @override
  FutureOr<PayslipDetail?> runNotifierBuild(
    covariant PayslipDetailNotifier notifier,
  ) {
    return notifier.build(
      payslipId,
    );
  }

  @override
  Override overrideWith(PayslipDetailNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: PayslipDetailNotifierProvider._internal(
        () => create()..payslipId = payslipId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        payslipId: payslipId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PayslipDetailNotifier, PayslipDetail?>
      createElement() {
    return _PayslipDetailNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PayslipDetailNotifierProvider &&
        other.payslipId == payslipId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, payslipId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PayslipDetailNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<PayslipDetail?> {
  /// The parameter `payslipId` of this provider.
  int get payslipId;
}

class _PayslipDetailNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PayslipDetailNotifier,
        PayslipDetail?> with PayslipDetailNotifierRef {
  _PayslipDetailNotifierProviderElement(super.provider);

  @override
  int get payslipId => (origin as PayslipDetailNotifierProvider).payslipId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
