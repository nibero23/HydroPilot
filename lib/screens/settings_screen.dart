  import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _minMoisture = 30;
  double _pauseTime = 75;
  double _maxPumpTime = 35;

  bool _notifyAll = true;
  bool _notifyDry = true;
  bool _notifyTank = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schwellenwerte & Steuerung'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slider Bereich
            _buildSectionContainer(
              Column(
                children: [
                  _buildSlider('Feuchte-Minimum', _minMoisture, 0, 100, '%', (v) => setState(() => _minMoisture = v)),
                  const Divider(color: Colors.grey),
                  _buildSlider('Mindestpause', _pauseTime, 0, 120, ' Min.', (v) => setState(() => _pauseTime = v)),
                  const Divider(color: Colors.grey),
                  _buildSlider('Max. Pumpzeit', _maxPumpTime, 0, 60, ' Sek.', (v) => setState(() => _maxPumpTime = v)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Kalibrierung
            _buildSectionContainer(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kalibrierung', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildCalibButton('Trocken (Dry)')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildCalibButton('Feucht (Wet)')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Benachrichtigungen
            _buildSectionContainer(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Benachrichtigungen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SwitchListTile(
                    title: const Text('Alle Benachrichtigungen'),
                    value: _notifyAll,
                    activeThumbColor: const Color(0xFF00B26B),
                    onChanged: (v) => setState(() => _notifyAll = v),
                  ),
                  SwitchListTile(
                    title: const Text('Boden trocken'),
                    value: _notifyDry,
                    activeThumbColor: const Color(0xFF00B26B),
                    onChanged: (v) => setState(() => _notifyDry = v),
                  ),
                  SwitchListTile(
                    title: const Text('Tank niedrig'),
                    value: _notifyTank,
                    activeThumbColor: const Color(0xFF00B26B),
                    onChanged: (v) => setState(() => _notifyTank = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C232D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildSlider(String title, double value, double min, double max, String unit, Function(double) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text('${value.toInt()}$unit', style: const TextStyle(color: Color(0xFF00B26B), fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: const Color(0xFF00B26B),
          inactiveColor: Colors.grey.withOpacity(0.3),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCalibButton(String title) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {},
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const Text('—', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}