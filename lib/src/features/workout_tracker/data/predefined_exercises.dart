// Define muscle group categories (can be an enum or const strings)
class MuscleGroup {
  static const String gogus = 'Göğüs';
  static const String sirt = 'Sırt';
  static const String omuz = 'Omuz';
  static const String biceps = 'Biceps';
  static const String triceps = 'Triceps';
  static const String onKol = 'Ön Kol';
  static const String bacak = 'Bacak';
  static const String karin = 'Karın';
  static const String kardiyo = 'Kardiyo';
  static const String tumVucut = 'Tüm Vücut';
  static const String diger = 'Diğer';

  // Kategori listesi (filtreleme için kullanılabilir)
  static const List<String> categories = [
    gogus,
    sirt,
    omuz,
    biceps,
    triceps,
    onKol,
    bacak,
    karin,
    kardiyo,
    tumVucut,
    diger,
  ];
}

// Simple exercise definition structure for now
// Later, this might evolve into a full data model class
class PredefinedExercise {
  final String name;
  final String category;

  const PredefinedExercise({required this.name, required this.category});
}

const List<PredefinedExercise> predefinedExercises = [
  // Göğüs
  PredefinedExercise(
    name: 'Bench Press (Barbell)',
    category: MuscleGroup.gogus,
  ),
  PredefinedExercise(
    name: 'Incline Bench Press (Barbell)',
    category: MuscleGroup.gogus,
  ),
  PredefinedExercise(
    name: 'Decline Bench Press (Barbell)',
    category: MuscleGroup.gogus,
  ),
  PredefinedExercise(name: 'Dumbbell Press', category: MuscleGroup.gogus),
  PredefinedExercise(
    name: 'Incline Dumbbell Press',
    category: MuscleGroup.gogus,
  ),
  PredefinedExercise(
    name: 'Decline Dumbbell Press',
    category: MuscleGroup.gogus,
  ),
  PredefinedExercise(name: 'Chest Fly (Dumbbell)', category: MuscleGroup.gogus),
  PredefinedExercise(
    name: 'Incline Chest Fly (Dumbbell)',
    category: MuscleGroup.gogus,
  ),
  PredefinedExercise(name: 'Cable Crossover', category: MuscleGroup.gogus),
  PredefinedExercise(name: 'Chest Dip', category: MuscleGroup.gogus),
  PredefinedExercise(name: 'Push-up (Şınav)', category: MuscleGroup.gogus),
  PredefinedExercise(name: 'Machine Chest Press', category: MuscleGroup.gogus),
  PredefinedExercise(name: 'Pec Deck Machine', category: MuscleGroup.gogus),

  // Sırt
  PredefinedExercise(name: 'Pull-up (Barfiks)', category: MuscleGroup.sirt),
  PredefinedExercise(name: 'Chin-up', category: MuscleGroup.sirt),
  PredefinedExercise(name: 'Lat Pulldown', category: MuscleGroup.sirt),
  PredefinedExercise(name: 'Seated Cable Row', category: MuscleGroup.sirt),
  PredefinedExercise(
    name: 'Bent-over Row (Barbell)',
    category: MuscleGroup.sirt,
  ),
  PredefinedExercise(
    name: 'Bent-over Row (Dumbbell)',
    category: MuscleGroup.sirt,
  ),
  PredefinedExercise(name: 'T-Bar Row', category: MuscleGroup.sirt),
  PredefinedExercise(
    name: 'Deadlift',
    category: MuscleGroup.sirt,
  ), // Also Bacak/Tüm Vücut
  PredefinedExercise(
    name: 'Romanian Deadlift',
    category: MuscleGroup.sirt,
  ), // Also Bacak
  PredefinedExercise(
    name: 'Good Morning',
    category: MuscleGroup.sirt,
  ), // Also Bacak
  PredefinedExercise(name: 'Hyperextension', category: MuscleGroup.sirt),
  PredefinedExercise(name: 'Machine Row', category: MuscleGroup.sirt),
  PredefinedExercise(
    name: 'Single Arm Dumbbell Row',
    category: MuscleGroup.sirt,
  ),

  // Omuz
  PredefinedExercise(
    name: 'Overhead Press (Barbell)',
    category: MuscleGroup.omuz,
  ),
  PredefinedExercise(
    name: 'Overhead Press (Dumbbell)',
    category: MuscleGroup.omuz,
  ),
  PredefinedExercise(name: 'Arnold Press', category: MuscleGroup.omuz),
  PredefinedExercise(
    name: 'Lateral Raise (Dumbbell)',
    category: MuscleGroup.omuz,
  ),
  PredefinedExercise(
    name: 'Front Raise (Dumbbell)',
    category: MuscleGroup.omuz,
  ),
  PredefinedExercise(name: 'Reverse Pec Deck', category: MuscleGroup.omuz),
  PredefinedExercise(name: 'Face Pull', category: MuscleGroup.omuz),
  PredefinedExercise(name: 'Upright Row', category: MuscleGroup.omuz),
  PredefinedExercise(
    name: 'Shrugs (Barbell/Dumbbell)',
    category: MuscleGroup.omuz,
  ), // Also Trapezius
  PredefinedExercise(
    name: 'Machine Shoulder Press',
    category: MuscleGroup.omuz,
  ),

  // Biceps
  PredefinedExercise(
    name: 'Bicep Curl (Barbell)',
    category: MuscleGroup.biceps,
  ),
  PredefinedExercise(
    name: 'Bicep Curl (Dumbbell)',
    category: MuscleGroup.biceps,
  ),
  PredefinedExercise(name: 'Hammer Curl', category: MuscleGroup.biceps),
  PredefinedExercise(name: 'Concentration Curl', category: MuscleGroup.biceps),
  PredefinedExercise(name: 'Preacher Curl', category: MuscleGroup.biceps),
  PredefinedExercise(name: 'Cable Curl', category: MuscleGroup.biceps),
  PredefinedExercise(
    name: 'Incline Dumbbell Curl',
    category: MuscleGroup.biceps,
  ),

  // Triceps
  PredefinedExercise(
    name: 'Close-Grip Bench Press',
    category: MuscleGroup.triceps,
  ),
  PredefinedExercise(
    name: 'Triceps Pushdown (Cable)',
    category: MuscleGroup.triceps,
  ),
  PredefinedExercise(
    name: 'Overhead Triceps Extension (Dumbbell/Cable)',
    category: MuscleGroup.triceps,
  ),
  PredefinedExercise(
    name: 'Skullcrusher (Barbell/Dumbbell)',
    category: MuscleGroup.triceps,
  ),
  PredefinedExercise(name: 'Triceps Dip', category: MuscleGroup.triceps),
  PredefinedExercise(name: 'Triceps Kickback', category: MuscleGroup.triceps),
  PredefinedExercise(name: 'Rope Pushdown', category: MuscleGroup.triceps),

  // Ön Kol
  PredefinedExercise(name: 'Wrist Curl', category: MuscleGroup.onKol),
  PredefinedExercise(name: 'Reverse Wrist Curl', category: MuscleGroup.onKol),
  PredefinedExercise(
    name: 'Farmer\'s Walk',
    category: MuscleGroup.onKol,
  ), // Also Tüm Vücut
  // Bacak
  PredefinedExercise(name: 'Squat (Barbell)', category: MuscleGroup.bacak),
  PredefinedExercise(
    name: 'Front Squat (Barbell)',
    category: MuscleGroup.bacak,
  ),
  PredefinedExercise(name: 'Leg Press', category: MuscleGroup.bacak),
  PredefinedExercise(
    name: 'Lunge (Barbell/Dumbbell)',
    category: MuscleGroup.bacak,
  ),
  PredefinedExercise(name: 'Leg Extension', category: MuscleGroup.bacak),
  PredefinedExercise(
    name: 'Hamstring Curl (Lying/Seated)',
    category: MuscleGroup.bacak,
  ),
  PredefinedExercise(
    name: 'Stiff-Legged Deadlift',
    category: MuscleGroup.bacak,
  ), // Also Sırt
  PredefinedExercise(
    name: 'Glute Bridge/Hip Thrust',
    category: MuscleGroup.bacak,
  ),
  PredefinedExercise(
    name: 'Calf Raise (Standing/Seated)',
    category: MuscleGroup.bacak,
  ),
  PredefinedExercise(name: 'Hack Squat', category: MuscleGroup.bacak),
  PredefinedExercise(name: 'Goblet Squat', category: MuscleGroup.bacak),
  PredefinedExercise(
    name: 'Bulgarian Split Squat',
    category: MuscleGroup.bacak,
  ),

  // Karın
  PredefinedExercise(name: 'Crunch', category: MuscleGroup.karin),
  PredefinedExercise(name: 'Leg Raise', category: MuscleGroup.karin),
  PredefinedExercise(name: 'Plank', category: MuscleGroup.karin),
  PredefinedExercise(name: 'Side Plank', category: MuscleGroup.karin),
  PredefinedExercise(name: 'Russian Twist', category: MuscleGroup.karin),
  PredefinedExercise(name: 'Cable Crunch', category: MuscleGroup.karin),
  PredefinedExercise(name: 'Hanging Leg Raise', category: MuscleGroup.karin),
  PredefinedExercise(name: 'Bicycle Crunch', category: MuscleGroup.karin),
  PredefinedExercise(name: 'Ab Wheel Rollout', category: MuscleGroup.karin),

  // Kardiyo (Örnekler)
  PredefinedExercise(name: 'Koşu Bandı', category: MuscleGroup.kardiyo),
  PredefinedExercise(name: 'Eliptik Bisiklet', category: MuscleGroup.kardiyo),
  PredefinedExercise(
    name: 'Kondisyon Bisikleti',
    category: MuscleGroup.kardiyo,
  ),
  PredefinedExercise(name: 'Kürek Makinesi', category: MuscleGroup.kardiyo),
  PredefinedExercise(name: 'İp Atlama', category: MuscleGroup.kardiyo),
  PredefinedExercise(
    name: 'Merdiven Tırmanma Makinesi',
    category: MuscleGroup.kardiyo,
  ),
  PredefinedExercise(name: 'Yüzme', category: MuscleGroup.kardiyo),

  // Diğer/Tüm Vücut
  PredefinedExercise(name: 'Burpee', category: MuscleGroup.tumVucut),
  PredefinedExercise(name: 'Kettlebell Swing', category: MuscleGroup.tumVucut),
  PredefinedExercise(
    name: 'Thruster (Barbell/Dumbbell)',
    category: MuscleGroup.tumVucut,
  ),
  PredefinedExercise(name: 'Clean and Jerk', category: MuscleGroup.tumVucut),
  PredefinedExercise(name: 'Snatch', category: MuscleGroup.tumVucut),
];
