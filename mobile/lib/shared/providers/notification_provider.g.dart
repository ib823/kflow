// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unreadNotificationCountHash() =>
    r'684c19ceaedffa46398fc433b98a2408b75247da';

/// Provider for unread count (badge display)
///
/// Copied from [unreadNotificationCount].
@ProviderFor(unreadNotificationCount)
final unreadNotificationCountProvider = AutoDisposeFutureProvider<int>.internal(
  unreadNotificationCount,
  name: r'unreadNotificationCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadNotificationCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadNotificationCountRef = AutoDisposeFutureProviderRef<int>;
String _$notificationsByTypeHash() =>
    r'43ac427984855eb5afe1b3f4514294be17373cca';

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

/// Provider for filtering notifications by type
///
/// Copied from [notificationsByType].
@ProviderFor(notificationsByType)
const notificationsByTypeProvider = NotificationsByTypeFamily();

/// Provider for filtering notifications by type
///
/// Copied from [notificationsByType].
class NotificationsByTypeFamily
    extends Family<AsyncValue<List<AppNotification>>> {
  /// Provider for filtering notifications by type
  ///
  /// Copied from [notificationsByType].
  const NotificationsByTypeFamily();

  /// Provider for filtering notifications by type
  ///
  /// Copied from [notificationsByType].
  NotificationsByTypeProvider call(
    String type,
  ) {
    return NotificationsByTypeProvider(
      type,
    );
  }

  @override
  NotificationsByTypeProvider getProviderOverride(
    covariant NotificationsByTypeProvider provider,
  ) {
    return call(
      provider.type,
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
  String? get name => r'notificationsByTypeProvider';
}

/// Provider for filtering notifications by type
///
/// Copied from [notificationsByType].
class NotificationsByTypeProvider
    extends AutoDisposeFutureProvider<List<AppNotification>> {
  /// Provider for filtering notifications by type
  ///
  /// Copied from [notificationsByType].
  NotificationsByTypeProvider(
    String type,
  ) : this._internal(
          (ref) => notificationsByType(
            ref as NotificationsByTypeRef,
            type,
          ),
          from: notificationsByTypeProvider,
          name: r'notificationsByTypeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$notificationsByTypeHash,
          dependencies: NotificationsByTypeFamily._dependencies,
          allTransitiveDependencies:
              NotificationsByTypeFamily._allTransitiveDependencies,
          type: type,
        );

  NotificationsByTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
  }) : super.internal();

  final String type;

  @override
  Override overrideWith(
    FutureOr<List<AppNotification>> Function(NotificationsByTypeRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NotificationsByTypeProvider._internal(
        (ref) => create(ref as NotificationsByTypeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<AppNotification>> createElement() {
    return _NotificationsByTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationsByTypeProvider && other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NotificationsByTypeRef
    on AutoDisposeFutureProviderRef<List<AppNotification>> {
  /// The parameter `type` of this provider.
  String get type;
}

class _NotificationsByTypeProviderElement
    extends AutoDisposeFutureProviderElement<List<AppNotification>>
    with NotificationsByTypeRef {
  _NotificationsByTypeProviderElement(super.provider);

  @override
  String get type => (origin as NotificationsByTypeProvider).type;
}

String _$notificationNotifierHash() =>
    r'dc6e837332f1b9a2b8ffaf1cb51dc35712cee76a';

/// See also [NotificationNotifier].
@ProviderFor(NotificationNotifier)
final notificationNotifierProvider = AutoDisposeAsyncNotifierProvider<
    NotificationNotifier, NotificationState>.internal(
  NotificationNotifier.new,
  name: r'notificationNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationNotifier = AutoDisposeAsyncNotifier<NotificationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
