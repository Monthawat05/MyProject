import '../theme/app_theme.dart';
import 'package:flutter/material.dart';

class TripTravelOptions extends StatelessWidget {
  final String origin;
  final String destination;

  const TripTravelOptions({
    super.key,
    required this.origin,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) => Card(
    color: AppTheme.surface,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            origin.isEmpty ? destination : '$origin → $destination',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'คำแนะนำที่พักและการเดินทางอยู่ในแผนด้านล่าง ราคากับเวลาเป็นเพียงประมาณการ กรุณาตรวจสอบก่อนจอง',
          ),
        ],
      ),
    ),
  );
}
