import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF12171E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('legal_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            indicatorColor: const Color(0xFF00B26B),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'tab_imprint'.tr()),
              Tab(text: 'tab_privacy'.tr()),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: TabBarView(
              children: [
                // 1. IMPRESSUM
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('tab_imprint'.tr(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text('imprint_company'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
                      const SizedBox(height: 24),
                      Text('imprint_contact'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
                      const SizedBox(height: 24),
                      Text('imprint_ceo'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 24),
                      Text('imprint_registry'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 24),
                      Text('imprint_vat'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),
                
                // 2. DATENSCHUTZ
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('tab_privacy'.tr() + 'erklärung', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text('privacy_intro'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
                      const SizedBox(height: 24),
                      
                      Text('privacy_data_title'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('privacy_data_text'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
                      const SizedBox(height: 24),
                      
                      Text('privacy_usage_title'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('privacy_usage_text'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
                      const SizedBox(height: 24),
                      
                      Text('privacy_rights_title'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('privacy_rights_text'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}