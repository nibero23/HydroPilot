import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPotScreen extends StatefulWidget {
  const AddPotScreen({super.key});

  @override
  State<AddPotScreen> createState() => _AddPotScreenState();
}

class _AddPotScreenState extends State<AddPotScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0 bis 3
  
  // Controller für die Eingaben
  final _ssidController = TextEditingController();
  final _wifiPasswordController = TextEditingController();
  final _potNameController = TextEditingController();
  final _plantController = TextEditingController();
  
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isSaving = false;

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  // Simulation der Bluetooth-Suche
  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(seconds: 2)); // Simuliert Scan-Zeit
    setState(() => _isScanning = false);
  }

  // Simulation der WLAN-Verbindung & Speichern in Firestore
  Future<void> _finishSetup() async {
    if (_potNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte gib einen Namen ein.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('pots').add({
          'name': _potNameController.text.trim(),
          'plant': _plantController.text.trim(),
          'userId': user.uid,
          'moisture': '0%',
          'temp': '--°C',
          'humidity': '0%',
          'tank': '0%',
          'battery': '100%',
          'pumpState': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        _nextStep(); // Zum Erfolgs-Screen
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12171E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _prevStep,
        ),
        title: const Text('Topf hinzufügen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // FORTSCHRITTSBALKEN (Wie im Screenshot)
          _buildProgressBar(),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Navigation nur über Buttons
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildStepBluetooth(),
                _buildStepWifi(),
                _buildStepNaming(),
                _buildStepSuccess(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          bool isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF00B26B) : Colors.white10,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // SCHRITT 1: BLUETOOTH SUCHE
  Widget _buildStepBluetooth() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bluetooth, size: 80, color: Colors.white),
          const SizedBox(height: 32),
          const Text('Gerät suchen', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text(
            'Stelle sicher, dass dein HydroPilot\neingeschaltet und in der Nähe ist.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 40),
          
          // Gerät gefunden Kachel
          GestureDetector(
            onTap: _nextStep,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFF00B26B).withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.eco, color: Color(0xFF00B26B)),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HydroPilot ESP32', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('HP-ESP32-A1B2', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 55),
              side: const BorderSide(color: Colors.white10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _isScanning ? null : _startScan,
            icon: _isScanning 
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.bluetooth, color: Colors.white, size: 18),
            label: Text(_isScanning ? 'Suche...' : 'Erneut suchen', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // SCHRITT 2: WLAN KONFIGURATION
  Widget _buildStepWifi() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Color(0xFF4A80F0), shape: BoxShape.circle),
            child: const Icon(Icons.wifi, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 32),
          const Text('WLAN einrichten', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Verbinde dein Gerät mit deinem Heimnetzwerk.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          
          _buildInputLabel('Netzwerkname (SSID)'),
          _buildTextField(_ssidController, 'z.B. Zuhause-5GHz'),
          const SizedBox(height: 20),
          _buildInputLabel('Passwort'),
          _buildTextField(_wifiPasswordController, 'WLAN-Passwort', isPassword: true),
          
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B26B),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _nextStep,
            child: const Text('Verbinden', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // SCHRITT 3: GERÄT BENENNEN
  Widget _buildStepNaming() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Color(0xFF00B26B), shape: BoxShape.circle),
            child: const Icon(Icons.eco, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 32),
          const Text('Gerät benennen', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Gib deinem Topf einen Namen und optional die Pflanze.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          
          _buildInputLabel('Topf-Name *'),
          _buildTextField(_potNameController, 'z.B. Wohnzimmer Monstera'),
          const SizedBox(height: 20),
          _buildInputLabel('Pflanze (optional)'),
          _buildTextField(_plantController, 'z.B. Monstera Deliciosa'),
          
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B26B),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _isSaving ? null : _finishSetup,
            child: _isSaving 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Fertigstellen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // SCHRITT 4: ERFOLG
  Widget _buildStepSuccess() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Color(0xFF00B26B), shape: BoxShape.circle),
            child: const Icon(Icons.check, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 32),
          const Text('Fertig!', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            '${_potNameController.text} ist verbunden und einsatzbereit.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B26B),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Zu meinen Töpfen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // HILFS-WIDGETS
  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
        filled: true,
        fillColor: const Color(0xFF1C232D),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}