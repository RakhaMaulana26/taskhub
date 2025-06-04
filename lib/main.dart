// lib/main.dart

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:taskhub/features/jadwal/screens/schedule_page.dart';
import 'package:taskhub/config/theme/app_theme.dart'; // Pastikan path ini benar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Schedule App',
          debugShowCheckedModeBanner: false,
          theme: appDarkTheme, // Menerapkan tema dari app_theme.dart
          home: const SchedulePage(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('id', 'ID'),
            // Locale('en', ''),
          ],
          locale: const Locale('id', 'ID'),
        );
      },
    );
  }
}
