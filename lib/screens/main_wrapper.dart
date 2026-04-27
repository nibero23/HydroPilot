import 'package:flutter/material.dart';
import 'pots_overview_screen.dart';
import 'plant_library_screen.dart'; // Die neue Bibliothek importieren
import 'premium_screen.dart';
import 'settings_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  // Hier definieren wir die 4 Screens für die 4 Tabs
  final List<Widget> _screens = [
    const PotsOverviewScreen(),
    const PlantLibraryScreen(), // NEU: Bibliothek als Tab
    const PremiumScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed, // Sorgt dafür, dass sich die Icons bei 4 Tabs nicht verschieben
        backgroundColor: const Color(0xFF1C232D),
        selectedItemColor: const Color(0xFF00B26B),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Töpfe'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Bibliothek'), // NEU
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Premium'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Einstellungen'),
        ],
      ),
    );
  }
}