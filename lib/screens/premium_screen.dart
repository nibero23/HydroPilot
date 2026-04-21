import 'package:flutter/material.dart';
import '../widgets/plan_card.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abo & Premium'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        // ... [Behalte den oberen Teil der premium_screen.dart bei, ändere nur die Column:]

        child: Column(
          children: [
            Text('Erweitere deine Möglichkeiten mit HydroPilot Plus oder Pro\nund bring deine Pflanzenpflege auf das nächste Level.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 24),
            
            PlanCard(
              isActive: true, badgeText: 'Aktiv', title: 'Free', subtitle: 'Perfekt zum Starten', price: '€0', priceSuffix: '/für immer',
              features: [{'title': '1 Topf', 'included': true}, {'title': '24h Historie', 'included': true}, {'title': 'Daten Export', 'included': false}],
              buttonText: 'Aktueller Plan', accentColor: Color(0xFF00B26B),
            ),
            SizedBox(height: 24),
            
            PlanCard(
              isActive: false, badgeText: 'Beliebt', title: 'Plus', subtitle: 'Für mehrere Pflanzen', price: '€4,99', priceSuffix: '/pro Monat',
              features: [{'title': 'Bis zu 5 Töpfe', 'included': true}, {'title': '7 Tage Historie', 'included': true}, {'title': 'Daten Export', 'included': true}],
              buttonText: 'Plus wählen', accentColor: Color(0xFF00B26B),
            ),
            SizedBox(height: 24),

            // HIER NEU: Der PRO Plan
            PlanCard(
              isActive: false, badgeText: 'Pro', title: 'Pro', subtitle: 'Für Power-User', price: '€9,99', priceSuffix: '/pro Monat',
              features: [{'title': 'Unbegrenzt Töpfe', 'included': true}, {'title': '30 Tage+ Historie', 'included': true}, {'title': 'Alle Alerts', 'included': true}],
              buttonText: 'Pro wählen', accentColor: Color(0xFF00B26B),
            ),
            SizedBox(height: 40),
          ],
        ),
        
      ),
    );
  }
}