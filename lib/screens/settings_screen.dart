import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Die Zustände für unsere Schalter (Toggles)
  bool pushNotifications = true;
  bool emailNewsletter = false;
  bool darkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // Glocken-Icon mit rotem Punkt
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
              Positioned(
                right: 12,
                top: 12,
                child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), // Damit es am PC gut aussieht
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Sektion: Benachrichtigungen ---
                const Text('Benachrichtigungen', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildSwitchTile('Push-Benachrichtigungen', pushNotifications, (val) => setState(() => pushNotifications = val)),
                _buildSwitchTile('E-Mail Newsletter', emailNewsletter, (val) => setState(() => emailNewsletter = val)),
                const SizedBox(height: 24),

                // --- Sektion: Darstellung ---
                const Text('Darstellung', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildSwitchTile('Dark Mode', darkMode, (val) => setState(() => darkMode = val)),
                const SizedBox(height: 24),

                // --- Sektion: Allgemein ---
                const Text('Allgemein', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildListTile('Sprache', 'Deutsch'),
                _buildListTile('Einheiten', 'Metrisch (°C, cm)'),
                const SizedBox(height: 32),

                // --- Sektion: Gefahrenzone ---
                const Text('Gefahrenzone', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      // Hier kommt später die Lösch-Logik hin
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Konto löschen', style: TextStyle(fontWeight: FontWeight.bold)),
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

  // Hilfsfunktion für die Schalter (Toggles)
  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        value: value,
        activeColor: const Color(0xFF00B26B),
        onChanged: onChanged,
      ),
    );
  }

  // Hilfsfunktion für die Zeilen mit Text und Pfeil
  Widget _buildListTile(String title, String trailingText) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(trailingText, style: const TextStyle(color: Colors.grey)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}