import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // NEU: Die Datenbank
import 'package:firebase_auth/firebase_auth.dart'; // NEU: Der Türsteher (für die User ID)
import 'dashboard_screen.dart';
import 'support_screen.dart';
import 'login_screen.dart';
import 'info_screen.dart';
import 'legal_screen.dart';
import 'add_pot_screen.dart';

class PotsOverviewScreen extends StatefulWidget {
  const PotsOverviewScreen({super.key});

  @override
  State<PotsOverviewScreen> createState() => _PotsOverviewScreenState();
}

class _PotsOverviewScreenState extends State<PotsOverviewScreen> {
  // _showAddDialog wurde entfernt, da du ja den schicken AddPotScreen nutzt!

  @override
  Widget build(BuildContext context) {
    // Hole die ID des aktuell eingeloggten Nutzers
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

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
              onPressed: () {
                // Wir brauchen kein "await" und "setState" mehr!
                // Der StreamBuilder unten aktualisiert die Liste vollautomatisch, 
                // sobald in der Datenbank ein neuer Topf auftaucht!
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPotScreen()),
                );
              },
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
                
                // --- HIER STARTET DIE FIREBASE MAGIE ---
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    // Wir fragen Firebase: "Gib mir alle Töpfe, bei denen die userId meiner eigenen ID entspricht!"
                    stream: FirebaseFirestore.instance
                        .collection('pots')
                        .where('userId', isEqualTo: currentUserId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      // 1. Ladebildschirm zeigen, während Daten aus dem Internet geholt werden
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF00B26B)));
                      }

                      // 2. Fehlermeldung, falls was schiefgeht
                      if (snapshot.hasError) {
                        return const Center(child: Text('Fehler beim Laden der Daten.', style: TextStyle(color: Colors.red)));
                      }

                      // 3. Wenn die Datenbank leer ist (Nutzer hat noch keine Töpfe)
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('Noch keine Töpfe vorhanden.\nKlicke auf Hinzufügen!', 
                            textAlign: TextAlign.center, 
                            style: TextStyle(color: Colors.grey, fontSize: 16)
                          ),
                        );
                      }

                      // 4. Wenn Töpfe da sind, laden wir sie in die Liste!
                      final pots = snapshot.data!.docs;

                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.85
                        ),
                        itemCount: pots.length, 
                        itemBuilder: (context, index) {
                          // Wir übergeben jetzt das gesamte Firebase-Dokument an die Karte
                          return _buildPotCard(context, pots[index]); 
                        },
                      );
                    },
                  ),
                ),
                // --- ENDE DER MAGIE ---
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Die Funktion nimmt jetzt ein echtes Firebase DocumentSnapshot entgegen!
  Widget _buildPotCard(BuildContext context, DocumentSnapshot potDoc) {
    // Wir wandeln das Dokument in eine Map um, damit du es wie vorher nutzen kannst
    Map<String, dynamic> potData = potDoc.data() as Map<String, dynamic>; 
    
    return GestureDetector(
      onTap: () {
        // WICHTIG: Wir übergeben jetzt die echte Firebase-ID (potDoc.id) statt einem simplen Index (0,1,2)!
        Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen(potId: potDoc.id)));
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
            // Falls in der DB noch kein Name steht, zeige "Unbenannt"
            Text(potData['name'] ?? 'Unbenannt', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(potData['location'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.opacity, color: Color(0xFF00B26B), size: 14), 
                Text(potData['moisture'] ?? '0%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.thermostat, color: Colors.orange, size: 14), 
                Text(potData['temp'] ?? '--°C', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))
              ],
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
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red), 
              title: const Text('Abmelden', style: TextStyle(color: Colors.red)), 
              onTap: () async { 
                // NEU: Loggt den User auch wirklich bei Google/Firebase aus!
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())); 
                }
              }
            ),
          ],
        ),
      ),
    );
  }
}