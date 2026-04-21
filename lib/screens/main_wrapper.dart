import 'package:flutter/material.dart';
import 'pots_overview_screen.dart';
import 'premium_screen.dart';
import 'support_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      // HIER WAR DER FEHLER: Das (pots: ...) ist jetzt weg!
      const PotsOverviewScreen(), 
      const PremiumScreen(),
      const SupportScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFF1C232D),
        selectedItemColor: const Color(0xFF00B26B),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Töpfe'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Premium'),
          BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: 'Support'),
        ],
      ),
    );
  }
}