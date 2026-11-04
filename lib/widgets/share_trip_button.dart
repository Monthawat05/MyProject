import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/trip_dates.dart';

class ShareTripButton extends StatelessWidget {
  final String destination;
  final String origin;
  final String itinerary;
  final int days;
  final DateTime? startDate;
  const ShareTripButton({
    super.key,
    required this.destination,
    this.origin = '',
    required this.itinerary,
    required this.days,
    this.startDate,
  });

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'คัดลอกแผนเพื่อแชร์',
    icon: const Icon(Icons.copy_outlined),
    onPressed: () async {
      final text =
          'แผนทริป $destination ($days วัน)\n'
          '${origin.isEmpty ? '' : 'ต้นทาง: $origin\n'}'
          '${startDate == null ? '' : '${tripDateRange(startDate!, days)}\n'}'
          '\n$itinerary\n\nวางแผนด้วย TripAI';
      try {
        await Clipboard.setData(ClipboardData(text: text));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'คัดลอกแผนแล้ว นำไปวางใน LINE หรือแชตเพื่อแชร์ได้เลย',
            ),
          ),
        );
      } catch (_) {
        if (!context.mounted) return;
        showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('เลือกข้อความเพื่อคัดลอก'),
            content: SingleChildScrollView(child: SelectableText(text)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ปิด'),
              ),
            ],
          ),
        );
      }
    },
  );
}
