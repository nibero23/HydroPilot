import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12171E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('info_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.eco_outlined, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                const Text('HydroPilot', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Version 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 24),
                Text(
                  'info_desc'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 48),
                
                _buildInfoRow('platform'.tr(), 'ESP32 + React'), // React laut deinem Bild
                _buildInfoRow('protocol'.tr(), 'BLE + WiFi + MQTT'),
                _buildInfoRow('firmware'.tr(), 'v2.1.3'),
                _buildInfoRow('license'.tr(), 'MIT', noDivider: true),
                
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.grey)),
                      onPressed: () {},
                      icon: const Icon(Icons.language, size: 16),
                      label: Text('website'.tr()),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.grey)),
                      onPressed: () {},
                      icon: const Icon(Icons.code, size: 16),
                      label: Text('github'.tr()),
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

  Widget _buildInfoRow(String title, String value, {bool noDivider = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        if (!noDivider) const Divider(color: Colors.white12, height: 1),
      ],
    );
  }
}