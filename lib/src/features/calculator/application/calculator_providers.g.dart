// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculator_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calculatorServiceHash() => r'f01b7c91482db3be7e05ef6c02b89584c5330fde';

/// See also [calculatorService].
@ProviderFor(calculatorService)
final calculatorServiceProvider =
    AutoDisposeProvider<CalculatorService>.internal(
      calculatorService,
      name: r'calculatorServiceProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$calculatorServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CalculatorServiceRef = AutoDisposeProviderRef<CalculatorService>;
String _$calculatorNotifierHash() =>
    r'f95f26600e9868449e53b96a62811a0d9d38ff1a';

/// See also [CalculatorNotifier].
@ProviderFor(CalculatorNotifier)
final calculatorNotifierProvider = AutoDisposeAsyncNotifierProvider<
  CalculatorNotifier,
  CalculatorState
>.internal(
  CalculatorNotifier.new,
  name: r'calculatorNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$calculatorNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CalculatorNotifier = AutoDisposeAsyncNotifier<CalculatorState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
