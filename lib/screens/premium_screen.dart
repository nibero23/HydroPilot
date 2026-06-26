import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // WICHTIG!

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

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
                    // 1. FREE PLAN
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
                      features: [
                        {'text': 'feat_1_pot'.tr(), 'active': true},
                        {'text': 'feat_24h_history'.tr(), 'active': true},
                        {'text': 'feat_basic_alerts'.tr(), 'active': true},
                        {'text': 'feat_data_export'.tr(), 'active': false},
                        {'text': 'feat_automations'.tr(), 'active': false},
                        {'text': 'feat_firmware_tools'.tr(), 'active': false},
                      ],
                    ),
                    
                    // 2. PLUS PLAN
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
                      features: [
                        {'text': 'feat_5_pots'.tr(), 'active': true},
                        {'text': 'feat_7d_history'.tr(), 'active': true},
                        {'text': 'feat_ext_alerts'.tr(), 'active': true},
                        {'text': 'feat_data_export'.tr(), 'active': true},
                        {'text': 'feat_automations'.tr(), 'active': false},
                        {'text': 'feat_firmware_tools'.tr(), 'active': false},
                      ],
                    ),
                    
                    // 3. PRO PLAN
                    _buildPlanCard(
                      title: 'plan_pro'.tr(),
                      subtitle: 'plan_pro_sub'.tr(),
                      price: 'plan_pro_price'.tr(),
                      period: 'plan_month_period'.tr(),
                      borderColor: Colors.white.withValues(alpha:0.1),
                      buttonText: 'btn_choose_pro'.tr(),
                      buttonBgColor: Colors.white,
                      buttonTextColor: const Color(0xFF12171E),
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
              
              // Die FittedBox verhindert die gelb-schwarzen Warnstreifen für immer!
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
                  onPressed: () {},
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
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
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
            color: isActive ? const Color(0xFF00B26B) : Colors.grey.withValues(alpha:0.5),
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.withValues(alpha:0.4),
              fontSize: 14,
              decoration: isActive ? TextDecoration.none : TextDecoration.lineThrough,
              decorationColor: Colors.grey.withValues(alpha:0.4),
            ),
          ),
        ],
      ),
    );
  }
}