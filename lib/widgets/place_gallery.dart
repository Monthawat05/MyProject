import '../theme/app_theme.dart';
import '../widgets/trip_day_colors.dart';
import 'package:flutter/material.dart';
import '../services/image_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/trip_day_order.dart';

class PlaceGallery extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>> dailyRoute;
  final ValueChanged<String>? onDayTap;

  const PlaceGallery({super.key, required this.dailyRoute, this.onDayTap});

  @override
  State<PlaceGallery> createState() => _PlaceGalleryState();
}

class _PlaceGalleryState extends State<PlaceGallery> {
  Map<String, String> _images = {};
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    final allPlaces = widget.dailyRoute.values
        .expand((points) => points)
        .map((p) => p['name'] as String)
        .toSet()
        .toList();

    try {
      final images = await ImageService.getPlaceImages(allPlaces);
      if (mounted) setState(() => _images = images);
    } on ImageLookupException catch (e) {
      if (mounted) setState(() => _loadError = e.message);
    } catch (e) {
      if (mounted) {
        setState(
          () => _loadError =
              'โหลดรูปไม่สำเร็จ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _colorForDay(int index) => tripDayColor(index);

  String _shortName(String name) {
    final parts = name.split(',');
    return parts.first.trim();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dailyRoute.isEmpty) return const SizedBox.shrink();

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2196F3),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_loadError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFF90A4AE),
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF546E7A)),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _loadImages,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'ลองโหลดรูปอีกครั้ง',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2196F3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final dayEntries = sortTripDays(widget.dailyRoute).entries.toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: dayEntries.asMap().entries.map((entry) {
        final dayIndex = entry.key;
        final dayLabel = entry.value.key;
        final places = entry.value.value;
        final color = _colorForDay(dayColorIndex(dayLabel, dayIndex));

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  TextButton(
                    onPressed: widget.onDayTap == null
                        ? null
                        : () => widget.onDayTap!(dayLabel),
                    child: Text(
                      dayLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (places.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'AI ไม่ได้ส่งรายชื่อสถานที่สำหรับวันนี้ ดูแผนรายวันด้านล่าง',
                  ),
                ),
              if (places.isNotEmpty)
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: places.length,
                    itemBuilder: (context, i) {
                      final placeName = places[i]['name'] as String;
                      final imageUrl = _images[placeName];

                      return Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            imageUrl != null
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (
                                          context,
                                          error,
                                          stackTrace,
                                        ) => Container(
                                          color: AppTheme.surface,
                                          child: const Icon(
                                            Icons.image_not_supported_outlined,
                                            color: Color(0xFF90CAF9),
                                          ),
                                        ),
                                  )
                                : Container(
                                    color: AppTheme.surface,
                                    child: const Center(
                                      child: Text(
                                        'ไม่พบรูปสถานที่นี้',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.muted,
                                        ),
                                      ),
                                    ),
                                  ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: IconButton.filled(
                                tooltip: 'เปิดเส้นทางไป $placeName',
                                icon: const Icon(Icons.directions, size: 20),
                                onPressed: () async {
                                  final place = places[i];
                                  final destination =
                                      place['lat'] is num && place['lon'] is num
                                      ? '${place['lat']},${place['lon']}'
                                      : placeName;
                                  final url = Uri.https(
                                    'www.google.com',
                                    '/maps/dir/',
                                    {'api': '1', 'destination': destination},
                                  );
                                  try {
                                    if (await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    )) {
                                      return;
                                    }
                                  } catch (_) {}
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'เปิดแผนที่ไม่สำเร็จ กรุณาลองอีกครั้ง',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.75),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  _shortName(placeName),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
