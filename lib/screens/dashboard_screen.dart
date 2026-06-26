import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart'; // WICHTIG!

class DashboardScreen extends StatefulWidget {
  final String potId;
  const DashboardScreen({super.key, required this.potId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Hier nutzen wir die Übersetzungs-Keys für die Logik
  String selectedChartMetric = 'chart_moisture'; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12171E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('pot_details'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('pots').doc(widget.potId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00B26B)));
          }
          var potData = snapshot.data!.data() as Map<String, dynamic>;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildHeader(potData),
                    const SizedBox(height: 24),
                    
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                      children: [
                        _buildMetricCard('moisture_label'.tr(), '${potData['moisture'] ?? '0'}%', 'Min: 30%', Icons.opacity, const Color(0xFF00B26B)),
                        _buildMetricCard('temp_label'.tr(), '${potData['temp'] ?? '0'}°C', null, Icons.thermostat, Colors.orange),
                        _buildMetricCard('humidity_label'.tr(), '${potData['humidity'] ?? '0'}%', null, Icons.air, Colors.blue),
                        _buildMetricCard('tank_label'.tr(), '${potData['tank'] ?? '0'}%', null, Icons.view_in_ar, Colors.cyan),
                        _buildMetricCard('battery_label'.tr(), '${potData['battery'] ?? '0'}%', '6.86V', Icons.battery_charging_full, Colors.purple),
                        _buildMetricCard('pump_label'.tr(), potData['pumpState'] == true ? 'pump_on'.tr() : 'pump_off'.tr(), null, Icons.waves, Colors.indigo),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildActionCard(),
                    const SizedBox(height: 24),
                    _buildChartSection(),
                    const SizedBox(height: 24),
                    _buildSchedulesSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> data) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: Color(0xFF1C232D), shape: BoxShape.circle),
          child: const Icon(Icons.water_drop, color: Color(0xFF00B26B), size: 28),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['name'] ?? 'unnamed'.tr(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text('last_seen'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const Spacer(),
        IconButton(icon: const Icon(Icons.tune, color: Colors.grey), onPressed: () {}),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String? subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          if (subtitle != null) Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(child: Text('pump_desc'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 14))),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B26B),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {},
            icon: const Icon(Icons.waves, color: Colors.white, size: 18),
            label: Text('water_now'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, height: 1.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildToggleButton('chart_moisture'.tr(), 'chart_moisture', Icons.opacity, const Color(0xFF00B26B)),
                const SizedBox(width: 8),
                _buildToggleButton('chart_temp'.tr(), 'chart_temp', Icons.thermostat, Colors.orange),
                const SizedBox(width: 8),
                _buildToggleButton('chart_humidity'.tr(), 'chart_humidity', Icons.air, Colors.blue),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 150, width: double.infinity, child: Center(child: Text("Graph...", style: TextStyle(color: Colors.grey)))),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, String value, IconData icon, Color color) {
    bool isSelected = selectedChartMetric == value;
    return GestureDetector(
      onTap: () => setState(() => selectedChartMetric = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('schedules'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18, color: Color(0xFF00B26B)),
              label: Text('new_btn'.tr(), style: const TextStyle(color: Color(0xFF00B26B), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(child: Text('no_schedules'.tr(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13))),
      ],
    );
  }
}