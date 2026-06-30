import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'premium_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String potId;
  const DashboardScreen({super.key, required this.potId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedChartMetric = 'chart_moisture';
  int _chartDays = 1;
  String _userPlan = 'free';

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted) setState(() => _userPlan = (doc.data()?['plan'] as String?) ?? 'free');
  }

  int get _planLevel => _userPlan == 'pro' ? 2 : _userPlan == 'plus' ? 1 : 0;

  bool _canUseChartDays(int days) {
    if (days == 1) return true;
    if (days == 7) return _planLevel >= 1;
    return _planLevel >= 2;
  }

  void _showUpgradeHint(String requiredPlan) {
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1C232D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SizedBox(
          width: size.width * 0.85,
          height: size.height * 0.40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B26B).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_outline, color: Color(0xFF00B26B), size: 30),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Feature gesperrt',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Für diese Funktion benötigst du HydroPilot $requiredPlan.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B26B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
                        },
                        child: Text(
                          '$requiredPlan freischalten',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Vielleicht später', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Map<String, dynamic> _potData = {};
  bool _isPumping = false;

  Future<void> _activatePump() async {
    if (_isPumping) return;
    setState(() => _isPumping = true);
    try {
      await FirebaseFirestore.instance.collection('pots').doc(widget.potId).update({
        'pumpCommand': true,
        'pumpDuration': 30,
        'pumpState': true,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.waves, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Pumpe für 30 Sekunden aktiviert'),
            ],
          ),
          backgroundColor: const Color(0xFF00B26B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
      await Future.delayed(const Duration(seconds: 30));
      if (!mounted) return;
      await FirebaseFirestore.instance.collection('pots').doc(widget.potId).update({
        'pumpCommand': false,
        'pumpState': false,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Fehler: Pumpe konnte nicht aktiviert werden'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPumping = false);
    }
  }

  void _showNotificationsSheet() {
    final alerts = _buildAlerts();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C232D),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Benachrichtigungen', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            if (alerts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Alles in Ordnung – keine Warnungen.', style: TextStyle(color: Colors.grey))),
              )
            else
              ...alerts.map((a) => _buildAlertTile(a.$1, a.$2, a.$3)),
          ],
        ),
      ),
    );
  }

  List<(IconData, Color, String)> _buildAlerts() {
    final alerts = <(IconData, Color, String)>[];
    double? parseNum(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(RegExp(r'[^0-9.\-]'), ''));
      return null;
    }
    final moisture = parseNum(_potData['moisture']);
    final battery = parseNum(_potData['battery']);
    final tank = parseNum(_potData['tank']);
    if (moisture != null && moisture < 30) alerts.add((Icons.opacity, Colors.orange, 'Bodenfeuchte unter 30% – Gießen empfohlen'));
    if (battery != null && battery < 20) alerts.add((Icons.battery_alert, Colors.red, 'Akku fast leer (${battery.toInt()}%)'));
    if (tank != null && tank < 10) alerts.add((Icons.view_in_ar, Colors.red, 'Wassertank fast leer (${tank.toInt()}%)'));
    return alerts;
  }

  Widget _buildAlertTile(IconData icon, Color color, String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.25))),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: TextStyle(color: color, fontSize: 13))),
        ],
      ),
    );
  }

  void _showPotSettingsSheet() {
    final nameController = TextEditingController(text: _potData['name'] as String? ?? '');
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C232D),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Topf-Einstellungen', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(sheetCtx)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('NAME', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF12171E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                hintText: 'Topfname',
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B26B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  await FirebaseFirestore.instance.collection('pots').doc(widget.potId).update({'name': name});
                  if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                },
                child: const Text('Speichern', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red, width: 1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                label: const Text('Topf löschen', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onPressed: () => _confirmDeletePot(sheetCtx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePot(BuildContext sheetCtx) {
    showDialog(
      context: sheetCtx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1C232D),
        title: const Text('Topf löschen?', style: TextStyle(color: Colors.white)),
        content: const Text('Alle Daten dieses Topfes werden unwiderruflich gelöscht.', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Abbrechen', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('pots').doc(widget.potId).delete();
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              if (sheetCtx.mounted) Navigator.pop(sheetCtx);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Löschen', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: _showNotificationsSheet),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('pots').doc(widget.potId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00B26B)));
          }
          _potData = snapshot.data!.data() as Map<String, dynamic>;
          var potData = _potData;

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
                        _buildMetricCard('moisture_label'.tr(), '${potData['moisture'] ?? '0%'}', 'Min: 30%', Icons.opacity, const Color(0xFF00B26B)),
                        _buildMetricCard('temp_label'.tr(), '${potData['temp'] ?? '--°C'}', null, Icons.thermostat, Colors.orange),
                        _buildMetricCard('humidity_label'.tr(), '${potData['humidity'] ?? '0%'}', null, Icons.air, Colors.blue),
                        _buildMetricCard('tank_label'.tr(), '${potData['tank'] ?? '0%'}', null, Icons.view_in_ar, Colors.cyan),
                        _buildMetricCard('battery_label'.tr(), '${potData['battery'] ?? '0%'}', '6.86V', Icons.battery_charging_full, Colors.purple),
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
        IconButton(icon: const Icon(Icons.tune, color: Colors.grey), onPressed: _showPotSettingsSheet),
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
              backgroundColor: _isPumping ? Colors.grey.shade700 : const Color(0xFF00B26B),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _isPumping ? null : _activatePump,
            icon: _isPumping
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.waves, color: Colors.white, size: 18),
            label: Text('water_now'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, height: 1.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    final metricKey = selectedChartMetric == 'chart_moisture'
        ? 'moisture'
        : selectedChartMetric == 'chart_temp'
            ? 'temp'
            : 'humidity';
    final color = selectedChartMetric == 'chart_moisture'
        ? const Color(0xFF00B26B)
        : selectedChartMetric == 'chart_temp'
            ? Colors.orange
            : Colors.blue;

    final cutoff = Timestamp.fromDate(
      DateTime.now().subtract(Duration(days: _chartDays)),
    );
    final queryLimit = _chartDays == 1 ? 24 : _chartDays == 7 ? 56 : 60;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
              ),
              const SizedBox(width: 8),
              Row(
                children: [1, 7, 30].map((d) {
                  final selected = _chartDays == d;
                  final unlocked = _canUseChartDays(d);
                  return GestureDetector(
                    onTap: () {
                      if (!unlocked) {
                        _showUpgradeHint(d == 7 ? 'Plus' : 'Pro');
                      } else {
                        setState(() => _chartDays = d);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: selected ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? Colors.white.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!unlocked)
                            Padding(
                              padding: const EdgeInsets.only(right: 3),
                              child: Icon(Icons.lock_outline, size: 9, color: Colors.grey.withValues(alpha: 0.6)),
                            ),
                          Text(
                            '${d}T',
                            style: TextStyle(
                              color: unlocked ? (selected ? Colors.white : Colors.grey) : Colors.grey.withValues(alpha: 0.4),
                              fontSize: 11,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pots')
                .doc(widget.potId)
                .collection('history')
                .orderBy('timestamp', descending: true)
                .where('timestamp', isGreaterThan: cutoff)
                .limit(queryLimit)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox(
                  height: 150,
                  child: Center(
                    child: Text('Noch keine Verlaufsdaten vorhanden', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ),
                );
              }

              final docs = snapshot.data!.docs.reversed.toList();
              final spots = <FlSpot>[];
              for (int i = 0; i < docs.length; i++) {
                final data = docs[i].data() as Map<String, dynamic>;
                final raw = data[metricKey];
                double? value;
                if (raw is num) {
                  value = raw.toDouble();
                } else if (raw is String) {
                  value = double.tryParse(raw.replaceAll(RegExp(r'[^0-9.\-]'), ''));
                }
                if (value != null) spots.add(FlSpot(i.toDouble(), value));
              }

              if (spots.isEmpty) {
                return const SizedBox(
                  height: 150,
                  child: Center(child: Text('Keine Daten für diesen Messwert', style: TextStyle(color: Colors.grey, fontSize: 13))),
                );
              }

              final minY = (spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 5).clamp(0, double.infinity).toDouble();
              final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 5;

              return SizedBox(
                height: 150,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (_) => FlLine(color: Colors.white.withValues(alpha: 0.05), strokeWidth: 1),
                      drawVerticalLine: false,
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, _) => Text(
                            value.toInt().toString(),
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minY: minY,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: color,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: color.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, String value, IconData icon, Color color) {
    final isSelected = selectedChartMetric == value;
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
              onPressed: _planLevel >= 2
                  ? _showAddScheduleSheet
                  : () => _showUpgradeHint('Pro'),
              icon: Icon(
                _planLevel >= 2 ? Icons.add : Icons.lock_outline,
                size: 18,
                color: _planLevel >= 2 ? const Color(0xFF00B26B) : Colors.grey,
              ),
              label: Text(
                'new_btn'.tr(),
                style: TextStyle(
                  color: _planLevel >= 2 ? const Color(0xFF00B26B) : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pots')
              .doc(widget.potId)
              .collection('schedules')
              .orderBy('time')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('no_schedules'.tr(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              );
            }
            return Column(
              children: snapshot.data!.docs.map((doc) {
                return _buildScheduleCard(doc.id, doc.data() as Map<String, dynamic>);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildScheduleCard(String docId, Map<String, dynamic> data) {
    const dayLabels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    final time = data['time'] as String? ?? '--:--';
    final days = List<int>.from(data['days'] ?? []);
    final duration = data['duration'] as int? ?? 30;
    final active = data['active'] as bool? ?? true;
    final durationLabel = duration >= 60 ? '${duration ~/ 60} min' : '${duration}s';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF12171E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '$durationLabel · ${days.map((d) => dayLabels[d]).join(', ')}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: active,
            activeThumbColor: const Color(0xFF00B26B),
            onChanged: (val) {
              FirebaseFirestore.instance
                  .collection('pots')
                  .doc(widget.potId)
                  .collection('schedules')
                  .doc(docId)
                  .update({'active': val});
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('pots')
                  .doc(widget.potId)
                  .collection('schedules')
                  .doc(docId)
                  .delete();
            },
          ),
        ],
      ),
    );
  }

  void _showAddScheduleSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C232D),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddScheduleSheet(potId: widget.potId),
    );
  }
}

class _AddScheduleSheet extends StatefulWidget {
  final String potId;
  const _AddScheduleSheet({required this.potId});

  @override
  State<_AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<_AddScheduleSheet> {
  TimeOfDay _time = TimeOfDay.now();
  final Set<int> _days = {0, 1, 2, 3, 4};
  int _duration = 30;
  bool _saving = false;

  static const _dayLabels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Neuer Zeitplan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text('UHRZEIT', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _time,
                builder: (context, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(primary: Color(0xFF00B26B)),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => _time = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: const Color(0xFF12171E), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Color(0xFF00B26B), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _time.format(context),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text('WOCHENTAGE', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final selected = _days.contains(i);
              return GestureDetector(
                onTap: () => setState(() => selected ? _days.remove(i) : _days.add(i)),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF00B26B) : const Color(0xFF12171E),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _dayLabels[i],
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          const Text('DAUER', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [10, 30, 60, 120, 300].map((sec) {
              final selected = _duration == sec;
              final label = sec >= 60 ? '${sec ~/ 60}min' : '${sec}s';
              return GestureDetector(
                onTap: () => setState(() => _duration = sec),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF00B26B) : const Color(0xFF12171E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B26B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Zeitplan speichern', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_days.isEmpty) return;
    setState(() => _saving = true);
    final timeStr = '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
    await FirebaseFirestore.instance
        .collection('pots')
        .doc(widget.potId)
        .collection('schedules')
        .add({
      'time': timeStr,
      'days': (_days.toList()..sort()),
      'duration': _duration,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (mounted) Navigator.pop(context);
  }
}
