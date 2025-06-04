// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workoutLogsHash() => r'47d1c916746d8b7bdb346ef34e102494e0cd14bf';

/// See also [workoutLogs].
@ProviderFor(workoutLogs)
final workoutLogsProvider =
    AutoDisposeStreamProvider<List<WorkoutLog>>.internal(
      workoutLogs,
      name: r'workoutLogsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$workoutLogsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WorkoutLogsRef = AutoDisposeStreamProviderRef<List<WorkoutLog>>;
String _$workoutNotifierHash() => r'5e37f37dda7d4094d45d288422986e6516edadee';

/// See also [WorkoutNotifier].
@ProviderFor(WorkoutNotifier)
final workoutNotifierProvider =
    AutoDisposeAsyncNotifierProvider<WorkoutNotifier, void>.internal(
      WorkoutNotifier.new,
      name: r'workoutNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$workoutNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WorkoutNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
