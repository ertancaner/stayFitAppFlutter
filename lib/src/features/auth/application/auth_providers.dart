import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

// AuthService'i sağlayan provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Kullanıcının kimlik doğrulama durumunu dinleyen stream provider
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Kayıt işleminin devam edip etmediğini takip eden provider.
/// true ise kayıt işlemi devam ediyor, false ise etmiyor.
final registrationInProgressProvider = StateProvider<bool>((ref) => false);