import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthException için eklendi
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // GoRouter import et
import 'package:stay_fit/src/features/auth/application/auth_providers.dart';
import 'package:stay_fit/src/routing/app_router.dart'; // AppRoute import et

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // Şifre doğrulama için
  bool _isLoading = false;
  bool _termsAccepted = false; // KVKK onayı için

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen kullanıcı sözleşmesini ve KVKK aydınlatma metnini onaylayın.')),
        );
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şifreler eşleşmiyor')),
        );
        return;
      }
      // Kayıt işlemi başladığında provider'ı güncelle
      ref.read(registrationInProgressProvider.notifier).state = true;
      setState(() {
        _isLoading = true;
      });

      try {
        // Kullanıcı oluşturma
        final userCredential = await ref.read(authServiceProvider).createUserWithEmailAndPassword(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );

        if (userCredential != null && userCredential.user != null) {
          // Kullanıcı başarıyla oluşturuldu, şimdi hemen çıkış yap
          await ref.read(authServiceProvider).signOut();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kayıt başarılı! Giriş sayfasına yönlendiriliyorsunuz.')),
            );
            // Future.delayed kaldırıldı, yönlendirme hemen yapılacak.
            if (!mounted) return;
            context.goNamed(AppRoute.login.name);
          }
        }
        // userCredential null veya userCredential.user null ise,
        // auth_service'deki createUserWithEmailAndPassword zaten hata fırlatacağı için
        // bu durum catch bloklarında ele alınacaktır. Bu nedenle buradaki else bloğu kaldırıldı.
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Kayıt sırasında bir hata oluştu. Lütfen tekrar deneyin.';
        if (e.code == 'weak-password') {
          errorMessage = 'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'Bu e-posta adresi zaten kayıtlı. Lütfen farklı bir e-posta deneyin veya giriş yapın.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Geçersiz e-posta adresi. Lütfen kontrol edin.';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Beklenmedik bir hata oluştu. Lütfen tekrar deneyin.')),
          );
        }
      } finally {
        // Kayıt işlemi bittiğinde (başarılı veya başarısız) provider'ı güncelle
        ref.read(registrationInProgressProvider.notifier).state = false;
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
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: Text(
                          'Hesap Oluştur',
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
                          if (value.length < 6) {
                            return 'Şifre en az 6 karakter olmalıdır';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Şifreyi Onayla',
                          prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha((255 * 0.05).round()), // Eskimiş kullanım düzeltildi
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen şifrenizi tekrar girin';
                          }
                          if (value != _passwordController.text) {
                            return 'Şifreler eşleşmiyor';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _termsAccepted,
                            onChanged: (value) {
                              setState(() {
                                _termsAccepted = value ?? false;
                              });
                            },
                            activeColor: theme.colorScheme.primary,
                          ),
                          Expanded(
                            child: GestureDetector( // Metne tıklanabilirlik için
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Kullanıcı Sözleşmesi ve Gizlilik Politikası'),
                                    content: const SingleChildScrollView( // Uzun metinler için kaydırılabilir
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Kullanıcı Sözleşmesi',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'StayFit mobil uygulamasını ("Uygulama") kullanarak aşağıdaki şartları kabul etmiş sayılırsınız. Lütfen bu sözleşmeyi dikkatlice okuyunuz.\n\n'
                                            '1. Hizmetler: Uygulama, fitness takibi, egzersiz önerileri ve sağlıklı yaşam konularında bilgi ve araçlar sunar. Bu hizmetler tıbbi tavsiye niteliğinde değildir.\n'
                                            '2. Kullanıcı Sorumlulukları: Uygulamayı kullanırken verdiğiniz bilgilerin (e-posta, şifre, antrenman verileri vb.) doğruluğundan siz sorumlusunuz. Sağlık durumunuza uygun olmayan egzersizleri yapmaktan kaçınınız.\n'
                                            '3. Veri Kullanımı: Kayıt sırasında ve uygulama kullanımı boyunca topladığımız kişisel verileriniz (e-posta, antrenman kayıtları, kilo bilgisi vb.) hizmetlerimizi geliştirmek, size özel öneriler sunmak ve uygulama deneyiminizi iyileştirmek amacıyla kullanılır. Detaylı bilgi için Gizlilik Politikamızı inceleyiniz.\n'
                                            '4. Fikri Mülkiyet: Uygulama içeriği ve tasarımı StayFit\'e aittir ve izinsiz kullanılamaz.\n'
                                            '5. Sorumluluk Sınırlandırması: Uygulama kullanımından doğabilecek dolaylı zararlardan StayFit sorumlu tutulamaz.\n'
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Gizlilik Politikası ve KVKK Aydınlatma Metni',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'StayFit olarak kişisel verilerinizin güvenliğine önem veriyoruz. 6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) uyarınca, veri sorumlusu sıfatıyla sizleri bilgilendirmek isteriz.\n\n'
                                            'Toplanan Kişisel Veriler: Adınız, soyadınız (isteğe bağlı), e-posta adresiniz, şifreniz (şifrelenmiş olarak), yaşınız, cinsiyetiniz, boyunuz, kilonuz, aktivite seviyeniz, antrenman ve beslenme kayıtlarınız gibi veriler toplanabilir.\n\n'
                                            'Veri İşleme Amaçları: Kişisel verileriniz; kullanıcı hesabınızı oluşturmak ve yönetmek, uygulama özelliklerini sunmak, size özel antrenman ve beslenme planları önermek, uygulama içi bildirimler göndermek, hizmet kalitemizi artırmak ve yasal yükümlülüklerimizi yerine getirmek amacıyla işlenir.\n\n'
                                            'Veri Paylaşımı: Kişisel verileriniz, yasal zorunluluklar dışında üçüncü taraflarla paylaşılmaz. Hizmetlerimizi sunmak için çalıştığımız anonimleştirilmiş veri analizi yapan iş ortaklarımızla sınırlı veri paylaşımı yapılabilir.\n\n'
                                            'Veri Saklama Süresi: Kişisel verileriniz, hesabınız aktif olduğu sürece veya yasal süreler boyunca saklanır.\n\n'
                                            'Haklarınız: KVKK kapsamında kişisel verilerinize erişme, düzeltme, silme, işlenmesine itiraz etme ve aktarılmasını talep etme haklarınız bulunmaktadır. Bu haklarınızı kullanmak için [destek@stayfit.app] adresinden bize ulaşabilirsiniz.\n\n'
                                            'Bu metni onaylayarak, kişisel verilerinizin yukarıda belirtilen amaçlar doğrultusunda işlenmesine açık rıza göstermiş olursunuz.'
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Kapat'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                  children: [
                                    const TextSpan(text: 'Okudum, anladım ve '),
                                    TextSpan(
                                      text: 'Kullanıcı Sözleşmesini',
                                      style: TextStyle(decoration: TextDecoration.underline, color: theme.colorScheme.primary),
                                      // recognizer: TapGestureRecognizer()..onTap = () { /* Sözleşme linki */ }
                                    ),
                                    const TextSpan(text: ' ve '),
                                    TextSpan(
                                      text: 'KVKK Aydınlatma Metnini',
                                      style: TextStyle(decoration: TextDecoration.underline, color: theme.colorScheme.primary),
                                      // recognizer: TapGestureRecognizer()..onTap = () { /* KVKK linki */ }
                                    ),
                                    const TextSpan(text: ' onaylıyorum.'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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
                              onPressed: _signUp,
                              child: const Text('Kayıt Ol'),
                            ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          context.goNamed(AppRoute.login.name);
                        },
                        child: Text(
                          'Hesabın var mı? Giriş Yap',
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