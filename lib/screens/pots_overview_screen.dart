import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dashboard_screen.dart';
import 'support_screen.dart';
import 'login_screen.dart';
import 'info_screen.dart';
import 'legal_screen.dart';
import 'add_pot_screen.dart';
import 'premium_screen.dart';
import 'settings_screen.dart';

class PotsOverviewScreen extends StatefulWidget {
  const PotsOverviewScreen({super.key});

  @override
  State<PotsOverviewScreen> createState() => _PotsOverviewScreenState();
}

class _PotsOverviewScreenState extends State<PotsOverviewScreen> {
  int _currentIndex = 0;
  bool _isEditMode = false;
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

  int get _potLimit => _userPlan == 'pro' ? 999 : _userPlan == 'plus' ? 5 : 1;

  Future<void> _tryAddPot(BuildContext ctx) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('pots')
        .where('userId', isEqualTo: uid)
        .count()
        .get();
    final count = snap.count ?? 0;
    if (!ctx.mounted) return;
    if (count >= _potLimit) {
      final needed = _userPlan == 'free' ? 'Plus' : 'Pro';
      final size = MediaQuery.of(ctx).size;
      showDialog(
        context: ctx,
        builder: (dialogCtx) => Dialog(
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
                        'Topf-Limit erreicht',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mit deinem aktuellen Plan kannst du nicht mehr Töpfe hinzufügen. Upgrade auf $needed.',
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
                            Navigator.pop(dialogCtx);
                            setState(() => _currentIndex = 1);
                          },
                          child: Text(
                            '$needed freischalten',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx),
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
      return;
    }
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => const AddPotScreen()));
  }
  
  // Test-Liste für Benachrichtigungen. 
  // Leer = Kein roter Punkt. 
  // Füge z.B. 'Update verfügbar' ein, um den Punkt zu sehen!
  final List<String> _notifications = []; 

  // --- DAS BENACHRICHTIGUNGS-MENÜ ---
  void _showNotificationMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent, // Macht den Hintergrund nicht dunkel
      builder: (context) {
        return Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 60.0, right: 16.0), // Abstand von oben und rechts
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF151A22), // Dunkler Hintergrund
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha:0.05)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha:0.5), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header des Menüs
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('notifications_title'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close, color: Colors.grey, size: 16),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.grey, height: 1, thickness: 0.2),
                    
                    // Inhalt des Menüs
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                      child: _notifications.isEmpty
                          ? Text('no_new_notifications'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 13))
                          : Column(
                              children: _notifications.map((note) => 
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text('• $note', style: const TextStyle(color: Colors.white, fontSize: 13)),
                                )
                              ).toList(),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    String appBarTitle = 'my_pots'.tr();
    if (_currentIndex == 1) appBarTitle = 'premium_tab'.tr();
    if (_currentIndex == 2) appBarTitle = 'settings_tab'.tr();

    // --- TÖPFE INHALT (Index 0) ---
    Widget potsContent = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('drag_to_sort'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: _isEditMode ? const Color(0xFF00B26B) : const Color(0xFF1C232D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () {
                      setState(() {
                        _isEditMode = !_isEditMode;
                      });
                    },
                    icon: Icon(_isEditMode ? Icons.check : Icons.tune, size: 16),
                    label: Text(_isEditMode ? 'done'.tr() : 'customize'.tr()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pots')
                    .where('userId', isEqualTo: currentUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF00B26B)));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Text('no_pots_yet'.tr(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    );
                  }

                  if (_isEditMode) {
                    return _buildEditList(docs);
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.85
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      return _buildPotCard(context, docs[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    // Aktiver Screen
    Widget activeScreen;
    if (_currentIndex == 0) {
      activeScreen = potsContent;
    } else if (_currentIndex == 1) {
      activeScreen = const PremiumScreen();
    } else {
      activeScreen = const SettingsScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF12171E),
      drawer: _buildDrawer(context), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(appBarTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        actions: [
          
          // --- HIER IST DIE NEUE GLOCKE MIT ROTEM PUNKT ---
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () => _showNotificationMenu(context), // Öffnet das Menü
              ),
              // Der Rote Punkt wird nur gezeichnet, wenn _notifications NICHT leer ist
              if (_notifications.isNotEmpty)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8, 
                    height: 8, 
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)
                  ),
                ),
            ],
          ),

          // Hinzufügen-Knopf nur bei den Töpfen anzeigen
          if (_currentIndex == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF00B26B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _tryAddPot(context),
                icon: const Icon(Icons.add, size: 18),
                label: Text('add'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
      
      body: activeScreen,
      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF12171E),
        selectedItemColor: const Color(0xFF00B26B),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_filled), label: 'pots_tab'.tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.workspace_premium), label: 'premium_tab'.tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: 'settings_tab'.tr()),
        ],
      ),
    );
  }

  Widget _buildPotCard(BuildContext context, DocumentSnapshot potDoc) {
    Map<String, dynamic> data = potDoc.data() as Map<String, dynamic>;

    return GestureDetector(
      onTap: () {
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
                  decoration: BoxDecoration(color: const Color(0xFF00B26B).withValues(alpha:0.1), borderRadius: BorderRadius.circular(12)),
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
            Text(data['name'] ?? 'unnamed'.tr(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            Text(data['location'] ?? 'no_location'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.opacity, color: Color(0xFF00B26B), size: 14),
                Text(data['moisture'] ?? '0%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.thermostat, color: Colors.orange, size: 14),
                Text(data['temp'] ?? '--°C', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditList(List<DocumentSnapshot> docs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var data = docs[index].data() as Map<String, dynamic>;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: const Color(0xFF1C232D), borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red, size: 28),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('pots').doc(docs[index].id).delete();
              },
            ),
            title: Text(data['name'] ?? 'unnamed'.tr(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Text(data['location'] ?? '', style: const TextStyle(color: Colors.grey)),
            trailing: const Icon(Icons.drag_handle, color: Colors.grey, size: 28),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF12171E),
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF00B26B), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.water_drop, color: Colors.white),
              ),
              title: const Text('HydroPilot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text('drawer_subtitle'.tr(), style: const TextStyle(color: Colors.grey)),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.white),
              title: Text('support'.tr(), style: const TextStyle(color: Colors.white)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: Text('about'.tr(), style: const TextStyle(color: Colors.white)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InfoScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.shield_outlined, color: Colors.white),
              title: Text('legal'.tr(), style: const TextStyle(color: Colors.white)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LegalScreen())),
            ),
            const Spacer(),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text('logout'.tr(), style: const TextStyle(color: Colors.red)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}