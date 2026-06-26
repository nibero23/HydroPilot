import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle; // NEU: Optionaler Untertitel für Schwellenwerte oder Voltzahl
  final IconData icon;
  final Color color;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C232D),
        borderRadius: BorderRadius.circular(20),
        // Ein ganz dezenter Rahmen für mehr Tiefe
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon in der Farbe der Metrik
          Icon(icon, color: color, size: 22),
          
          const SizedBox(height: 12),
          
          // Titel in Grau, All-Caps (wie im Design)
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          
          const Spacer(),
          
          // Der Hauptwert
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Falls Einheiten wie % oder °C separat gelistet werden sollen
            ],
          ),
          
          // Optionaler Untertitel (z.B. "Min: 30%")
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle!,
                style: TextStyle(
                  color: Colors.grey.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}