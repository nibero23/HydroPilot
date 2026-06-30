import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _selectedLanguage;
  String _selectedUnit = 'Metrisch (°C)';
  bool _analyticsEnabled = true;
  bool _loadingDemo = false;

  Future<void> _loadDemoData() async {
    setState(() => _loadingDemo = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final potsSnap = await FirebaseFirestore.instance
          .collection('pots')
          .where('userId', isEqualTo: uid)
          .get();

      final rng = Random();
      final now = DateTime.now();

      for (final doc in potsSnap.docs) {
        // Aktuelle Sensorwerte
        await doc.reference.update({
          'moisture': '65%',
          'temp': '22°C',
          'humidity': '58%',
          'tank': '74%',
          'battery': '89%',
          'pumpState': false,
        });

        // 120 Historien-Punkte (alle 6 Stunden = 30 Tage)
        final histRef = doc.reference.collection('history');
        // Firestore batch max 500 Ops – 120 passt
        final batch = FirebaseFirestore.instance.batch();
        for (int i = 119; i >= 0; i--) {
          final ts = Timestamp.fromDate(now.subtract(Duration(hours: i * 6)));
          final moisture = 50 + 22 * sin(i * pi / 10) + rng.nextInt(6) - 3;
          final temp = 21 + 4 * sin(i * pi / 16) + rng.nextDouble() * 1.5;
          final humidity = 55 + 14 * sin(i * pi / 12) + rng.nextInt(5) - 2;
          batch.set(histRef.doc(), {
            'timestamp': ts,
            'moisture': moisture.clamp(20, 100).round(),
            'temp': double.parse(temp.clamp(15, 35).toStringAsFixed(1)),
            'humidity': humidity.clamp(20, 90).round(),
          });
        }
        await batch.commit();

        // Demo-Zeitplan (falls noch keiner existiert)
        final schedSnap = await doc.reference.collection('schedules').limit(1).get();
        if (schedSnap.docs.isEmpty) {
          await doc.reference.collection('schedules').add({
            'time': '08:00',
            'days': [0, 1, 2, 3, 4],
            'duration': 30,
            'active': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Demo-Daten erfolgreich geladen!'),
            ],
          ),
          backgroundColor: const Color(0xFF00B26B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loadingDemo = false);
    }
  }

  final List<String> _languages = ['DE Deutsch', 'GB English', 'TR Türkçe', 'FR Français', 'ES Español'];
  final List<String> _units = ['Metrisch (°C)', 'Imperial (°F)'];

  final List<Color> _accentColors = [
    const Color(0xFF00B26B), const Color(0xFF0D6B60), const Color(0xFF006494),
    const Color(0xFF264653), const Color(0xFF4B3E65), const Color(0xFF8A2342),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String currentCode = context.locale.languageCode;
    switch (currentCode) {
      case 'en': _selectedLanguage = 'GB English'; break;
      case 'tr': _selectedLanguage = 'TR Türkçe'; break;
      case 'fr': _selectedLanguage = 'FR Français'; break;
      case 'es': _selectedLanguage = 'ES Español'; break;
      case 'de':
      default: _selectedLanguage = 'DE Deutsch'; break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hier rufen wir die aktuelle Akzentfarbe ab!
    final primaryColor = Theme.of(context).primaryColor;
    // Wir holen uns den Provider, um ihn später per Button ändern zu können
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Wir ermitteln, welches Theme gerade aktiv ist, um den Button richtig zu markieren
    String currentThemeLabel = 'system';
    if (themeProvider.themeMode == ThemeMode.light) currentThemeLabel = 'light';
    if (themeProvider.themeMode == ThemeMode.dark) currentThemeLabel = 'dark';

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Reagiert jetzt auf Hell/Dunkel
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThemeCard(currentThemeLabel, themeProvider, primaryColor),
                _buildAccentColorCard(themeProvider, primaryColor),
                _buildLanguageAndUnitsCard(primaryColor),
                _buildPrivacyCard(primaryColor),
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor, // Nutzt die globale Farbe!
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      switch (_selectedLanguage) {
                        case 'GB English': context.setLocale(const Locale('en')); break;
                        case 'TR Türkçe': context.setLocale(const Locale('tr')); break;
                        case 'FR Français': context.setLocale(const Locale('fr')); break;
                        case 'ES Español': context.setLocale(const Locale('es')); break;
                        case 'DE Deutsch':
                        default: context.setLocale(const Locale('de')); break;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('settings_saved'.tr(), style: const TextStyle(color: Colors.white)), 
                          backgroundColor: primaryColor,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_outlined, color: Colors.white),
                    label: Text('save_settings'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _loadingDemo ? null : _loadDemoData,
                    icon: _loadingDemo
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey))
                        : const Icon(Icons.science_outlined, color: Colors.grey, size: 20),
                    label: Text(
                      _loadingDemo ? 'Wird geladen...' : 'Demo-Daten laden',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required String title, required IconData icon, required Widget child, required Color primaryColor}) {
    // Ob wir im hellen oder dunklen Modus sind
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151A22) : Colors.grey.shade100, // Reagiert auf Hell/Dunkel
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha:0.05) : Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 20), // Globale Farbe!
              const SizedBox(width: 12),
              Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildThemeCard(String currentThemeLabel, ThemeProvider provider, Color primaryColor) {
    return _buildSettingsCard(
      title: 'appearance'.tr(),
      icon: Icons.light_mode_outlined,
      primaryColor: primaryColor,
      child: Row(
        children: [
          _buildThemeOption('light'.tr(), 'light', Icons.light_mode_outlined, currentThemeLabel, () => provider.setThemeMode(ThemeMode.light), primaryColor),
          const SizedBox(width: 12),
          _buildThemeOption('dark'.tr(), 'dark', Icons.dark_mode_outlined, currentThemeLabel, () => provider.setThemeMode(ThemeMode.dark), primaryColor),
          const SizedBox(width: 12),
          _buildThemeOption('system'.tr(), 'system', Icons.desktop_windows_outlined, currentThemeLabel, () => provider.setThemeMode(ThemeMode.system), primaryColor),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String label, String value, IconData icon, String currentTheme, VoidCallback onTap, Color primaryColor) {
    bool isSelected = currentTheme == value;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.black87;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap, // HIER ÄNDERN WIR DAS THEME LIVE!
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.transparent : (isDark ? const Color(0xFF222831) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? primaryColor : Colors.transparent, width: 2),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? primaryColor : Colors.grey, size: 24),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: isSelected ? textColor : Colors.grey, fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccentColorCard(ThemeProvider provider, Color primaryColor) {
    return _buildSettingsCard(
      title: 'accent_color'.tr(),
      icon: Icons.color_lens_outlined,
      primaryColor: primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _accentColors.map((color) => _buildColorCircle(color, provider, primaryColor)).toList(),
          ),
          const SizedBox(height: 16),
          Text('color_desc'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildColorCircle(Color color, ThemeProvider provider, Color currentPrimary) {
    bool isSelected = currentPrimary == color;
    return GestureDetector(
      onTap: () => provider.setAccentColor(color), // HIER ÄNDERN WIR DIE FARBE LIVE!
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: color, shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, width: 3) : null,
        ),
        child: isSelected 
          ? Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))) 
          : null,
      ),
    );
  }

  Widget _buildLanguageAndUnitsCard(Color primaryColor) {
    return _buildSettingsCard(
      title: 'language_units'.tr(),
      icon: Icons.language_outlined,
      primaryColor: primaryColor,
      child: Column(
        children: [
          _buildDropdownRow(title: 'language'.tr(), subtitle: 'app_language'.tr(), currentValue: _selectedLanguage, items: _languages, onChanged: (val) => setState(() => _selectedLanguage = val!)),
          const SizedBox(height: 24),
          _buildDropdownRow(title: 'units'.tr(), subtitle: 'temp_display'.tr(), currentValue: _selectedUnit, items: _units, onChanged: (val) => setState(() => _selectedUnit = val!)),
        ],
      ),
    );
  }

  Widget _buildDropdownRow({required String title, required String subtitle, required String currentValue, required List<String> items, required ValueChanged<String?> onChanged}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        Container(
          width: 170,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF151A22) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha:0.2) : Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentValue,
              dropdownColor: isDark ? const Color(0xFF222831) : Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              isExpanded: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
              onChanged: onChanged,
              selectedItemBuilder: (context) => items.map<Widget>((item) => Container(alignment: Alignment.centerLeft, child: Text(item))).toList(),
              items: items.map<DropdownMenuItem<String>>((value) => DropdownMenuItem<String>(value: value, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(value), if (currentValue == value) Icon(Icons.check, color: Theme.of(context).primaryColor, size: 18)]))).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyCard(Color primaryColor) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildSettingsCard(
      title: 'privacy'.tr(),
      icon: Icons.shield_outlined,
      primaryColor: primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('analytics'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('analytics_desc'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _analyticsEnabled,
            activeThumbColor: primaryColor,
            inactiveTrackColor: isDark ? const Color(0xFF222831) : Colors.grey.shade300,
            onChanged: (val) => setState(() => _analyticsEnabled = val),
          ),
        ],
      ),
    );
  }
}