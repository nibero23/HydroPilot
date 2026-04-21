import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const HydroPilotApp());
}

class HydroPilotApp extends StatelessWidget {
  const HydroPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HydroPilot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF12171E),
        // HIER GEÄNDERT: 'brightness: Brightness.dark' zwingt die Schrift auf Weiß
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF00B26B),
          primary: const Color(0xFF00B26B),
          surface: const Color(0xFF1C232D),
        ),
        // Globale Textfarben explizit auf Weiß setzen
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white, // Macht die AppBar-Texte und Icons weiß
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const LoginScreen(), 
    );
  }
}