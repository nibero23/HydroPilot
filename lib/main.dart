import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart'; // NEU
import 'theme_provider.dart'; // NEU

import 'firebase_options.dart'; 
import 'screens/login_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('de'), Locale('en'), Locale('tr'), Locale('fr'), Locale('es')],
      path: 'assets/translations', 
      fallbackLocale: const Locale('de'),
      // NEU: Hier wickeln wir die App in den Provider ein
      child: ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const HydroPilotApp(),
      ),
    ),
  );
}

class HydroPilotApp extends StatelessWidget {
  const HydroPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Hier hören wir auf den Lautsprecher!
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HydroPilot',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // NEU: Das Theme wird jetzt live aus dem Provider gesteuert
      themeMode: themeProvider.themeMode, 
      
      // Helles Theme
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: themeProvider.accentColor,
        colorScheme: ColorScheme.light(primary: themeProvider.accentColor),
        scaffoldBackgroundColor: Colors.white,
      ),

      // Dunkles Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: themeProvider.accentColor,
        colorScheme: ColorScheme.dark(primary: themeProvider.accentColor),
        scaffoldBackgroundColor: const Color(0xFF12171E),
      ),
      
      home: const LoginScreen(), 
    );
  }
}