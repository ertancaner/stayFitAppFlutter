import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Eklendi
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stay_fit/src/routing/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    // Sade ve Monokrom Renk Paleti
    const Color primaryDark = Color(0xFF1A1A1A); // Çok koyu gri, siyaha yakın
    const Color primaryText = Colors.black87;
    const Color secondaryText = Colors.black54;
    const Color scaffoldBackgroundColor = Colors.white;
    const Color cardBackgroundColor = Color(
      0xFFF7F7F7,
    ); // Çok açık gri kartlar için
    const Color selectedItemColor =
        primaryDark; // Seçili ikonlar için ana koyu renk
    const Color unselectedItemColor =
        Colors.grey; // Seçili olmayan ikonlar için gri

    return MaterialApp.router(
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      // Localization ayarları eklendi
      localizationsDelegates: [
        // const kaldırıldı
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'), // Türkçe
        Locale('en', 'US'), // İngilizce
      ],
      locale: const Locale('tr', 'TR'), // Varsayılan dil Türkçe
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryDark,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryDark, // Ana renk tonu
          primary: primaryDark,
          secondary: primaryDark, // Vurgu rengi de ana koyu renk olabilir
          onPrimary: Colors.white, // primaryDark üzerindeki metin/ikon
          onSecondary: Colors.white, // secondary üzerindeki metin/ikon
          surface: scaffoldBackgroundColor, // Kartlar, dialoglar vb. yüzeyler. Tekrar eden satırlar kaldırıldı.
          onSurface: primaryText, // Yüzeyler üzerindeki metin. Tekrar eden satırlar kaldırıldı.
          error: Colors.redAccent,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: primaryText, displayColor: primaryText),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: scaffoldBackgroundColor, // Veya hafif bir gri
          selectedItemColor: selectedItemColor,
          unselectedItemColor: unselectedItemColor,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0.5, // Hafif bir ayrım için
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor:
              scaffoldBackgroundColor, // AppBar arka planı da beyaz/açık
          foregroundColor: primaryDark, // AppBar başlık ve ikon renkleri koyu
          elevation: 0.5, // Hafif bir ayrım çizgisi
          titleTextStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryDark,
          ),
          iconTheme: IconThemeData(color: primaryDark), // AppBar ikonları
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          elevation: 4.0,
        ),
        cardTheme: CardTheme(
          elevation: 0.5, // Kartlara daha az gölge
          color: cardBackgroundColor, // Kart arka plan rengi
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            // side: BorderSide(color: Colors.grey[300]!, width: 0.5), // İsteğe bağlı ince border
          ),
          margin: const EdgeInsets.symmetric(
            vertical: 6.0,
            horizontal: 0,
          ), // Kart marjinleri
        ),
        dialogTheme: DialogTheme(
          backgroundColor: scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          titleTextStyle: TextStyle(
            color: primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          contentTextStyle: TextStyle(color: secondaryText, fontSize: 16),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryDark, // TextButton rengi
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: primaryDark, width: 1.5),
          ),
          labelStyle: TextStyle(color: secondaryText),
          hintStyle: TextStyle(color: Colors.grey[400]),
          iconColor: secondaryText,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: primaryDark,
          linearMinHeight: 6,
          linearTrackColor: Colors.grey[300],
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          // Açılan menünün stilini belirle
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all( // MaterialStateProperty yerine WidgetStateProperty
              scaffoldBackgroundColor,
            ), // Arka plan rengi
            elevation: WidgetStateProperty.all(2.0), // MaterialStateProperty yerine WidgetStateProperty
            shape: WidgetStateProperty.all( // MaterialStateProperty yerine WidgetStateProperty
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            // padding: MaterialStateProperty.all(EdgeInsets.zero), // İç padding (isteğe bağlı)
          ),
          // Input alanının stilini belirle (DropdownButtonFormField için)
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: primaryDark, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 12.0,
            ), // İç padding
          ),
          textStyle: TextStyle(color: primaryText), // Menüdeki yazı stili
        ),
        useMaterial3: true,
      ),
    );
  }
}
