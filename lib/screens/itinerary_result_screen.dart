import '../widgets/trip_route_view.dart';
import '../theme/app_theme.dart';

import '../widgets/trip_travel_options.dart';

import 'edit_itinerary_screen.dart';
import '../widgets/share_trip_button.dart';
import '../widgets/trip_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../services/ai_service.dart';
import '../services/database_service.dart';
import '../services/geocoding_service.dart';
import '../models/trip_model.dart';
import '../widgets/gradient_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItineraryResultScreen extends StatefulWidget {
  final String destination;
  final String origin;
  final int days;
  final DateTime? startDate;
  final String budget;
  final int travelers;
  final List<String> styles;

  const ItineraryResultScreen({
    super.key,
    required this.destination,
    this.origin = '',
    required this.days,
    this.startDate,
    required this.budget,
    required this.travelers,
    required this.styles,
  });

  @override
  State<ItineraryResultScreen> createState() => _ItineraryResultScreenState();
}

class _ItineraryResultScreenState extends State<ItineraryResultScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSaved = false;
  String _result = '';
  String _errorMessage = '';
  Map<String, List<Map<String, dynamic>>> _dailyRoute = {};

  bool _locatingPlaces = false;

  @override
  void initState() {
    super.initState();
    _fetchItinerary();
  }

  Future<void> _fetchItinerary() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _locatingPlaces = false;
    });
    try {
      final planResult = await AIService.generateTripPlan(
        origin: widget.origin,
        destination: widget.destination,
        days: widget.days,
        startDate: widget.startDate,
        budget: widget.budget,
        travelers: widget.travelers,
        styles: widget.styles,
      );

      if (!mounted) return;
      setState(() => _locatingPlaces = true);

      final allPlaces = planResult.dailyPlaces.values
          .expand((places) => places)
          .toSet()
          .toList();

      // Let the user read the plan while the map is being prepared.
      setState(() {
        _result = planResult.itinerary;
        _isLoading = false;
      });
      final coordsMap = await GeocodingService.getCoordinatesBatch(allPlaces);

      final Map<String, List<Map<String, dynamic>>> dailyRoute = {};
      for (var dayNumber = 1; dayNumber <= widget.days; dayNumber++) {
        final day = 'Day $dayNumber';
        final places = planResult.dailyPlaces[day] ?? <String>[];
        final points = <Map<String, dynamic>>[];
        for (final place in places) {
          final coords = coordsMap[place];
          points.add({
            'name': place,
            if (coords != null) 'lat': coords['lat'],
            if (coords != null) 'lon': coords['lon'],
          });
        }
        dailyRoute[day] = points;
      }

      if (!mounted) return;
      setState(() {
        _dailyRoute = dailyRoute;
        _locatingPlaces = false;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e is TripPlanException
            ? e.message
            : 'สร้างแผนทริปไม่สำเร็จ กรุณาลองอีกครั้ง';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTrip() async {
    if (_isSaving || _isSaved || _locatingPlaces) return;
    setState(() {
      _isSaving = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      final trip = TripModel(
        origin: widget.origin,
        userId: userId,
        destination: widget.destination,
        days: widget.days,
        budget: widget.budget,
        travelers: widget.travelers,
        styles: widget.styles,
        itinerary: _result,
        createdAt: DateTime.now(),
        startDate: widget.startDate,
        dailyRoute: _dailyRoute,
      );

      await DatabaseService.saveTrip(trip);
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _isSaved = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('บันทึกทริปสำเร็จแล้ว!')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: GradientAppBar(
        title: 'แผนทริป ${widget.destination}',
        actions: [
          if (!_isLoading && _errorMessage.isEmpty)
            ShareTripButton(
              origin: widget.origin,
              destination: widget.destination,
              itinerary: _result,
              days: widget.days,
              startDate: widget.startDate,
            ),
        ],
      ),
      body: _isLoading
          ? TripLoadingView(
              destination: widget.destination,
              days: widget.days,
              locatingPlaces: _locatingPlaces,
            )
          : _errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Color(0xFFFF9EAA),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFFF9EAA)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _fetchItinerary,
                      icon: const Icon(Icons.refresh),
                      label: const Text('ลองอีกครั้ง'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_locatingPlaces)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                LinearProgressIndicator(),
                                SizedBox(height: 8),
                                Text(
                                  'กำลังเตรียมแผนที่ อ่านรายละเอียดแผนด้านล่างได้เลย',
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: TripRouteView(dailyRoute: _dailyRoute),
                        ),
                        TripTravelOptions(
                          origin: widget.origin,
                          destination: widget.destination,
                        ),
                        Container(
                          margin: const EdgeInsets.all(20.0),
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
                            data: _result,
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
                                  left: BorderSide(
                                    color: Color(0xFF70E9ED),
                                    width: 3,
                                  ),
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              code: const TextStyle(
                                color: Color(0xFFE1F3FF),
                                backgroundColor: Color(0xFF0E1B30),
                              ),
                              codeblockDecoration: const BoxDecoration(
                                color: Color(0xFF0E1B30),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
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
                              strong: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              listBullet: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!_isSaved)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('แก้ไขแผน'),
                      onPressed: _isSaving
                          ? null
                          : () async {
                              final edited = await Navigator.push<String>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditItineraryScreen(initialText: _result),
                                ),
                              );
                              if (!mounted || edited == null) return;
                              setState(() => _result = edited);
                            },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isSaved || _isSaving || _locatingPlaces
                          ? null
                          : _saveTrip,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              _isSaved
                                  ? Icons.check_circle
                                  : Icons.bookmark_add_outlined,
                            ),
                      label: Text(
                        _isSaved ? 'บันทึกแล้ว' : 'บันทึกทริปนี้',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSaved
                            ? Colors.green
                            : const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
