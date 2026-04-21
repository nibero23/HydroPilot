import 'package:flutter/material.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  int _selectedIndex = 0; // 0 = Impressum, 1 = Datenschutz

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impressum & Datenschutz', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text('Rechtliches', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Der Schalter (Impressum / Datenschutz)
            Container(
              decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedIndex == 0 ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: Text('Impressum', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedIndex == 1 ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: Text('Datenschutz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Zeige den jeweiligen Text basierend auf der Auswahl
            _selectedIndex == 0 ? _buildImpressum() : _buildDatenschutz(),
          ],
        ),
      ),
    );
  }

  Widget _buildImpressum() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Impressum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 16),
        Text(
          'HydroPilot GmbH\nMusterstraße 42\n12345 Berlin\nDeutschland\n\nE-Mail: info@hydropilot.app\nTelefon: +49 30 123456\n\nGeschäftsführer: Max Mustermann\n\nHandelsregister: HRB 12345, Amtsgericht Berlin-Charlottenburg\n\nUSt-IdNr.: DE123456789',
          style: TextStyle(color: Colors.grey, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildDatenschutz() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Datenschutzerklärung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 16),
        Text('Der Schutz Ihrer persönlichen Daten ist uns ein besonderes Anliegen. Wir verarbeiten Ihre Daten daher ausschließlich auf Grundlage der gesetzlichen Bestimmungen (DSGVO, TKG 2003).', style: TextStyle(color: Colors.grey, height: 1.5)),
        SizedBox(height: 20),
        Text('Erfasste Daten', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 8),
        Text('Wir erfassen E-Mail-Adresse und Name bei der Registrierung. Sensordaten (Bodenfeuchte, Temperatur, Luftfeuchtigkeit, Tankstand, Akkustand) werden verschlüsselt übertragen und auf unseren Servern gespeichert.', style: TextStyle(color: Colors.grey, height: 1.5)),
        SizedBox(height: 20),
        Text('Nutzung der Daten', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 8),
        Text('Ihre Daten werden ausschließlich zur Bereitstellung der App-Funktionen verwendet. Eine Weitergabe an Dritte erfolgt nicht.', style: TextStyle(color: Colors.grey, height: 1.5)),
        SizedBox(height: 20),
        Text('Ihre Rechte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 8),
        Text('Sie haben jederzeit das Recht auf Auskunft, Berichtigung, Löschung und Einschränkung der Verarbeitung Ihrer Daten.', style: TextStyle(color: Colors.grey, height: 1.5)),
      ],
    );
  }
}