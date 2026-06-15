import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Standard-Werte beim Start
  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = const Color(0xFF00B26B);

  // Werte abrufen
  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;

  // Werte ändern und die ganze App benachrichtigen!
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners(); // Das ist der magische Befehl, der alles neu zeichnet
  }

  void setAccentColor(Color color) {
    _accentColor = color;
    notifyListeners(); 
  }
}