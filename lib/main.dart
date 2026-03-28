import 'package:flutter/material.dart';

import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/history/history_screen.dart';
import 'features/home/home_screen.dart';
import 'features/scanner/result_screen.dart';
import 'features/scanner/scanner_screen.dart';
// add these later when you create them
// import 'features/billing/payment_success_screen.dart';
// import 'features/billing/payment_cancel_screen.dart';

void main() {
  runApp(const StrategosApp());
}

class StrategosApp extends StatelessWidget {
  const StrategosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Strategos by Czarina',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020304),
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF4FA3),
          secondary: Color(0xFFFF4FA3),
          surface: Color(0xFF0F1118),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/scanner': (context) => const ScannerScreen(),

        // optional future routes
        // '/history': (context) => const HistoryScreen(),
        // '/payment-success': (context) => const PaymentSuccessScreen(),
        // '/payment-cancel': (context) => const PaymentCancelScreen(),
      },
    );
  }
}