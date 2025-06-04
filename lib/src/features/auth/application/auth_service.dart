import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore için eklendi

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore örneği eklendi

  // Kullanıcı durumunu dinle
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // E-posta ve şifre ile giriş yap
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      // Hatanın UI katmanında yakalanıp işlenmesi için tekrar fırlat.
      // print('AuthService - Giriş hatası'); // Hata ayıklama için e.code olmadan
      rethrow;
    }
  }

  // E-posta ve şifre ile kayıt ol
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı başarıyla oluşturulduysa Firestore'a kaydet
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          // İleride eklenebilecek diğer alanlar: displayName, photoURL vb.
        });
      }
      // signOut() çağrısı buradan kaldırıldı. RegisterPage'de yönetilecek.
      return userCredential;
    } on FirebaseAuthException catch (_) { // 'e' değişkeni kullanılmadığı için '_' ile değiştirildi.
      // Firebase Auth hatası
      // print('Firebase Auth Kayıt hatası: _.message'); // Eğer loglama yapılacaksa _ kullanılamaz, spesifik hata mesajı için e gerekir.
      // Hatanın UI katmanında yakalanıp işlenmesi için tekrar fırlat.
      rethrow;
    } catch (_) { // 'e' değişkeni kullanılmadığı için '_' ile değiştirildi.
      // Firestore veya diğer genel hatalar
      // print('Firestore veya genel kayıt hatası: $_');
      // Hatanın UI katmanında yakalanıp işlenmesi için tekrar fırlat.
      rethrow;
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}