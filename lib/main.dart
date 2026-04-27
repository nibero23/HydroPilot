import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // NEU
import 'firebase_options.dart'; // Diese Datei wird gleich von Firebase generiert!
import 'screens/login_screen.dart';

void main() async {
  // NEU: Diese beiden Zeilen starten Firebase, bevor die App lädt
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HydroPilotApp());
}

class HydroPilotApp extends StatelessWidget {
  const HydroPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HydroPilot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF12171E),
        primaryColor: const Color(0xFF00B26B),
      ),
      home: const LoginScreen(),
    );
  }
}