import 'package:flutter/material.dart';
import 'plant_library_screen.dart';
import '../database.dart'; // Um den fertigen Topf am Ende zu speichern

class AddPotScreen extends StatefulWidget {
  const AddPotScreen({super.key});

  @override
  State<AddPotScreen> createState() => _AddPotScreenState();
}

class _AddPotScreenState extends State<AddPotScreen> {
  int _currentStep = 0; // 0: Start, 1: Suche, 2: WLAN, 3: Konfiguration, 4: Erfolg

  // Eingegebene Daten merken
  String _selectedWifi = "";
  String _potName = "";
  String _location = "Wohnzimmer";
  String _selectedPlant = "Pflanze wählen"; // Hier landet die Auswahl aus der Bibliothek

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  // Simuliert die Bluetooth-Suche
  void _startSearch() async {
    _nextStep(); // Geht zu Schritt 1 (Ladebildschirm)
    await Future.delayed(const Duration(seconds: 3)); // 3 Sekunden warten
    if (mounted) _nextStep(); // Geht zu Schritt 2 (WLAN)
  }

  // Am Ende in unserer Dummy-Datenbank speichern
  void _savePotAndFinish() {
    setState(() {
      globalPots.add({
        'name': _potName.isEmpty ? 'Neuer Topf' : _potName,
        'location': _location,
        'moisture': '0%',
        'temp': '--°C',
        'schedules': []
      });
    });
    _nextStep(); // Geht zu Schritt 4 (Erfolg)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topf hinzufügen', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStep(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep0Start();
      case 1:
        return _buildStep1Searching();
      case 2:
        return _buildStep2WLAN();
      case 3:
        return _buildStep3Config();
      case 4:
        return _buildStep4Success();
      default:
        return const SizedBox();
    }
  }

  // --- SCHRITT 0: Bluetooth Einleitung ---
  Widget _buildStep0Start() {
    return Column(
      key: const ValueKey(0),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.bluetooth_searching, size: 80, color: Color(0xFF00B26B)),
        const SizedBox(height: 30),
        const Text('Neuen Topf finden', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        const Text(
          'Stelle sicher, dass der HydroPilot am Strom angeschlossen ist und die Status-LED blau blinkt.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 50),
        _buildButton('Gerät suchen', _startSearch),
      ],
    );
  }

  // --- SCHRITT 1: Lade-Screen ---
  Widget _buildStep1Searching() {
    return Column(
      key: const ValueKey(1),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Color(0xFF00B26B)),
        const SizedBox(height: 30),
        const Text('Sensordaten werden gesucht...', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('Bitte bleibe in der Nähe des Topfes.', style: TextStyle(color: Colors.grey.withValues(alpha: 0.8))),
      ],
    );
  }

  // --- SCHRITT 2: WLAN einrichten ---
  Widget _buildStep2WLAN() {
    return Column(
      key: const ValueKey(2),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF00B26B).withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.wifi, size: 50, color: Color(0xFF00B26B))),
        ),
        const SizedBox(height: 30),
        const Center(child: Text('WLAN einrichten', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
        const SizedBox(height: 30),
        const Text('Netzwerk (SSID)', style: TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(color: Colors.white),
          onChanged: (val) => _selectedWifi = val,
          decoration: _inputStyle('z.B. FRITZ!Box 7590', Icons.wifi),
        ),
        const SizedBox(height: 20),
        const Text('WLAN Passwort', style: TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: _inputStyle('Passwort eingeben', Icons.lock_outline),
        ),
        const SizedBox(height: 50),
        _buildButton('Topf mit WLAN verbinden', _nextStep),
      ],
    );
  }

  // --- SCHRITT 3: Konfiguration & Pflanzenwahl ---
  Widget _buildStep3Config() {
    return Column(
      key: const ValueKey(3),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: Text('Topf konfigurieren', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
        const SizedBox(height: 30),
        const Text('Name des Topfes', style: TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          onChanged: (val) => _potName = val,
          style: const TextStyle(color: Colors.white),
          decoration: _inputStyle('z.B. Mein Lieblingsbasilikum', Icons.edit),
        ),
        const SizedBox(height: 20),
        const Text('Standort', style: TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          onChanged: (val) => _location = val,
          style: const TextStyle(color: Colors.white),
          decoration: _inputStyle('z.B. Wohnzimmer', Icons.location_on_outlined),
        ),
        const SizedBox(height: 30),
        
        // HIER: Der Link zur Pflanzenbibliothek!
        const Text('Welche Pflanze ist im Topf?', style: TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            // Wir öffnen die Bibliothek und warten auf die Antwort
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlantLibraryScreen()),
            );
            // Wenn eine Pflanze ausgewählt wurde, speichern wir sie
            if (result != null && result is String) {
              setState(() => _selectedPlant = result);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_florist, color: Color(0xFF00B26B)),
                    const SizedBox(width: 12),
                    Text(_selectedPlant, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 50),
        _buildButton('Speichern', _savePotAndFinish),
      ],
    );
  }

  // --- SCHRITT 4: Erfolg ---
  Widget _buildStep4Success() {
    return Column(
      key: const ValueKey(4),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, size: 100, color: Color(0xFF00B26B)),
        const SizedBox(height: 30),
        const Text('Erfolgreich hinzugefügt!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Text('$_potName ist jetzt online und bereit.', style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 50),
        _buildButton('Zum Dashboard', () {
          Navigator.pop(context); // Schließt den Flow und geht zurück zur Übersicht
        }),
      ],
    );
  }

  // --- Hilfs-Widgets ---
  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00B26B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF1C232D),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}