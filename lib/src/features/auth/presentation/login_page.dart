import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthException için eklendi
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // GoRouter import et
import 'package:stay_fit/src/features/auth/application/auth_providers.dart';
import 'package:stay_fit/src/routing/app_router.dart'; // AppRoute import et

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final userCredential = await ref.read(authServiceProvider).signInWithEmailAndPassword(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
        if (userCredential != null && mounted) {
          context.goNamed(AppRoute.home.name);
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Giriş sırasında bir hata oluştu. Lütfen tekrar deneyin.';
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          errorMessage = 'E-posta adresiniz veya şifreniz yanlış. Lütfen kontrol edin.';
        }
        // Diğer spesifik Firebase Auth hata kodları için buraya eklemeler yapılabilir.
        // Örneğin: e.code == 'invalid-email', e.code == 'user-disabled' vb.
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        // Diğer beklenmedik hatalar için genel bir mesaj
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Beklenmedik bir hata oluştu. Lütfen tekrar deneyin.')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      // appBar: AppBar(title: const Text('Giriş Yap')), // AppBar kaldırıldı, daha modern bir görünüm için
      backgroundColor: theme.colorScheme.surface, // Arka plan rengi tema ile uyumlu
      body: Center( // İçeriği ortalamak için Center widget'ı
        child: SingleChildScrollView( // Küçük ekranlarda kaydırma için
          padding: const EdgeInsets.all(24.0), // Kenar boşlukları artırıldı
          child: ConstrainedBox( // Formun maksimum genişliğini sınırlamak için
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4.0, // Kart'a gölge efekti
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), // Yuvarlak kenarlar
              child: Padding(
                padding: const EdgeInsets.all(24.0), // Kart içi boşluklar
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Elemanları yatayda genişlet
                    children: [
                      // Uygulama Logosu veya Adı (Örnek)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: Text(
                          'StayFit',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'E-posta',
                          prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha((255 * 0.05).round()), // Eskimiş kullanım düzeltildi
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen e-postanızı girin';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Geçerli bir e-posta adresi girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha((255 * 0.05).round()), // Eskimiş kullanım düzeltildi
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen şifrenizi girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              onPressed: _signIn,
                              child: const Text('Giriş Yap'),
                            ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          context.goNamed(AppRoute.register.name);
                        },
                        child: Text(
                          'Hesabın yok mu? Kayıt Ol',
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}