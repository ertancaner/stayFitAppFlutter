import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:stay_fit/src/routing/app_router.dart'; // AppRoute enum'u için

// AppRoute enum'u için

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  // AnimationController için TickerProvider ekle
  late final AnimationController _lottieController;
  bool _isLottieAnimationComplete = false;
  bool _isMinimumTimePassed = false;
  static const _minSplashTime = Duration(
    milliseconds: 2500,
  ); // Minimum splash süresi
  static const _appLoadTimeEstimate = Duration(
    milliseconds: 1500,
  ); // Tahmini uygulama yükleme süresi

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isLottieAnimationComplete = true;
          });
          _checkAndNavigate();
        }
      }
    });

    // Minimum bekleme süresini başlat
    Future.delayed(_minSplashTime).then((_) {
      if (mounted) {
        setState(() {
          _isMinimumTimePassed = true;
        });
        _checkAndNavigate();
      }
    });

    // Burada uygulama için gerekli başlangıç yüklemeleri yapılabilir (Riverpod provider'ları vs.)
    // Bu örnekte sadece bir gecikme ile simüle ediyoruz.
    // Gerçek bir uygulamada, bu Future, asıl yükleme işleminizi temsil etmelidir.
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Örneğin, veritabanı başlatma, ayarları okuma vb.
    // Bu süre, Lottie animasyonunun hızını ayarlamak için kullanılabilir (isteğe bağlı)
    // Şimdilik sabit bir gecikme kullanalım.
    await Future.delayed(
      _appLoadTimeEstimate,
    ); // Tahmini uygulama yükleme süresi
    // Yükleme bittiğinde, eğer _minSplashTime daha uzunsa o beklenecek.
    // Eğer _minSplashTime daha kısaysa ve animasyon da bittiyse hemen geçilecek.
    // Bu fonksiyon doğrudan navigasyonu tetiklemiyor, sadece yüklemenin bittiğini işaret ediyor.
    // Navigasyon _checkAndNavigate içinde yönetilecek.
  }

  void _checkAndNavigate() {
    // Hem Lottie animasyonu tamamlandıysa hem de minimum süre geçtiyse yönlendir.
    // Gerçekte, _initializeApp'in de tamamlanmasını beklemek isteyebilirsiniz.
    // Şimdilik, _isMinimumTimePassed, genel yükleme ve bekleme süresini temsil ediyor.
    if (_isLottieAnimationComplete && _isMinimumTimePassed && mounted) {
      context.goNamed(AppRoute.home.name);
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Lottie.asset(
          'assets/lottie/loading_animation.json',
          controller: _lottieController,
          width: 250, // Biraz büyüttüm
          height: 250, // Biraz büyüttüm
          fit: BoxFit.contain,
          onLoaded: (composition) {
            // Animasyon yüklendiğinde controller'ın süresini ayarla ve başlat.
            // Bu, animasyonun tam olarak bir kez oynamasını sağlar.
            // Eğer animasyonun hızını ayarlamak isteseydik, composition.duration'ı
            // _appLoadTimeEstimate'e göre ölçekleyebilirdik.
            // Örneğin: _lottieController.duration = composition.duration * (uygulamaYuklemeSuresi / animasyonNormalSuresi)
            // Ama bu, animasyonun doğal hızını bozar.
            // Animasyonun hızını artırmak için süresini kısaltıyoruz.
            // Örneğin, orijinal sürenin yarısı kadar bir sürede oynamasını sağlayalım (2 kat hız).
            final originalDuration = composition.duration;
            _lottieController.duration = Duration(
              milliseconds: (originalDuration.inMilliseconds / 2).round(),
            );
            _lottieController.forward();
          },
        ),
      ),
    );
  }
}
