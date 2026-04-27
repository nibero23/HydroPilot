import 'package:flutter/material.dart';

class PlantLibraryScreen extends StatefulWidget {
  const PlantLibraryScreen({super.key});

  @override
  State<PlantLibraryScreen> createState() => _PlantLibraryScreenState();
}

class _PlantLibraryScreenState extends State<PlantLibraryScreen> {
  final List<Map<String, String>> allPlants = [
    {'name': 'Monstera Deliciosa', 'info': 'Mittel - 40% Feuchte', 'image': '🌿'},
    {'name': 'Basilikum', 'info': 'Hoch - 60% Feuchte', 'image': '🍃'},
    {'name': 'Aloe Vera', 'info': 'Niedrig - 20% Feuchte', 'image': '🌵'},
    {'name': 'Tomate', 'info': 'Hoch - 65% Feuchte', 'image': '🍅'},
    {'name': 'Ficus Elastica', 'info': 'Mittel - 45% Feuchte', 'image': '🌳'},
    {'name': 'Orchidee', 'info': 'Mittel - 50% Feuchte', 'image': '🌸'},
    {'name': 'Schlangenpflanze', 'info': 'Niedrig - 15% Feuchte', 'image': '🐍'},
    {'name': 'Zitronenbaum', 'info': 'Hoch - 55% Feuchte', 'image': '🍋'},
  ];

  List<Map<String, String>> displayedPlants = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    displayedPlants = allPlants;
  }

  void _filterPlants(String query) {
    setState(() {
      displayedPlants = allPlants
          .where((p) => p['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12171E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Pflanze suchen...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: _filterPlants,
              )
            : const Text('Pflanzenbibliothek', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _filterPlants('');
              }
            }),
          ),
        ],
      ),
      // RETTUNG: Center + ConstrainedBox begrenzen die Breite auf dem Laptop
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), 
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: displayedPlants.isEmpty
                ? const Center(child: Text('Keine Pflanze gefunden.', style: TextStyle(color: Colors.grey)))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 150, // Verhindert, dass Kacheln zu breit werden
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8, // Sorgt für ein schönes Hochformat
                    ),
                    itemCount: displayedPlants.length,
                    itemBuilder: (context, index) {
                      final plant = displayedPlants[index];
                      return _buildPlantCard(plant);
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantCard(Map<String, String> plant) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C232D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Das Icon hat jetzt eine feste Größe und "explodiert" nicht mehr
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A3441).withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Text(plant['image']!, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 12),
          Text(
            plant['name']!,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            plant['info']!.split(' - ')[0], // Kürzt den Text für die kleine Kachel
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}