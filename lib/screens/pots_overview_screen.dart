import 'package:flutter/material.dart';
import '../database.dart'; // HIER importieren wir die Datenbank
import 'dashboard_screen.dart';
import 'support_screen.dart';
import 'login_screen.dart';
import 'info_screen.dart';
import 'legal_screen.dart';

class PotsOverviewScreen extends StatefulWidget {
  const PotsOverviewScreen({super.key});

  @override
  State<PotsOverviewScreen> createState() => _PotsOverviewScreenState();
}

class _PotsOverviewScreenState extends State<PotsOverviewScreen> {
  void _showAddDialog() {
    String newName = "";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C232D),
          title: const Text('Neuen Topf hinzufügen', style: TextStyle(color: Colors.white)),
          content: TextField(
            style: const TextStyle(color: Colors.white),
            onChanged: (value) => newName = value,
            decoration: const InputDecoration(hintText: 'Z.B. Monstera', hintStyle: TextStyle(color: Colors.grey)),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B26B)),
              onPressed: () {
                if (newName.isNotEmpty) {
                  setState(() {
                    // Speichert den neuen Topf direkt in der globalen Datenbank
                    globalPots.add({'name': newName, 'location': 'Neu hinzugefügt', 'moisture': '0%', 'temp': '--°C', 'schedules': []});
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Speichern', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('Meine Töpfe', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF00B26B)),
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Hinzufügen', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(backgroundColor: const Color(0xFF1C232D), foregroundColor: Colors.white),
                  onPressed: () {}, icon: const Icon(Icons.tune, size: 16), label: const Text('Anpassen'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.85),
                    itemCount: globalPots.length, // Lade Anzahl aus Datenbank
                    itemBuilder: (context, index) {
                      return _buildPotCard(context, index); // Wir übergeben nur noch die Nummer (Index)!
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPotCard(BuildContext context, int index) {
    Map<String, dynamic> potData = globalPots[index]; // Lade Daten aus Datenbank
    
    return GestureDetector(
      onTap: () async {
        // Wir schicken das Dashboard los und sagen ihm: "Lade Topf Nummer X"
        await Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen(potIndex: index)));
        // Wenn man zurückkommt, Seite neu laden, falls Zeitpläne dazukamen
        setState(() {}); 
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF00B26B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.water_drop, color: Color(0xFF00B26B), size: 28),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFF00B26B)), borderRadius: BorderRadius.circular(12)),
                  child: const Text('OK', style: TextStyle(color: Color(0xFF00B26B), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(potData['name'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(potData['location'], style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Icon(Icons.opacity, color: Color(0xFF00B26B), size: 14), Text(potData['moisture'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Icon(Icons.thermostat, color: Colors.orange, size: 14), Text(potData['temp'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF12171E),
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF00B26B), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.water_drop, color: Colors.white)),
              title: const Text('HydroPilot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: const Text('Smart Watering', style: TextStyle(color: Colors.grey)),
              trailing: IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
            ),
            const Divider(color: Colors.grey),
            ListTile(leading: const Icon(Icons.help_outline, color: Colors.white), title: const Text('Support', style: TextStyle(color: Colors.white)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportScreen()))),
            ListTile(leading: const Icon(Icons.info_outline, color: Colors.white), title: const Text('Über HydroPilot', style: TextStyle(color: Colors.white)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InfoScreen()))),
            ListTile(leading: const Icon(Icons.shield_outlined, color: Colors.white), title: const Text('Impressum & Datenschutz', style: TextStyle(color: Colors.white)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LegalScreen()))),
            const Spacer(),
            const Divider(color: Colors.grey),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Abmelden', style: TextStyle(color: Colors.red)), onTap: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())); }),
          ],
        ),
      ),
    );
  }
}