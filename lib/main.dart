// lib/main.dart

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:taskhub/features/jadwal/screens/schedule_page.dart';
import 'package:taskhub/config/theme/app_theme.dart'; // Pastikan path ini benar
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
