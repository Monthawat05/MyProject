import 'trip_day_order.dart';

class TripModel {
  final String? id;
  final String userId;
  final String destination;
  final String origin;
  final int days;
  final String budget;
  final int travelers;
  final List<String> styles;
  final String itinerary;
  final DateTime createdAt;
  final DateTime? startDate;
  final Map<String, List<Map<String, dynamic>>> dailyRoute;

  TripModel({
    this.id,
    required this.userId,
    required this.destination,
    this.origin = '',
    required this.days,
    required this.budget,
    required this.travelers,
    required this.styles,
    required this.itinerary,
    required this.createdAt,
    this.startDate,
    this.dailyRoute = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'destination': destination,
      'origin': origin,
      'days': days,
      'budget': budget,
      'travelers': travelers,
      'styles': styles,
      'itinerary': itinerary,
      'createdAt': createdAt.toIso8601String(),
      if (startDate != null)
        'startDate':
            '${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}',
      'dailyRoute': dailyRoute,
    };
  }

  factory TripModel.fromMap(String id, Map<String, dynamic> map) {
    Map<String, List<Map<String, dynamic>>> parsedRoute = {};
    if (map['dailyRoute'] != null) {
      final rawRoute = map['dailyRoute'] as Map<String, dynamic>;
      parsedRoute = rawRoute.map((key, value) {
        final list = (value as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        return MapEntry(key, list);
      });
    }

    return TripModel(
      id: id,
      userId: map['userId'] ?? '',
      destination: map['destination'] ?? '',
      origin: map['origin'] is String ? map['origin'] : '',
      days: map['days'] ?? 1,
      budget: map['budget'] ?? '',
      travelers: map['travelers'] ?? 1,
      styles: List<String>.from(map['styles'] ?? []),
      itinerary: map['itinerary'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      startDate: map['startDate'] is String
          ? DateTime.tryParse(map['startDate'])
          : null,
      dailyRoute: sortTripDays(parsedRoute),
    );
  }
}
