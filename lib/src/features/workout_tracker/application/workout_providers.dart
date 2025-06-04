import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Ref için gerekli
// import 'package:stay_fit/src/data/database_helper.dart'; // Kullanılmıyor, kaldırıldı
// import 'package:stay_fit/src/features/home/application/home_providers.dart'; // Kullanılmıyor, kaldırıldı
// Yeni domain dosyasını import et
import 'package:stay_fit/src/features/workout_tracker/domain/exercise.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stay_fit/src/features/auth/application/auth_providers.dart'; // authStateChangesProvider için

part 'workout_providers.g.dart';

// Antrenman Günlükleri listesi için provider (Firestore'dan stream olarak)
@riverpod
Stream<List<WorkoutLog>> workoutLogs(Ref ref) { // WorkoutLogsRef, Ref olarak güncellendi
  final authState = ref.watch(authStateChangesProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value([]); // Kullanıcı yoksa boş stream
      }
      final userId = user.uid;
      final firestore = FirebaseFirestore.instance;

      return firestore
          .collection('users')
          .doc(userId)
          .collection('workoutLogs')
          .orderBy('date', descending: true)
          .snapshots()
          .asyncMap((snapshot) async { // asyncMap kullanıldı
        List<WorkoutLog> logs = [];
        for (var doc in snapshot.docs) {
          final logData = doc.data();
          final logId = doc.id;

          // Egzersizleri alt koleksiyondan çek
          final exercisesSnapshot = await firestore
              .collection('users')
              .doc(userId)
              .collection('workoutLogs')
              .doc(logId)
              .collection('loggedExercises')
              .orderBy('exerciseName') // İsteğe bağlı sıralama
              .get();

          List<LoggedExercise> loggedExercises = [];
          for (var exDoc in exercisesSnapshot.docs) {
            final exData = exDoc.data();
            final exId = exDoc.id;

            // Setleri alt koleksiyondan çek
            final setsSnapshot = await firestore
                .collection('users')
                .doc(userId)
                .collection('workoutLogs')
                .doc(logId)
                .collection('loggedExercises')
                .doc(exId)
                .collection('loggedSets')
                .orderBy('weight') // İsteğe bağlı sıralama
                .get();
            
            List<LoggedSet> sets = setsSnapshot.docs
                .map((setDoc) => LoggedSet.fromJson(setDoc.data(), id: setDoc.id))
                .toList();
            
            loggedExercises.add(LoggedExercise.fromJson(exData, id: exId, sets: sets));
          }
          logs.add(WorkoutLog.fromJson(logData, id: logId, loggedExercises: loggedExercises));
        }
        return logs;
      });
    },
    loading: () => Stream.value([]),
    error: (error, stackTrace) {
      // print("WorkoutLogs stream error: $error");
      return Stream.error(error);
    },
  );
}

// Antrenman Sayfası Notifier'ı (yeni log, egzersiz, set ekleme/silme işlemleri için)
@riverpod
class WorkoutNotifier extends _$WorkoutNotifier {
  @override
  FutureOr<void> build() {
    // Başlangıçta bir şey yapmaya gerek yok
  }

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  // DatabaseHelper'a erişim (Geçici, Firestore'a tam geçişte kaldırılacak) - KULLANILMIYOR
  // DatabaseHelper get _db => ref.read(databaseHelperProvider);

  // Belirli bir tarihe ait WorkoutLog'u bulur veya oluşturur (Firestore için güncellenecek) - KULLANILMIYOR
  // Bu metodun Firestore'daki karşılığı genellikle doğrudan ekleme veya stream üzerinden dinleme şeklinde olur.
  // Şimdilik SQLite bağımlılığını koruyarak devam edelim, sonra Firestore'a uyarlayalım.
  // Future<WorkoutLog> _findOrCreateWorkoutLog(DateTime date) async {
  //   final user = _auth.currentUser;
  //   if (user == null) throw Exception("Kullanıcı giriş yapmamış.");
  //   final userId = user.uid;
  //
  //   // Önce Firestore'da o tarihe ait log var mı kontrol et
  //   final querySnapshot = await _firestore
  //       .collection('users')
  //       .doc(userId)
  //       .collection('workoutLogs')
  //       .where('date', isEqualTo: date.toIso8601String().substring(0, 10)) // Sadece gün bazlı kontrol
  //       .limit(1)
  //       .get();
  //
  //   if (querySnapshot.docs.isNotEmpty) {
  //     final doc = querySnapshot.docs.first;
  //     // Egzersiz ve setleri de yükle
  //      final exercisesSnapshot = await doc.reference.collection('loggedExercises').get();
  //      List<LoggedExercise> loggedExercises = [];
  //      for (var exDoc in exercisesSnapshot.docs) {
  //        final setsSnapshot = await exDoc.reference.collection('loggedSets').get();
  //        List<LoggedSet> sets = setsSnapshot.docs.map((sDoc) => LoggedSet.fromJson(sDoc.data(), id: sDoc.id)).toList();
  //        loggedExercises.add(LoggedExercise.fromJson(exDoc.data(), id: exDoc.id, sets: sets));
  //      }
  //     return WorkoutLog.fromJson(doc.data(), id: doc.id, loggedExercises: loggedExercises);
  //   } else {
  //     // Firestore'da yoksa yeni oluştur (ama henüz kaydetme, egzersiz eklenince kaydedilecek)
  //     return WorkoutLog(date: date, id: _firestore.collection('users').doc(userId).collection('workoutLogs').doc().id);
  //   }
  // }

  // Seçilen bir egzersizi belirli bir tarihteki antrenman günlüğüne ekler
  // Hem loggedExerciseId hem de workoutLogId döndürür
  Future<Map<String, String>> addExerciseToLog(
    String exerciseName,
    String? category,
    DateTime date,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı giriş yapmamış.");
    final userId = user.uid;

    // Tarihe göre WorkoutLog bul veya oluştur (Firestore'da)
    final logCollectionRef = _firestore.collection('users').doc(userId).collection('workoutLogs');
    QuerySnapshot logSnapshot = await logCollectionRef
        .where('date', isEqualTo: Timestamp.fromDate(DateTime(date.year, date.month, date.day))) // Sadece gün bazlı karşılaştırma
        .limit(1)
        .get();

    String workoutLogId;
    DocumentReference<Map<String, dynamic>> workoutLogRef;

    if (logSnapshot.docs.isNotEmpty) {
      workoutLogRef = logSnapshot.docs.first.reference as DocumentReference<Map<String, dynamic>>;
      workoutLogId = workoutLogRef.id;
      // Başlığı güncelle (eğer kategori varsa ve başlıkta yoksa)
      final currentLogData = logSnapshot.docs.first.data() as Map<String, dynamic>;
      String? currentTitle = currentLogData['title'];
      String? newTitle = currentTitle;
      if (category != null && category.isNotEmpty) {
        if (newTitle == null || newTitle.isEmpty) {
          newTitle = category;
        } else {
          final existingCategories = newTitle.split(',').map((e) => e.trim().toLowerCase()).toList();
          if (!existingCategories.contains(category.toLowerCase())) {
            newTitle = "$newTitle, $category";
          }
        }
        if (newTitle != currentTitle) {
          await workoutLogRef.update({'title': newTitle});
        }
      }
    } else {
      // Yeni log oluştur
      workoutLogRef = logCollectionRef.doc();
      workoutLogId = workoutLogRef.id;
      await workoutLogRef.set({
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
        'title': category, // İlk egzersizin kategorisi başlık olabilir
        // Diğer log alanları...
      });
    }

    final newExerciseRef = workoutLogRef.collection('loggedExercises').doc();
    final newExercise = LoggedExercise(
      id: newExerciseRef.id, // Firestore ID'si
      workoutLogId: workoutLogId, // workoutLogId burada atanıyor
      exerciseName: exerciseName,
      category: category,
    );
    await newExerciseRef.set(newExercise.toJson());

    ref.invalidate(workoutLogsProvider);
    return {
      'loggedExerciseId': newExerciseRef.id,
      'workoutLogId': workoutLogId,
    };
  }


  // Yeni: WorkoutLog ekler ve ID'sini döndürür (Firestore için güncellendi)
  Future<String> insertWorkoutLogAndGetId(WorkoutLog log) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı giriş yapmamış.");
    final userId = user.uid;

    final newLogRef = _firestore.collection('users').doc(userId).collection('workoutLogs').doc();
    await newLogRef.set(log.copyWith(id: newLogRef.id).toJson()); // ID'yi modele ekleyip kaydet
    ref.invalidate(workoutLogsProvider);
    return newLogRef.id;
  }

  // Yeni: LoggedExercise ekler ve ID'sini döndürür (Firestore için güncellendi)
  Future<String> insertLoggedExerciseAndGetId(LoggedExercise exercise, String workoutLogId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı giriş yapmamış.");
    final userId = user.uid;

    final newExerciseRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workoutLogs')
        .doc(workoutLogId)
        .collection('loggedExercises')
        .doc();
    await newExerciseRef.set(exercise.copyWith(id: newExerciseRef.id, workoutLogId: workoutLogId).toJson());
    ref.invalidate(workoutLogsProvider);
    return newExerciseRef.id;
  }

  // Bir egzersize yeni bir set ekler (Firestore için güncellendi)
  Future<String> addSetToExercise(String workoutLogId, String loggedExerciseId, LoggedSet set) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı giriş yapmamış.");
    final userId = user.uid;

    final newSetRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workoutLogs')
        .doc(workoutLogId)
        .collection('loggedExercises')
        .doc(loggedExerciseId)
        .collection('loggedSets')
        .doc();
    await newSetRef.set(set.copyWith(id: newSetRef.id, loggedExerciseId: loggedExerciseId).toJson());
    ref.invalidate(workoutLogsProvider);
    return newSetRef.id;
  }

  // Bir antrenman günlüğünü siler (Firestore için güncellendi)
  Future<void> deleteWorkoutLog(String logId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı giriş yapmamış.");
    final userId = user.uid;

    final logRef = _firestore.collection('users').doc(userId).collection('workoutLogs').doc(logId);
    
    // Alt koleksiyonları sil (önce egzersizler, sonra setler - ya da tam tersi)
    // Bu işlem karmaşık olabilir, batched writes veya cloud function ile yapmak daha iyi olabilir.
    // Şimdilik sadece ana log'u silelim, alt koleksiyonlar elle veya başka bir mekanizma ile silinebilir.
    // ÖNEMLİ: Gerçek bir uygulamada alt koleksiyonların da silinmesi gerekir.
    final exercisesSnapshot = await logRef.collection('loggedExercises').get();
    for (var exDoc in exercisesSnapshot.docs) {
      final setsSnapshot = await exDoc.reference.collection('loggedSets').get();
      for (var setDoc in setsSnapshot.docs) {
        await setDoc.reference.delete();
      }
      await exDoc.reference.delete();
    }
    await logRef.delete();
    ref.invalidate(workoutLogsProvider);
  }

  // Kaydedilmiş bir egzersizi siler (WorkoutLog içinden - Firestore için güncellendi)
  Future<void> deleteLoggedExercise(String workoutLogId, String loggedExerciseId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı giriş yapmamış.");
    final userId = user.uid;

    final exerciseRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workoutLogs')
        .doc(workoutLogId)
        .collection('loggedExercises')
        .doc(loggedExerciseId);

    // Setleri sil
    final setsSnapshot = await exerciseRef.collection('loggedSets').get();
    for (var setDoc in setsSnapshot.docs) {
      await setDoc.reference.delete();
    }
    await exerciseRef.delete();

    // Eğer bu egzersiz silindikten sonra log'da başka egzersiz kalmazsa, log'u da sil (opsiyonel)
    // Veya sadece başlığı güncelle
    final workoutLogRef = _firestore.collection('users').doc(userId).collection('workoutLogs').doc(workoutLogId);
    final remainingExercisesSnapshot = await workoutLogRef.collection('loggedExercises').limit(1).get();
    if (remainingExercisesSnapshot.docs.isEmpty) {
      // await workoutLogRef.delete(); // Log'u silmek yerine başlığı temizleyebiliriz veya boş bırakabiliriz
    } else {
        // Başlığı güncelleme mantığı buraya eklenebilir (exerciseToDelete.category'yi kullanarak)
        // Bu kısım, addExerciseToLog'daki başlık güncelleme mantığına benzer olabilir.
        // Şimdilik basit tutalım.
    }

    ref.invalidate(workoutLogsProvider);
  }

  // Bir seti siler (Firestore için güncellendi)
  Future<void> deleteLoggedSet(String workoutLogId, String loggedExerciseId, String setId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı giriş yapmamış.");
    final userId = user.uid;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('workoutLogs')
        .doc(workoutLogId)
        .collection('loggedExercises')
        .doc(loggedExerciseId)
        .collection('loggedSets')
        .doc(setId)
        .delete();
    ref.invalidate(workoutLogsProvider);
  }

  // --- Güncelleme Metodları (Gerektiğinde eklenecek) ---
  // Future<void> updateLoggedExercise(...) async { ... }
  // Future<void> updateLoggedSet(...) async { ... }

  // --- Eski Metodlar (Kaldırıldı veya Yorumlandı) ---
  /*
  Future<void> addExercise(Exercise exercise) async { ... }
  Future<void> updateExercise(Exercise exercise) async { ... }
  Future<void> deleteExercise(int id) async { ... }
  */
}
