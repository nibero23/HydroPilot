import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF12171E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('support_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            indicatorColor: const Color(0xFF00B26B),
            labelColor: const Color(0xFF00B26B),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: const Icon(Icons.help_outline), text: 'tab_faq'.tr()),
              Tab(icon: const Icon(Icons.smart_toy_outlined), text: 'tab_ai_chat'.tr()),
              Tab(icon: const Icon(Icons.email_outlined), text: 'tab_email'.tr()),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: TabBarView(
              children: [
                // 1. FAQ TAB
                ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  children: [
                    _buildFaqItem('faq_q1'.tr(), 'faq_a1'.tr()),
                    _buildFaqItem('faq_q2'.tr(), 'faq_a2'.tr()),
                    _buildFaqItem('faq_q3'.tr(), 'faq_a3'.tr()),
                  ],
                ),
                
                // 2. KI-CHAT TAB
                Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C232D),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text('ai_greeting'.tr(), style: const TextStyle(color: Colors.white, height: 1.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'ai_input_hint'.tr(),
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF151A22),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: const Color(0xFF00B26B),
                              child: IconButton(
                                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // 3. E-MAIL TAB
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('email_hint'.tr(), style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      
                      Row(
                        children: [
                          Expanded(child: _buildTextField('email_name'.tr(), 'email_name_hint'.tr())),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('email_address'.tr(), 'email_address_hint'.tr())),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildTextField('email_subject'.tr(), 'email_subject_hint'.tr()),
                      const SizedBox(height: 24),
                      _buildTextField('email_message'.tr(), 'email_message_hint'.tr(), maxLines: 5),
                      const SizedBox(height: 32),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B26B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.send, color: Colors.white),
                          label: Text('email_send'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
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

  Widget _buildFaqItem(String question, String answer) {
    return Theme(
      data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        title: Text(question, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(answer, style: const TextStyle(color: Colors.grey, height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF1C232D),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}