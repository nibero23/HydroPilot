import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // NEU
import 'package:firebase_auth/firebase_auth.dart';    // NEU

class AddPotScreen extends StatefulWidget {
  const AddPotScreen({super.key});

  @override
  State<AddPotScreen> createState() => _AddPotScreenState();
}

class _AddPotScreenState extends State<AddPotScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;

  Future<void> _savePot() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte gib einen Namen für den Topf ein.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Die ID des aktuell eingeloggten Users holen
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 2. Daten an Firestore senden
      await FirebaseFirestore.instance.collection('pots').add({
        'name': _nameController.text.trim(),
        'location': _locationController.text.trim().isEmpty 
                    ? 'Unbekannter Ort' 
                    : _locationController.text.trim(),
        'userId': user.uid,          // WICHTIG: Damit der Topf nur dir gehört
        'moisture': '0%',            // Startwerte
        'temp': '--°C',
        'createdAt': FieldValue.serverTimestamp(), // Sortierung nach Erstellungsdatum
        'schedules': [],             // Leere Liste für Gießpläne
      });

      if (mounted) {
        Navigator.pop(context); // Zurück zur Übersicht
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Speichern: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12171E),
      appBar: AppBar(
        title: const Text('Neuer Topf'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Name der Pflanze',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1C232D),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Standort (z.B. Wohnzimmer)',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1C232D),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B26B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _savePot,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('In der Cloud speichern', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}