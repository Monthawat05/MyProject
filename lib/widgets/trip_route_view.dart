import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/trip_day_order.dart';
import '../theme/app_theme.dart';
import 'trip_day_colors.dart';
import 'place_gallery.dart';

class TripRouteView extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>> dailyRoute;
  const TripRouteView({super.key, required this.dailyRoute});
  @override
  State<TripRouteView> createState() => _TripRouteViewState();
}

class _TripRouteViewState extends State<TripRouteView> {
  final _controller = MapController();
  final _mapKey = GlobalKey();
  bool _ready = false;
  String? _selected;
  List<LatLng> _points(List<Map<String, dynamic>> places) => places
      .where(
        (p) =>
            p['lat'] is num &&
            p['lon'] is num &&
            (p['lat'] as num).isFinite &&
            (p['lon'] as num).isFinite &&
            (p['lat'] as num).abs() <= 90 &&
            (p['lon'] as num).abs() <= 180,
      )
      .map(
        (p) =>
            LatLng((p['lat'] as num).toDouble(), (p['lon'] as num).toDouble()),
      )
      .toList();

  void _focus(String day) {
    final points = _points(widget.dailyRoute[day] ?? []);
    if (points.isEmpty || !_ready) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ยังไม่พบพิกัดของวันนี้')));
      return;
    }
    setState(() => _selected = day);
    if (points.toSet().length == 1) {
      _controller.move(points.first, 14);
    } else {
      _controller.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(42),
          maxZoom: 15,
        ),
      );
    }
    final mapContext = _mapKey.currentContext;
    if (mapContext != null) {
      Scrollable.ensureVisible(
        mapContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = sortTripDays(widget.dailyRoute).entries.toList();
    if (days.isEmpty) return const SizedBox.shrink();
    final all = _points(days.expand((d) => d.value).toList());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (all.isNotEmpty)
          SizedBox(
            key: _mapKey,
            height: 240,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: FlutterMap(
                mapController: _controller,
                options: MapOptions(
                  initialCenter: all.first,
                  initialZoom: 12,
                  initialCameraFit: all.length > 1
                      ? CameraFit.bounds(
                          bounds: LatLngBounds.fromPoints(all),
                          padding: const EdgeInsets.all(40),
                          maxZoom: 14,
                        )
                      : null,
                  onMapReady: () => _ready = true,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.trip_ai_app',
                  ),
                  PolylineLayer(
                    polylines: [
                      for (var i = 0; i < days.length; i++)
                        if (_points(days[i].value).length > 1)
                          Polyline(
                            points: _points(days[i].value),
                            color: tripDayColor(dayColorIndex(days[i].key, i)),
                            strokeWidth: _selected == days[i].key ? 5 : 3,
                          ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      for (var i = 0; i < days.length; i++)
                        for (final point in _points(days[i].value))
                          Marker(
                            point: point,
                            width: 40,
                            height: 40,
                            child: Tooltip(
                              message: days[i].key,
                              child: Icon(
                                Icons.location_pin,
                                size: _selected == days[i].key ? 40 : 34,
                                color: tripDayColor(
                                  dayColorIndex(days[i].key, i),
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: ColoredBox(
                      color: Color(0xDDFFFFFF),
                      child: Padding(
                        padding: EdgeInsets.all(3),
                        child: Text(
                          '© OpenStreetMap contributors',
                          style: TextStyle(color: Colors.black87, fontSize: 9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'ยังไม่พบพิกัดสำหรับแผนนี้ ดูสถานที่และรายละเอียดด้านล่าง',
            ),
          ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (var i = 0; i < days.length; i++)
              ActionChip(
                avatar: Icon(
                  Icons.circle,
                  size: 10,
                  color: tripDayColor(dayColorIndex(days[i].key, i)),
                ),
                label: Text(days[i].key),
                backgroundColor: _selected == days[i].key
                    ? const Color(0xFF20475F)
                    : AppTheme.surface,
                onPressed: () => _focus(days[i].key),
              ),
          ],
        ),
        const SizedBox(height: 12),
        PlaceGallery(dailyRoute: widget.dailyRoute, onDayTap: _focus),
      ],
    );
  }
}
