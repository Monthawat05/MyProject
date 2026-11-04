import '../widgets/trip_route_view.dart';
import '../theme/app_theme.dart';
import '../widgets/trip_preview_card.dart';

import '../widgets/trip_travel_options.dart';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'trip_input_screen.dart';
import 'edit_itinerary_screen.dart';
import '../widgets/share_trip_button.dart';
import '../services/database_service.dart';
import '../models/trip_model.dart';
import '../models/trip_dates.dart';
import '../widgets/gradient_app_bar.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  late final Stream<List<TripModel>> _trips = DatabaseService.getTrips();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const GradientAppBar(title: 'ทริปฉัน'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<List<TripModel>>(
                stream: _trips,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8ACFFF),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                    );
                  }

                  final trips = snapshot.data ?? [];

                  if (trips.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.card_travel_rounded,
                            size: 100,
                            color: Color(0xFFBBDEFB),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'ยังไม่มีทริปที่บันทึกไว้',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.muted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'เริ่มสร้างทริปแรกของคุณกันเลย!',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      return _TripCard(key: ValueKey(trip.id), trip: trip);
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TripInputScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text(
                  'สร้างทริปใหม่',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripModel trip;
  const _TripCard({super.key, required this.trip});

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ลบทริปนี้?'),
        content: Text('ต้องการลบทริป "${trip.destination}" ใช่หรือไม่'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (confirmed != true || trip.id == null) return;
    try {
      await DatabaseService.deleteTrip(trip.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ลบทริปแล้ว')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบไม่สำเร็จ กรุณาลองอีกครั้ง')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      TripPreviewCard(
        trip: trip,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SavedItineraryView(trip: trip)),
        ),
      ),
      Positioned(
        top: 8,
        right: 8,
        child: IconButton(
          tooltip: 'ลบทริป',
          style: IconButton.styleFrom(
            backgroundColor: const Color(0x990C2940),
            foregroundColor: Colors.white,
          ),
          onPressed: () => _delete(context),
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    ],
  );
}

class SavedItineraryView extends StatefulWidget {
  final TripModel trip;

  final bool readOnly;
  const SavedItineraryView({
    super.key,
    required this.trip,
    this.readOnly = false,
  });

  @override
  State<SavedItineraryView> createState() => SavedItineraryViewState();
}

class SavedItineraryViewState extends State<SavedItineraryView> {
  TripModel get trip => widget.trip;
  late String _itinerary;
  String? _pendingEdit;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _itinerary = trip.itinerary;
  }

  Future<void> _editTrip() async {
    if (_isSaving || widget.readOnly) return;
    final edited = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => EditItineraryScreen(
          initialText: _pendingEdit ?? _itinerary,
          confirmLabel: 'บันทึกการแก้ไข',
        ),
      ),
    );
    if (!mounted || edited == null) return;
    if (edited == _itinerary) {
      _pendingEdit = null;
      return;
    }
    _pendingEdit = edited;
    setState(() => _isSaving = true);
    try {
      await DatabaseService.updateItinerary(trip, edited);
      if (!mounted) return;
      setState(() {
        _itinerary = edited;
        _pendingEdit = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกการแก้ไขทริปแล้ว')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'บันทึกไม่สำเร็จ กดแก้ไขแผนเพื่อลองอีกครั้ง ข้อความที่แก้ยังอยู่ในหน้านี้',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: GradientAppBar(
        title: 'แผนทริป ${trip.destination}',
        actions: [
          ShareTripButton(
            origin: trip.origin,
            destination: trip.destination,
            itinerary: _itinerary,
            days: trip.days,
            startDate: trip.startDate,
          ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          if (!widget.readOnly)
            IconButton(
              tooltip: 'แก้ไขแผน',
              onPressed: _isSaving ? null : _editTrip,
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TripRouteView(dailyRoute: trip.dailyRoute),
            const SizedBox(height: 16),
            if (trip.startDate != null)
              Text(
                tripDateRange(trip.startDate!, trip.days),
                style: const TextStyle(color: AppTheme.accent),
              ),
            if (trip.origin.isNotEmpty)
              TripTravelOptions(
                origin: trip.origin,
                destination: trip.destination,
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Markdown(
                data: _itinerary,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                styleSheet: MarkdownStyleSheet(
                  blockquote: const TextStyle(
                    color: Color(0xFFF1F7FF),
                    fontSize: 15,
                    height: 1.7,
                  ),
                  blockquotePadding: const EdgeInsets.all(16),
                  blockquoteDecoration: const BoxDecoration(
                    color: Color(0xFF203A50),
                    border: Border(
                      left: BorderSide(color: Color(0xFF70E9ED), width: 3),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  code: const TextStyle(
                    color: Color(0xFFE1F3FF),
                    backgroundColor: Color(0xFF0E1B30),
                  ),
                  codeblockDecoration: const BoxDecoration(
                    color: Color(0xFF0E1B30),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  p: const TextStyle(fontSize: 15, height: 1.6),
                  h1: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8ACFFF),
                  ),
                  h2: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8ACFFF),
                  ),
                  h3: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent,
                  ),
                  strong: const TextStyle(fontWeight: FontWeight.bold),
                  listBullet: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
