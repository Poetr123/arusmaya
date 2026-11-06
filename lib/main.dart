import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal Indonesia.
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ArusMayaApp());
}

class ArusMayaApp extends StatelessWidget {
  const ArusMayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArusMaya',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      // Konfigurasi bahasa aplikasi.
      locale: const Locale('id', 'ID'),

      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const SplashScreen(),
    );
  }
}
