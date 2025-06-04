import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Timestamp için eklendi

// Veritabanında saklanacak bir antrenman setinin modeli
class LoggedSet extends Equatable {
  final String? id; // Firestore doküman ID'si (opsiyonel)
  final String loggedExerciseId; // Hangi kaydedilmiş egzersize ait olduğu (Firestore doküman ID'si)
  final int reps; // Tekrar sayısı
  final double weight; // Kullanılan ağırlık (kg)
  final int restTimeInSeconds; // Set sonrası dinlenme süresi (saniye)

  const LoggedSet({
    this.id,
    required this.loggedExerciseId,
    required this.reps,
    required this.weight,
    this.restTimeInSeconds = 0, // Varsayılan dinlenme süresi 0
  });

  // Firestore için Map dönüşümleri
  Map<String, dynamic> toJson() {
    return {
      // id alanı Firestore tarafından otomatik yönetildiği için genellikle toJson'a eklenmez
      'loggedExerciseId': loggedExerciseId,
      'reps': reps,
      'weight': weight,
      'restTimeInSeconds': restTimeInSeconds,
    };
  }

  factory LoggedSet.fromJson(Map<String, dynamic> json, {String? id}) {
    return LoggedSet(
      id: id, // Doküman ID'si dışarıdan sağlanır
      loggedExerciseId: json['loggedExerciseId'] as String,
      reps: json['reps'] as int,
      weight: (json['weight'] as num).toDouble(),
      restTimeInSeconds: json['restTimeInSeconds'] as int? ?? 0,
    );
  }

  LoggedSet copyWith({
    String? id,
    String? loggedExerciseId,
    int? reps,
    double? weight,
    int? restTimeInSeconds,
  }) {
    return LoggedSet(
      id: id ?? this.id,
      loggedExerciseId: loggedExerciseId ?? this.loggedExerciseId,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restTimeInSeconds: restTimeInSeconds ?? this.restTimeInSeconds,
    );
  }

  @override
  List<Object?> get props => [
    id,
    loggedExerciseId,
    reps,
    weight,
    restTimeInSeconds,
  ];
}

// Belirli bir antrenman günlüğünde yapılan egzersizi temsil eder
class LoggedExercise extends Equatable {
  final String? id; // Firestore doküman ID'si
  final String workoutLogId; // Hangi antrenman günlüğüne ait olduğu (Firestore doküman ID'si)
  final String
  exerciseName; // Yapılan egzersizin adı (ExerciseDefinition'dan gelir)
  final String? category; // Egzersizin kategorisi (opsiyonel)
  final List<LoggedSet> sets; // Bu egzersiz için yapılan setler (Firestore'da alt koleksiyon olarak tutulacak)

  const LoggedExercise({
    this.id,
    required this.workoutLogId,
    required this.exerciseName,
    this.category,
    this.sets = const [], // Başlangıçta boş set listesi
  });

  // Firestore için Map dönüşümleri
  // Not: Set listesi ayrı bir alt koleksiyonda yönetileceği için toJson/fromJson'da doğrudan yer almaz.
  Map<String, dynamic> toJson() {
    return {
      // id alanı Firestore tarafından otomatik yönetildiği için genellikle toJson'a eklenmez
      'workoutLogId': workoutLogId,
      'exerciseName': exerciseName,
      'category': category,
      // 'sets' alanı burada olmayacak, alt koleksiyon olarak yönetilecek
    };
  }

  factory LoggedExercise.fromJson(
    Map<String, dynamic> json, {
    String? id,
    List<LoggedSet> sets = const [], // Setler dışarıdan yüklenecek
  }) {
    return LoggedExercise(
      id: id, // Doküman ID'si dışarıdan sağlanır
      workoutLogId: json['workoutLogId'] as String,
      exerciseName: json['exerciseName'] as String,
      category: json['category'] as String?,
      sets: sets, // Setler ayrı olarak yüklenip buraya atanır
    );
  }

  LoggedExercise copyWith({
    String? id,
    String? workoutLogId,
    String? exerciseName,
    String? category,
    List<LoggedSet>? sets,
  }) {
    return LoggedExercise(
      id: id ?? this.id,
      workoutLogId: workoutLogId ?? this.workoutLogId,
      exerciseName: exerciseName ?? this.exerciseName,
      category: category ?? this.category,
      sets: sets ?? this.sets,
    );
  }

  @override
  List<Object?> get props => [id, workoutLogId, exerciseName, category, sets];
}

// Belirli bir tarihteki antrenman günlüğünü temsil eder
class WorkoutLog extends Equatable {
  final String? id; // Firestore doküman ID'si
  final DateTime date; // Antrenman tarihi
  final String?
  title; // Antrenman gününün başlığı/kategorisi (örn: "Göğüs Günü", "İtiş Antrenmanı")
  final List<LoggedExercise> loggedExercises; // O gün yapılan egzersizler (Firestore'da alt koleksiyon olarak tutulacak)

  const WorkoutLog({
    this.id,
    required this.date,
    this.title,
    this.loggedExercises = const [],
  });

  // Firestore için Map dönüşümleri
  // Not: LoggedExercise listesi ayrı bir alt koleksiyonda yönetileceği için toJson/fromJson'da doğrudan yer almaz.
  Map<String, dynamic> toJson() {
    return {
      // id alanı Firestore tarafından otomatik yönetildiği için genellikle toJson'a eklenmez
      'date': date.toIso8601String(), // Tarihi ISO 8601 formatında string olarak saklayalım
      'title': title,
      // 'loggedExercises' alanı burada olmayacak, alt koleksiyon olarak yönetilecek
    };
  }

  factory WorkoutLog.fromJson(
    Map<String, dynamic> json, {
    String? id,
    List<LoggedExercise> loggedExercises = const [], // Egzersizler dışarıdan yüklenecek
  }) {
    return WorkoutLog(
      id: id, // Doküman ID'si dışarıdan sağlanır
      date: _parseDate(json['date']), // Tarih alanını esnek şekilde parse et
      title: json['title'] as String?,
      loggedExercises:
          loggedExercises, // Egzersizler ayrı olarak yüklenip buraya atanır
    );
  }

  // Helper method to parse date flexibly
  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue is String) {
      return DateTime.parse(dateValue);
    } else if (dateValue is Timestamp) {
      return dateValue.toDate();
    } else if (dateValue is int) {
      // Eğer milisaniye olarak saklandıysa (pek olası değil ama bir ihtimal)
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    // Beklenmedik bir tip veya null ise, bir varsayılan değer döndür veya hata fırlat.
    // Şimdilik, uygulamanın çökmemesi için Epoch tarihini döndürelim,
    // ancak bu durumun loglanması iyi olur.
    // print('WorkoutLog.fromJson: date alanı beklenmedik bir tipte veya null: $dateValue');
    return DateTime.fromMillisecondsSinceEpoch(0); // Veya hata fırlat: throw ArgumentError('Invalid date format');
  }

  WorkoutLog copyWith({
    String? id,
    DateTime? date,
    String? title,
    List<LoggedExercise>? loggedExercises,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      loggedExercises: loggedExercises ?? this.loggedExercises,
    );
  }

  @override
  List<Object?> get props => [id, date, title, loggedExercises];
}
