import 'package:flutter/material.dart';

class PlanCard extends StatelessWidget {
  final bool isActive;
  final String badgeText;
  final String title;
  final String subtitle;
  final String price;
  final String priceSuffix;
  final List<Map<String, dynamic>> features;
  final String buttonText;
  final Color accentColor;

  const PlanCard({
    super.key,
    required this.isActive,
    required this.badgeText,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.priceSuffix,
    required this.features,
    required this.buttonText,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C232D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? accentColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                    child: Text(priceSuffix, style: const TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...features.map((feature) {
                final bool included = feature['included'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Icon(included ? Icons.check : Icons.remove, color: included ? accentColor : Colors.grey.withValues(alpha: 0.5), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        feature['title'],
                        style: TextStyle(
                          color: included ? Colors.white : Colors.grey.withValues(alpha: 0.5),
                          decoration: included ? TextDecoration.none : TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? Colors.white.withValues(alpha: 0.1) : accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {},
                  child: Text(buttonText, style: TextStyle(color: isActive ? Colors.grey : Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        if (isActive)
          Positioned(
            top: -12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badgeText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
      ],
    );
  }
}