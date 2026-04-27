import 'dart:async'; // WICHTIG: Wird für den Cooldown-Timer benötigt!
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/metric_card.dart';
import '../database.dart';

class DashboardScreen extends StatefulWidget {
  final int potIndex;
  const DashboardScreen({super.key, required this.potIndex});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedChart = 0; 
  int _selectedTimeframe = 0; 
  
  bool notifySoilDry = true;
  bool notifyTankEmpty = true;

  // --- NEU: ZUSTÄNDE FÜR DEN COOLDOWN ---
  double _wateringDuration = 35.0; // Standardwert
  bool _isWatering = false; // Läuft die Pumpe gerade?
  bool _isCooldown = false; // Ist die Pumpe in der Sickerpause?
  int _remainingSeconds = 0;
  Timer? _timer;

  // Zustände für die Bibliothek
  bool _isLibraryExpanded = false;
  String _selectedCategory = 'Alle';
  String _searchQuery = '';

  final List<Map<String, String>> allPlants = [
    {'name': 'Tomate', 'category': 'Gemüse', 'image': '🍅'},
    {'name': 'Gurke', 'category': 'Gemüse', 'image': '🥒'},
    {'name': 'Paprika', 'category': 'Gemüse', 'image': '🫑'},
    {'name': 'Zucchini', 'category': 'Gemüse', 'image': '🥒'},
    {'name': 'Salat', 'category': 'Gemüse', 'image': '🥬'},
    {'name': 'Basilikum', 'category': 'Kräuter', 'image': '🌿'},
    {'name': 'Minze', 'category': 'Kräuter', 'image': '🌱'},
    {'name': 'Erdbeere', 'category': 'Obst', 'image': '🍓'},
    {'name': 'Heidelbeere', 'category': 'Obst', 'image': '🫐'},
    {'name': 'Monstera', 'category': 'Zimmerpflanze', 'image': '🌿'},
  ];

  // --- DIE TIMER LOGIK ---
  void _startWatering() {
    if (_isWatering || _isCooldown) return;

    setState(() {
      _isWatering = true;
      _remainingSeconds = _wateringDuration.toInt();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--; // Zählt jede Sekunde runter
        } else {
          if (_isWatering) {
            // Gießen fertig -> Wechsle in den Cooldown (z.B. 10 Sekunden)
            _isWatering = false;
            _isCooldown = true;
            _remainingSeconds = 10; 
          } else if (_isCooldown) {
            // Cooldown fertig -> Alles wieder freigeben
            _isCooldown = false;
            timer.cancel();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Timer stoppen, wenn man den Screen verlässt
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> potData = globalPots[widget.potIndex];
    
    List<Map<String, String>> filteredPlants = allPlants.where((p) {
      bool categoryMatch = _selectedCategory == 'Alle' || p['category'] == _selectedCategory;
      bool searchMatch = p['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return categoryMatch && searchMatch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF12171E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.grid_view), onPressed: () => Navigator.pop(context)),
        title: const Text('Topf Details', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.tune), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(potData),
                const SizedBox(height: 20),
                _buildMetricsGrid(potData),
                const SizedBox(height: 20),
                
                // HIER IST DIE NEUE COOLDOWN-KARTE
                _buildQuickAction(),
                
                const SizedBox(height: 20),
                _buildExpandableLibrary(filteredPlants, potData),
                const SizedBox(height: 20),
                _buildChartSection(),
                const SizedBox(height: 30),
                _buildBottomSettings(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- DIE NEUE, KOMPAKTE QUICK ACTION MIT COOLDOWN ---
  Widget _buildQuickAction() {
    // Dynamischer Text, je nachdem in welcher Phase wir sind
    String titleText = 'Sofort gießen (${_wateringDuration.toInt()}s)';
    if (_isWatering) titleText = 'Pumpe läuft...';
    if (_isCooldown) titleText = 'Sickerpause...';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C232D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText, 
                      style: TextStyle(
                        color: _isWatering ? const Color(0xFF00B26B) : (_isCooldown ? Colors.orange : Colors.white), 
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      )
                    ),
                    if (_isWatering || _isCooldown)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Bitte warten: $_remainingSeconds Sekunden', 
                          style: const TextStyle(color: Colors.grey, fontSize: 13)
                        ),
                      ),
                  ],
                ),
              ),
              ElevatedButton(
                // Button ist deaktiviert (null), wenn gegossen wird oder Cooldown aktiv ist
                onPressed: (_isWatering || _isCooldown) ? null : _startWatering,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_isWatering || _isCooldown) ? Colors.grey.withOpacity(0.3) : const Color(0xFF00B26B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(
                  (_isWatering || _isCooldown) ? '${_remainingSeconds}s' : 'Gießen',
                  style: TextStyle(
                    color: (_isWatering || _isCooldown) ? Colors.grey : Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            ],
          ),
          
          // Der Slider wird NUR angezeigt, wenn die Pumpe NICHT läuft
          if (!_isWatering && !_isCooldown) ...[
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF00B26B),
                inactiveTrackColor: Colors.grey.withOpacity(0.2),
                thumbColor: const Color(0xFF00B26B),
                overlayColor: const Color(0xFF00B26B).withOpacity(0.1),
                trackHeight: 2.0, // Macht den Slider viel schlanker und iOS-ähnlicher
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0), // Kleinerer Knopf
              ),
              child: Slider(
                value: _wateringDuration,
                min: 5,
                max: 120,
                divisions: 23,
                onChanged: (double newValue) {
                  setState(() {
                    _wateringDuration = newValue;
                  });
                },
              ),
            ),
          ]
        ],
      ),
    );
  }

  // --- DER REST BLEIBT GLEICH ---
  Widget _buildHeader(Map<String, dynamic> potData) {
    return Row(children: [const Icon(Icons.water_drop, color: Color(0xFF00B26B), size: 40), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(potData['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)), Text('${potData['location']} - Online', style: const TextStyle(color: Colors.grey, fontSize: 12))])]);
  }

  Widget _buildMetricsGrid(Map<String, dynamic> potData) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: [
        MetricCard(title: 'FEUCHTE', value: potData['moisture'], icon: Icons.opacity, color: const Color(0xFF00B26B)),
        MetricCard(title: 'TEMP', value: potData['temp'], icon: Icons.thermostat, color: Colors.orange),
        const MetricCard(title: 'TANK', value: '78%', icon: Icons.waves, color: Colors.cyan),
        const MetricCard(title: 'LUFT', value: '55%', icon: Icons.air, color: Colors.lightBlue),
        const MetricCard(title: 'PUMPE', value: 'Aus', icon: Icons.settings_input_component, color: Colors.purple),
        const MetricCard(title: 'AKKU', value: '92%', icon: Icons.battery_charging_full, color: Colors.green),
      ],
    );
  }

  Widget _buildExpandableLibrary(List<Map<String, String>> filteredPlants, Map<String, dynamic> potData) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.local_florist, color: Color(0xFF00B26B)),
            title: const Text('Pflanzenprofil wählen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('82 Pflanzen - Automatische Empfehlungen', style: TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: Icon(_isLibraryExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
            onTap: () => setState(() => _isLibraryExpanded = !_isLibraryExpanded),
          ),
          if (_isLibraryExpanded) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(children: [
              Container(height: 45, decoration: BoxDecoration(color: const Color(0xFF12171E), borderRadius: BorderRadius.circular(12)), child: TextField(style: const TextStyle(color: Colors.white), onChanged: (val) => setState(() => _searchQuery = val), decoration: const InputDecoration(hintText: 'Pflanze suchen...', hintStyle: TextStyle(color: Colors.grey), prefixIcon: Icon(Icons.search, color: Colors.grey), border: InputBorder.none))),
              const SizedBox(height: 12),
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ['Alle', 'Gemüse', 'Obst', 'Kräuter', 'Zimmerpflanze'].map((cat) { bool isSel = _selectedCategory == cat; return Padding(padding: const EdgeInsets.only(right: 8.0), child: ChoiceChip(label: Text(cat), selected: isSel, onSelected: (selected) => setState(() => _selectedCategory = cat), backgroundColor: const Color(0xFF12171E), selectedColor: const Color(0xFF00B26B).withOpacity(0.2), labelStyle: TextStyle(color: isSel ? const Color(0xFF00B26B) : Colors.grey), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSel ? const Color(0xFF00B26B) : Colors.transparent)), showCheckmark: false)); }).toList())),
              const SizedBox(height: 16),
              GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 120, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.0), itemCount: filteredPlants.length, itemBuilder: (context, index) { final p = filteredPlants[index]; return GestureDetector(onTap: () { setState(() { potData['name'] = p['name']; _isLibraryExpanded = false; }); }, child: Container(decoration: BoxDecoration(color: const Color(0xFF2A3441).withOpacity(0.3), borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(p['image']!, style: const TextStyle(fontSize: 32)), const SizedBox(height: 8), Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: Text(p['name']!, style: const TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis))]))); },),
              const SizedBox(height: 16),
            ]),
          )
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildTimeframeTab(0, '24h'),
            _buildTimeframeTab(1, '7 Tage'),
            _buildTimeframeTab(2, '30 Tage'),
          ]),
          const SizedBox(height: 20),
          SizedBox(height: 150, child: LineChart(_getChartData())),
        ],
      ),
    );
  }

  Widget _buildTimeframeTab(int index, String title) {
    bool isSel = _selectedTimeframe == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTimeframe = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSel ? const Color(0xFF2A3441) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Text(title, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 12)),
      ),
    );
  }

  LineChartData _getChartData() {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [LineChartBarData(spots: const [FlSpot(0, 3), FlSpot(2, 5), FlSpot(4, 4), FlSpot(6, 6), FlSpot(8, 5)], isCurved: true, color: const Color(0xFF00B26B), barWidth: 3, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: const Color(0xFF00B26B).withOpacity(0.1)))],
    );
  }

  Widget _buildBottomSettings() {
    return Column(children: [
      SwitchListTile(title: const Text('Boden trocken', style: TextStyle(color: Colors.white)), value: notifySoilDry, activeColor: const Color(0xFF00B26B), onChanged: (v) => setState(() => notifySoilDry = v)),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B26B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () {}, child: const Text('Einstellungen speichern', style: TextStyle(color: Colors.white)))),
      TextButton(onPressed: () {}, child: const Text('Topf löschen', style: TextStyle(color: Colors.redAccent))),
    ]);
  }
}