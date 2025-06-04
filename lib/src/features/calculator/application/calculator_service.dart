
enum Gender { male, female }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

enum Goal { lose, maintain, gain }

class CalculatorService {
  // BMI Hesaplama
  double calculateBMI(double weightKg, double heightCm) {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100.0;
    return weightKg / (heightM * heightM);
  }

  // BMI Kategorisi
  String getBmiCategory(double bmi) {
    if (bmi <= 0) return "-";
    if (bmi < 18.5) return "Zayıf";
    if (bmi < 24.9) return "Normal";
    if (bmi < 29.9) return "Fazla Kilolu";
    return "Obez";
  }

  // BMR Hesaplama (Mifflin-St Jeor)
  double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required Gender gender,
  }) {
    if (weightKg <= 0 || heightCm <= 0 || age <= 0) return 0;
    if (gender == Gender.male) {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  // Aktivite Faktörleri
  double _getActivityFactor(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
      case ActivityLevel.veryActive:
        return 1.9;
    }
  }

  // TDEE Hesaplama
  double calculateTDEE({
    required double bmr,
    required ActivityLevel activityLevel,
  }) {
    if (bmr <= 0) return 0;
    return bmr * _getActivityFactor(activityLevel);
  }

  // Hedefe Göre Kalori Ayarlaması
  double calculateTargetCalories({required double tdee, required Goal goal}) {
    if (tdee <= 0) return 0;
    switch (goal) {
      case Goal.lose:
        return tdee - 500; // Örnek: 500 kalori açık
      case Goal.maintain:
        return tdee;
      case Goal.gain:
        return tdee + 500; // Örnek: 500 kalori fazla
    }
  }

  // Makro Hesaplama
  Map<String, double> calculateMacros({
    required double targetCalories,
    required Goal goal,
  }) {
    if (targetCalories <= 0) {
      return {'protein': 0, 'carbs': 0, 'fat': 0};
    }

    double proteinPercent, carbsPercent, fatPercent;

    // Hedefe göre makro yüzdeleri (bu yüzdeler kişiselleştirilebilir)
    switch (goal) {
      case Goal.lose:
        proteinPercent = 0.40;
        carbsPercent = 0.30;
        fatPercent = 0.30;
        break;
      case Goal.maintain:
        proteinPercent = 0.30;
        carbsPercent = 0.40;
        fatPercent = 0.30;
        break;
      case Goal.gain:
        proteinPercent = 0.30;
        carbsPercent = 0.50;
        fatPercent = 0.20;
        break;
    }

    final proteinGrams =
        (targetCalories * proteinPercent) / 4; // 1g protein = 4 kcal
    final carbsGrams =
        (targetCalories * carbsPercent) / 4; // 1g karbonhidrat = 4 kcal
    final fatGrams = (targetCalories * fatPercent) / 9; // 1g yağ = 9 kcal

    return {'protein': proteinGrams, 'carbs': carbsGrams, 'fat': fatGrams};
  }
}
