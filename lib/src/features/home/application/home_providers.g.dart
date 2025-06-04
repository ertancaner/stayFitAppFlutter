// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseHelperHash() => r'3c872a6be504a5942fbf7213cf260628ebc873ed';

/// See also [databaseHelper].
@ProviderFor(databaseHelper)
final databaseHelperProvider = Provider<DatabaseHelper>.internal(
  databaseHelper,
  name: r'databaseHelperProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$databaseHelperHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseHelperRef = ProviderRef<DatabaseHelper>;
String _$weightEntriesHash() => r'2edf4785ffdf30ebc430f5321bf824101e98d37b';

/// See also [weightEntries].
@ProviderFor(weightEntries)
final weightEntriesProvider =
    AutoDisposeStreamProvider<List<WeightEntry>>.internal(
      weightEntries,
      name: r'weightEntriesProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$weightEntriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeightEntriesRef = AutoDisposeStreamProviderRef<List<WeightEntry>>;
String _$targetWeightHash() => r'e0562953be590a02d88e85d227951c3ed1ffe74f';

/// See also [TargetWeight].
@ProviderFor(TargetWeight)
final targetWeightProvider =
    AutoDisposeAsyncNotifierProvider<TargetWeight, double?>.internal(
      TargetWeight.new,
      name: r'targetWeightProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$targetWeightHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TargetWeight = AutoDisposeAsyncNotifier<double?>;
String _$homeNotifierHash() => r'9ffa6f82fa6f8432383df6f8feac9d3195e584ec';

/// See also [HomeNotifier].
@ProviderFor(HomeNotifier)
final homeNotifierProvider =
    AutoDisposeAsyncNotifierProvider<HomeNotifier, void>.internal(
      HomeNotifier.new,
      name: r'homeNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$homeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
