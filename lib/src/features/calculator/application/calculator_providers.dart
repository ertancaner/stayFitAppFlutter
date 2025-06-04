import 'package:flutter/foundation.dart'; // @immutable için
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stay_fit/src/features/calculator/application/calculator_service.dart';
import 'package:stay_fit/src/features/home/application/home_providers.dart'; // weightEntriesProvider için

part 'calculator_providers.g.dart';

// CalculatorService için provider
@riverpod
CalculatorService calculatorService(Ref ref) {
  return CalculatorService();
}

// Hesaplayıcı state'i için data class
// Not: freezed ile oluşturmak daha iyi olabilir ama şimdilik basit tutalım.
@immutable // State class'larının immutable olması önerilir.
class CalculatorState {
  final double? heightCm;
  final double? weightKg; // Ana sayfadan alınacak
  final int? age;
  final Gender? gender;
  final ActivityLevel activityLevel;
  final Goal goal;

  final double? bmi;
  final String? bmiCategory;
  final double? bmr;
  final double? tdee;
  final double? targetCalories;
  final Map<String, double>? macros;

  const CalculatorState({
    // const constructor
    this.heightCm,
    this.weightKg,
    this.age,
    this.gender,
    this.activityLevel = ActivityLevel.moderate, // Varsayılan
    this.goal = Goal.maintain, // Varsayılan
    this.bmi,
    this.bmiCategory,
    this.bmr,
    this.tdee,
    this.targetCalories,
    this.macros,
  });

  CalculatorState copyWith({
    // Nullable tipler için value anlamsız, doğrudan değeri alalım
    double? heightCm,
    double? weightKg,
    int? age,
    Gender? gender,
    ActivityLevel? activityLevel,
    Goal? goal,
    // Sonuçları nullable yapalım ki temizlenebilsin
    double? bmi,
    String? bmiCategory,
    double? bmr,
    double? tdee,
    double? targetCalories,
    Map<String, double>? macros,
    bool clearResults = false, // Sonuçları temizlemek için flag
  }) {
    return CalculatorState(
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      // clearResults true ise null ata, değilse yeni değeri veya eski değeri koru
      bmi: clearResults ? null : (bmi ?? this.bmi),
      bmiCategory: clearResults ? null : (bmiCategory ?? this.bmiCategory),
      bmr: clearResults ? null : (bmr ?? this.bmr),
      tdee: clearResults ? null : (tdee ?? this.tdee),
      targetCalories:
          clearResults ? null : (targetCalories ?? this.targetCalories),
      macros: clearResults ? null : (macros ?? this.macros),
    );
  }
}

// Hesaplayıcı Notifier'ı
@riverpod
class CalculatorNotifier extends _$CalculatorNotifier {
  @override
  Future<CalculatorState> build() async {
    // Başlangıçta ana sayfadaki son kiloyu al
    // ref'i doğrudan kullanabiliriz
    final weightEntries = await ref.watch(weightEntriesProvider.future);
    final lastWeight =
        weightEntries.isNotEmpty ? weightEntries.first.weight : null;
    // Başlangıç state'ini döndür
    return CalculatorState(weightKg: lastWeight);
  }

  // Girdi değerlerini güncelleme metotları
  void updateHeight(double? height) {
    // state'i doğrudan güncellemek yerine AsyncValue kontrolü yapalım
    // state zaten Future içerdiği için valueOrNull kullanmak daha güvenli
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncData(
        currentState.copyWith(heightCm: height, clearResults: true),
      );
    }
  }

  void updateAge(int? age) {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncData(currentState.copyWith(age: age, clearResults: true));
    }
  }

  void updateGender(Gender? gender) {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncData(
        currentState.copyWith(gender: gender, clearResults: true),
      );
    }
  }

  void updateActivityLevel(ActivityLevel level) {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncData(
        currentState.copyWith(activityLevel: level, clearResults: true),
      );
    }
  }

  void updateGoal(Goal goal) {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncData(currentState.copyWith(goal: goal, clearResults: true));
    }
  }

  // Hesaplama işlemini tetikleme
  Future<void> calculate() async {
    // state'in yüklenmesini bekle veya mevcut değeri al
    final currentState = state.valueOrNull;
    if (currentState == null) {
      // print("State henüz yüklenmedi."); // Veya kullanıcıya mesaj göster
      return;
    }

    // Gerekli tüm girdilerin dolu olduğundan emin ol
    if (currentState.heightCm == null ||
        currentState.weightKg == null ||
        currentState.age == null ||
        currentState.gender == null) {
      // Kullanıcıya eksik bilgi uyarısı gösterilebilir
      // print("Hesaplama için tüm bilgiler gerekli!");
      throw Exception(
          "Lütfen hesaplama için tüm bilgileri (boy, kilo, yaş, cinsiyet) girin.");
    }

    // Servisi ref üzerinden oku
    final service = ref.read(calculatorServiceProvider);

    // Hesaplamaları yap
    final bmi = service.calculateBMI(
      currentState.weightKg!,
      currentState.heightCm!,
    );
    final bmiCategory = service.getBmiCategory(bmi);
    final bmr = service.calculateBMR(
      weightKg: currentState.weightKg!,
      heightCm: currentState.heightCm!,
      age: currentState.age!,
      gender: currentState.gender!,
    );
    final tdee = service.calculateTDEE(
      bmr: bmr,
      activityLevel: currentState.activityLevel,
    );
    final targetCalories = service.calculateTargetCalories(
      tdee: tdee,
      goal: currentState.goal,
    );
    final macros = service.calculateMacros(
      targetCalories: targetCalories,
      goal: currentState.goal,
    );

    // State'i yeni sonuçlarla güncelle
    // state zaten AsyncValue olduğu için tekrar sarmalamaya gerek yok
    state = AsyncData(
      currentState.copyWith(
        bmi: bmi,
        bmiCategory: bmiCategory,
        bmr: bmr,
        tdee: tdee,
        targetCalories: targetCalories,
        macros: macros,
        clearResults: false, // Sonuçları temizleme flag'ini false yap
      ),
    );
  }
}
