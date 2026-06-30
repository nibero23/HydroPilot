import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  void _showCurrentPlanInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Du nutzt bereits den Free Plan.'),
          ],
        ),
        backgroundColor: const Color(0xFF1C232D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSubscribeSheet(String planName, String price, String period, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C232D),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.star_rounded, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'HydroPilot $planName',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '$price$period',
              style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'premium_footer'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    final planKey = planName.toLowerCase();
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .set({'plan': planKey}, SetOptions(merge: true));
                  }
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 18),
                          const SizedBox(width: 10),
                          Text('$planName-Abo gestartet! 7 Tage gratis.'),
                        ],
                      ),
                      backgroundColor: color,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                child: const Text(
                  '7 Tage gratis testen',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Abbrechen', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF12171E),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'premium_desc'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 48),
                Wrap(
                  spacing: 24,
                  runSpacing: 48,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildPlanCard(
                      title: 'plan_free'.tr(),
                      subtitle: 'plan_free_sub'.tr(),
                      price: 'plan_free_price'.tr(),
                      period: 'plan_free_period'.tr(),
                      badgeText: 'badge_active'.tr(),
                      badgeColor: const Color(0xFF00B26B),
                      borderColor: const Color(0xFF00B26B),
                      buttonText: 'btn_current_plan'.tr(),
                      buttonBgColor: const Color(0xFF222831),
                      buttonTextColor: Colors.grey,
                      onPressed: _showCurrentPlanInfo,
                      features: [
                        {'text': 'feat_1_pot'.tr(), 'active': true},
                        {'text': 'feat_24h_history'.tr(), 'active': true},
                        {'text': 'feat_basic_alerts'.tr(), 'active': true},
                        {'text': 'feat_data_export'.tr(), 'active': false},
                        {'text': 'feat_automations'.tr(), 'active': false},
                        {'text': 'feat_firmware_tools'.tr(), 'active': false},
                      ],
                    ),
                    _buildPlanCard(
                      title: 'plan_plus'.tr(),
                      subtitle: 'plan_plus_sub'.tr(),
                      price: 'plan_plus_price'.tr(),
                      period: 'plan_month_period'.tr(),
                      badgeText: 'badge_popular'.tr(),
                      badgeColor: const Color(0xFF14B8A6),
                      borderColor: const Color(0xFF14B8A6),
                      buttonText: 'btn_choose_plus'.tr(),
                      buttonBgColor: const Color(0xFF14B8A6),
                      buttonTextColor: Colors.white,
                      onPressed: () => _showSubscribeSheet('Plus', '€4,99', '/pro Monat', const Color(0xFF14B8A6)),
                      features: [
                        {'text': 'feat_5_pots'.tr(), 'active': true},
                        {'text': 'feat_7d_history'.tr(), 'active': true},
                        {'text': 'feat_ext_alerts'.tr(), 'active': true},
                        {'text': 'feat_data_export'.tr(), 'active': true},
                        {'text': 'feat_automations'.tr(), 'active': false},
                        {'text': 'feat_firmware_tools'.tr(), 'active': false},
                      ],
                    ),
                    _buildPlanCard(
                      title: 'plan_pro'.tr(),
                      subtitle: 'plan_pro_sub'.tr(),
                      price: 'plan_pro_price'.tr(),
                      period: 'plan_month_period'.tr(),
                      borderColor: Colors.white.withValues(alpha: 0.1),
                      buttonText: 'btn_choose_pro'.tr(),
                      buttonBgColor: Colors.white,
                      buttonTextColor: const Color(0xFF12171E),
                      onPressed: () => _showSubscribeSheet('Pro', '€9,99', '/pro Monat', const Color(0xFF00B26B)),
                      features: [
                        {'text': 'feat_unlimited_pots'.tr(), 'active': true},
                        {'text': 'feat_30d_history'.tr(), 'active': true},
                        {'text': 'feat_all_alerts'.tr(), 'active': true},
                        {'text': 'feat_data_export'.tr(), 'active': true},
                        {'text': 'feat_auto_rules'.tr(), 'active': true},
                        {'text': 'feat_firmware_tools'.tr(), 'active': true},
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Text(
                  'premium_footer'.tr(),
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String subtitle,
    required String price,
    required String period,
    String? badgeText,
    Color? badgeColor,
    required Color borderColor,
    required String buttonText,
    required Color buttonBgColor,
    required Color buttonTextColor,
    required VoidCallback onPressed,
    required List<Map<String, dynamic>> features,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: 320,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          decoration: BoxDecoration(
            color: const Color(0xFF151A22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 24),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(price, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                    Text(period, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: features.map((f) => _buildFeatureRow(f['text'], f['active'])).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBgColor,
                    foregroundColor: buttonTextColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: onPressed,
                  child: Text(buttonText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        if (badgeText != null && badgeColor != null)
          Positioned(
            top: -16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
              child: Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureRow(String text, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check : Icons.remove,
            color: isActive ? const Color(0xFF00B26B) : Colors.grey.withValues(alpha: 0.5),
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.withValues(alpha: 0.4),
              fontSize: 14,
              decoration: isActive ? TextDecoration.none : TextDecoration.lineThrough,
              decorationColor: Colors.grey.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
