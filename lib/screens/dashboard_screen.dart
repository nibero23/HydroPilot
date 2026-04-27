import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // NEU: Damit wir in der Cloud suchen können

class DashboardScreen extends StatefulWidget {
  final String potId; // Geändert von int potIndex zu String potId

  const DashboardScreen({super.key, required this.potId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12171E),
      appBar: AppBar(
        title: const Text('Topf Details'),
        backgroundColor: Colors.transparent,
      ),
      // Wir nutzen wieder einen StreamBuilder, um die Daten dieses EINEN Topfes live zu zeigen
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pots')
            .doc(widget.potId) // Suche genau das Dokument mit dieser ID
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00B26B)));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Topf nicht gefunden.', style: TextStyle(color: Colors.white)));
          }

          // Hier sind die echten Daten aus der Cloud!
          var potData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  potData['name'] ?? 'Unbenannt',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text(
                  potData['location'] ?? 'Kein Standort',
                  style: const TextStyle(color: Colors.grey, fontSize: 18),
                ),
                const SizedBox(height: 40),
                
                // Beispiel für eine Daten-Anzeige (Feuchtigkeit)
                _buildInfoCard('Bodenfeuchtigkeit', potData['moisture'] ?? '0%', Icons.opacity, Colors.blue),
                const SizedBox(height: 16),
                _buildInfoCard('Temperatur', potData['temp'] ?? '--°C', Icons.thermostat, Colors.orange),
                
                // Hier kommt später dein Graph und die Zeitpläne rein...
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}