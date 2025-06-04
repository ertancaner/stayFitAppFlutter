import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tarih formatlaması için eklendi
import 'package:stay_fit/src/app.dart';
import 'package:firebase_core/firebase_core.dart'; // Gelecekte Firebase için
import 'firebase_options.dart'; // Gelecekte Firebase için
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Ortam değişkenleri için eklendi

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe tarih formatlamasını başlat
  await initializeDateFormatting('tr_TR', null);

  // .env dosyasını yükle
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: App()));
}
