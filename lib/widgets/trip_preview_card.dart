import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../models/trip_dates.dart';
import '../services/image_service.dart';

class TripPreviewCard extends StatefulWidget {
  final TripModel trip;
  final VoidCallback onTap;
  final String? imageQuery;
  final String? subtitle;
  const TripPreviewCard({
    super.key,
    required this.trip,
    required this.onTap,
    this.imageQuery,
    this.subtitle,
  });
  @override
  State<TripPreviewCard> createState() => _TripPreviewCardState();
}

class _TripPreviewCardState extends State<TripPreviewCard> {
  late Future<String?> _image;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _image = widget.imageQuery != null
        ? ImageService.getPlaceImage(widget.imageQuery!)
        : ImageService.getDestinationImage(widget.trip.destination);
  }

  @override
  void didUpdateWidget(covariant TripPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trip.destination != widget.trip.destination ||
        oldWidget.imageQuery != widget.imageQuery) {
      _load();
    }
  }

  Widget _chip(IconData icon, String text, Color color, Color background) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x130E3A64),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(25),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 155,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF409ACE), Color(0xFF145678)],
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Icon(
                            Icons.landscape_outlined,
                            color: Color(0x55FFFFFF),
                            size: 100,
                          ),
                        ),
                      ),
                    ),
                    FutureBuilder<String?>(
                      future: _image,
                      builder: (_, snapshot) => snapshot.data == null
                          ? const SizedBox.shrink()
                          : Image.network(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, error, stack) =>
                                  const SizedBox.shrink(),
                            ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xBC09253C)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 17,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.destination,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.text,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.subtitle ??
                                (trip.origin.isEmpty
                                    ? 'แตะเพื่อดูแผนทริป'
                                    : 'เริ่มต้นจาก ${trip.origin}'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFE4F2FF),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(
                          Icons.calendar_today,
                          '${trip.days} วัน',
                          const Color(0xFF8ACFFF),
                          const Color(0xFF193951),
                        ),
                        _chip(
                          Icons.people,
                          '${trip.travelers} คน',
                          const Color(0xFF95DFBA),
                          const Color(0xFF193F39),
                        ),
                        if (trip.styles.isNotEmpty)
                          _chip(
                            Icons.local_florist,
                            trip.styles.first,
                            const Color(0xFFFFCD86),
                            const Color(0xFF463C2E),
                          ),
                      ],
                    ),
                    if (trip.startDate != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        tripDateRange(trip.startDate!, trip.days),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
