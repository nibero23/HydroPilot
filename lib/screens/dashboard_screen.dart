import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/metric_card.dart';
import 'settings_screen.dart';
import '../database.dart'; // Datenbank importieren

class DashboardScreen extends StatefulWidget {
  final int potIndex; // Erhält nur noch die Nummer (0 für Basilikum, 1 für haha, etc.)
  const DashboardScreen({super.key, required this.potIndex});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedChart = 0; 

  void _showAddScheduleModal() {
    TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
    List<String> dayNames = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    List<bool> selectedDays = [true, true, true, true, true, false, false];
    double pumpDuration = 30.0;
    TextEditingController nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, top: 24, left: 24, right: 24),
              decoration: const BoxDecoration(color: Color(0xFF12171E), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bewässerungs-Zeitplan', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    TextField(controller: nameController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Name (optional)', hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)), filled: true, fillColor: const Color(0xFF1C232D), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.grey),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () async {
                            TimeOfDay? time = await showTimePicker(context: context, initialTime: selectedTime, builder: (context, child) { return Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFF00B26B), surface: Color(0xFF1C232D))), child: child!); });
                            if (time != null) setModalState(() => selectedTime = time);
                          },
                          child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withValues(alpha: 0.3))), child: Text(selectedTime.format(context), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                        ),
                        const SizedBox(width: 12),
                        const Text('Uhrzeit', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Wochentage', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        bool isActive = selectedDays[index];
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedDays[index] = !selectedDays[index]),
                          child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isActive ? const Color(0xFF00B26B) : const Color(0xFF1C232D), borderRadius: BorderRadius.circular(8)), child: Text(dayNames[index], style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold))),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Pumpendauer', style: TextStyle(color: Colors.grey)), Text('${pumpDuration.toInt()}s', style: const TextStyle(color: Color(0xFF00B26B), fontWeight: FontWeight.bold))]),
                    Slider(value: pumpDuration, min: 5, max: 35, activeColor: const Color(0xFF00B26B), inactiveColor: Colors.grey.withValues(alpha: 0.3), onChanged: (val) => setModalState(() => pumpDuration = val)),
                    const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('5s', style: TextStyle(color: Colors.grey, fontSize: 12)), Text('Max: 35s (Sensor-Limit)', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 16),
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.05), border: Border.all(color: Colors.orange.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(12)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20), SizedBox(width: 8), Expanded(child: Text('Das Maximum basiert auf dem Topf-Sensor-Limit (35s) – so wird verhindert, dass die Pflanze überwässert wird.\nZiel-Feuchte: 30%', style: TextStyle(color: Colors.grey, fontSize: 12)))])),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B26B), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: () {
                              // HIER WIRD GESPEICHERT: Direkt in der globalen Datenbank!
                              setState(() {
                                globalPots[widget.potIndex]['schedules'].add({
                                  'name': nameController.text.isEmpty ? 'Zeitplan ${globalPots[widget.potIndex]['schedules'].length + 1}' : nameController.text,
                                  'time': selectedTime.format(context),
                                  'duration': pumpDuration.toInt(),
                                  'active': true,
                                });
                              });
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text('Speichern', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C232D), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.grey),
                            label: const Text('Abbrechen', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lade die aktuellen Daten aus der Datenbank anhand des Index
    Map<String, dynamic> potData = globalPots[widget.potIndex];
    List schedules = potData['schedules'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.grid_view), onPressed: () => Navigator.pop(context)),
        title: const Text('Topf Details', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.tune), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())))],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.water_drop, color: Color(0xFF00B26B), size: 40),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [Text(potData['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(width: 8), Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle))]),
                        Text('${potData['location']} - Zuletzt vor 2 Min.', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10,
                  children: [
                    MetricCard(title: 'FEUCHTE', value: potData['moisture'], icon: Icons.opacity, color: const Color(0xFF00B26B)),
                    MetricCard(title: 'TEMP', value: potData['temp'], icon: Icons.thermostat, color: Colors.orange),
                    const MetricCard(title: 'TANK', value: '78%', icon: Icons.waves, color: Colors.cyan),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [const Expanded(child: Text('Pumpe für 35s aktivieren', style: TextStyle(color: Colors.grey))), ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.play_arrow, color: Colors.white), label: const Text('Gießen', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B26B)))]),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [_buildChartTab(0, 'Bodenfeuchte', Icons.opacity, const Color(0xFF00B26B)), const SizedBox(width: 8), _buildChartTab(1, 'Temperatur', Icons.thermostat, Colors.orange)])),
                      const SizedBox(height: 20),
                      SizedBox(height: 200, child: LineChart(_getChartData())),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bewässerungs-Zeitpläne', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton.icon(onPressed: _showAddScheduleModal, icon: const Icon(Icons.add, color: Color(0xFF00B26B), size: 18), label: const Text('Neu', style: TextStyle(color: Color(0xFF00B26B))))
                  ],
                ),
                const SizedBox(height: 16),
                
                // Zeitpläne anzeigen
                schedules.isEmpty 
                  ? const Center(child: Text('Noch keine Zeitpläne. Tippe auf "Neu" um einen zu erstellen.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                  : Column(
                      children: schedules.map((schedule) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: Color(0xFF00B26B)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(schedule['time'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                    Text('${schedule['name']} • ${schedule['duration']}s Pumpendauer', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Switch(value: schedule['active'], activeThumbColor: const Color(0xFF00B26B), onChanged: (val) => setState(() => schedule['active'] = val))
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartTab(int index, String title, IconData icon, Color color) {
    bool isActive = _selectedChart == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedChart = index),
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent, border: Border.all(color: isActive ? color : Colors.grey.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(20)), child: Row(children: [Icon(icon, size: 16, color: isActive ? color : Colors.grey), const SizedBox(width: 6), Text(title, style: TextStyle(color: isActive ? color : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))])),
    );
  }

  LineChartData _getChartData() {
    return LineChartData(
      gridData: const FlGridData(show: false), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false),
      lineBarsData: [LineChartBarData(spots: const [FlSpot(0, 30), FlSpot(2, 45), FlSpot(4, 35), FlSpot(6, 60), FlSpot(8, 45)], isCurved: true, color: _selectedChart == 0 ? const Color(0xFF00B26B) : Colors.orange, barWidth: 3, dotData: const FlDotData(show: false))]
    );
  }
}