import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart'; // NEW
import 'theme_provider.dart'; // NEW

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
      // NEW: Wrap the app in the provider
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
    // Listen to the provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HydroPilot',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // NEW: Theme is now controlled live from the provider
      themeMode: themeProvider.themeMode, 
      
      // Light theme
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: themeProvider.accentColor,
        colorScheme: ColorScheme.light(primary: themeProvider.accentColor),
        scaffoldBackgroundColor: Colors.white,
      ),

      // Dark theme
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