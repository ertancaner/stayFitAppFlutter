import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stay_fit/src/data/database_helper.dart'; // Firestore'a geçince bu kaldırılabilir
import 'package:stay_fit/src/features/home/domain/weight_entry.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Eksik import eklendi
import 'package:cloud_firestore/cloud_firestore.dart'; // Eksik import eklendi
import 'package:stay_fit/src/features/auth/application/auth_providers.dart'; // authStateChangesProvider için eklendi
// shared_preferences eklendiğinde import edilecek
// import 'package:shared_preferences/shared_preferences.dart';

part 'home_providers.g.dart';

// DatabaseHelper için provider
@Riverpod(keepAlive: true)
DatabaseHelper databaseHelper(Ref ref) {
  return DatabaseHelper.instance;
}

// Tartım kayıtları listesi için provider (Firestore'dan stream olarak)
@riverpod
Stream<List<WeightEntry>> weightEntries(Ref ref) {
  // authStateChangesProvider'ı dinleyerek kullanıcı durumu değişikliklerinde provider'ın yeniden çalışmasını sağla
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
          .collection('weightEntries')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return WeightEntry.fromJson(data).copyWith(id: doc.id);
        }).toList();
      });
    },
    loading: () => Stream.value([]), // Yüklenirken boş stream
    error: (error, stackTrace) => Stream.error(error), // Hata durumunda hata stream'i
  );
}


// Eski kod tamamen yorum satırı içine alındı veya silindi.

// Hedef kilo için provider (şimdilik basit bir state, sonra shared_preferences ile)
// SharedPreferences'ı ekledikten sonra bu provider'ı güncelleyeceğiz.
// const String targetWeightKey = 'targetWeight';

@riverpod
class TargetWeight extends _$TargetWeight {
  @override
  Future<double?> build() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null; // Kullanıcı yoksa hedef kilo da yok
    }
    final userId = user.uid;
    final firestore = FirebaseFirestore.instance;

    try {
      final docSnapshot = await firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return (docSnapshot.data()!['targetWeight'] as num?)?.toDouble();
      }
    } catch (e) {
      // print("Firestore'dan hedef kilo okunurken hata: $e");
      // Hata durumunda null dönebilir veya hata fırlatılabilir.
      // UI tarafı AsyncError'u ele alabilir.
      rethrow;
    }
    return null; // Veri yoksa veya hata oluşursa
  }

  Future<void> setTargetWeight(double weight) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Kullanıcı giriş yapmamış.");
    }
    final userId = user.uid;
    final firestore = FirebaseFirestore.instance;

    try {
      await firestore
          .collection('users')
          .doc(userId)
          .set({'targetWeight': weight}, SetOptions(merge: true)); // merge:true ile diğer alanları koru
      state = AsyncValue.data(weight);
    } catch (e) {
      // print("Firestore'a hedef kilo yazılırken hata: $e");
      state = AsyncValue.error(e, StackTrace.current);
      throw Exception("Hedef kilo ayarlanamadı.");
    }
  }
}

// Ana Sayfa Notifier'ı (tartım ekleme, silme, güncelleme işlemleri için)
@riverpod
class HomeNotifier extends _$HomeNotifier {
  @override
  FutureOr<void> build() {
    // Başlangıçta bir şey yapmaya gerek yok
  }

  Future<void> addWeightEntry(double weight, DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Kullanıcı giriş yapmamış.");
    }
    final userId = user.uid;

    final newEntry = WeightEntry(
      userId: userId, // userId eklendi
      weight: weight,
      date: date,
      // id alanı Firestore tarafından otomatik atanacak
    );

    // Firestore'a kaydet
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore
          .collection('users')
          .doc(userId)
          .collection('weightEntries')
          .add(newEntry.toJson()); // toJson() ile Map'e çevir
    } catch (e) {
      // print("Firestore'a tartım kaydı eklenirken hata: $e");
      throw Exception("Tartım kaydı eklenemedi.");
    }

    // final dbHelper = ref.read(databaseHelperProvider); // SQLite kısmı kaldırılıyor
    // await dbHelper.insertWeightEntry(newEntry); // SQLite kısmı kaldırılıyor
    ref.invalidate(weightEntriesProvider); // Listeyi yenile (Bu provider da Firestore'dan okuyacak şekilde güncellenmeli)
  }

  Future<void> updateWeightEntry(WeightEntry entry) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || entry.id == null) {
      throw Exception("Kullanıcı girişi veya tartım ID'si eksik.");
    }
    final userId = user.uid;

    try {
      final firestore = FirebaseFirestore.instance;
      await firestore
          .collection('users')
          .doc(userId)
          .collection('weightEntries')
          .doc(entry.id) // Güncellenecek dokümanın ID'si
          .update(entry.toJson()); // toJson() ile Map'e çevir
    } catch (e) {
      // print("Firestore'da tartım kaydı güncellenirken hata: $e");
      throw Exception("Tartım kaydı güncellenemedi.");
    }

    // final dbHelper = ref.read(databaseHelperProvider); // SQLite kısmı kaldırılıyor
    // await dbHelper.updateWeightEntry(entry); // SQLite kısmı kaldırılıyor
    ref.invalidate(weightEntriesProvider); // Listeyi yenile
  }

  Future<void> deleteWeightEntry(String entryId) async { // id tipi int'ten String'e değişti
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Kullanıcı giriş yapmamış.");
    }
    final userId = user.uid;

    try {
      final firestore = FirebaseFirestore.instance;
      await firestore
          .collection('users')
          .doc(userId)
          .collection('weightEntries')
          .doc(entryId) // Silinecek dokümanın ID'si
          .delete();
    } catch (e) {
      // print("Firestore'dan tartım kaydı silinirken hata: $e");
      throw Exception("Tartım kaydı silinemedi.");
    }
    // final dbHelper = ref.read(databaseHelperProvider); // SQLite kısmı kaldırılıyor
    // await dbHelper.deleteWeightEntry(id); // SQLite kısmı kaldırılıyor
    ref.invalidate(weightEntriesProvider); // Listeyi yenile
  }
}
