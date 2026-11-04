import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static final Map<String, Map<String, double>> _cache = {};

  static Future<Map<String, double>?> getCoordinates(String place) async {
    if (_cache.containsKey(place)) return Map.of(_cache[place]!);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(place)}&format=json&limit=1',
      );

      final response = await http
          .get(url, headers: {'User-Agent': 'TripAIApp/1.0'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final coordinates = {
            'lat': double.parse(data[0]['lat']),
            'lon': double.parse(data[0]['lon']),
          };
          if (_cache.length >= 100) _cache.remove(_cache.keys.first);
          _cache[place] = coordinates;
          return Map.of(coordinates);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ค้นหาพิกัดหลายแห่ง (หน่วงเวลา 1.1 วิ/ครั้ง ตามกฎของ Nominatim)
  static Future<Map<String, Map<String, double>>> getCoordinatesBatch(
    List<String> places,
  ) async {
    final Map<String, Map<String, double>> results = {};
    for (final place in places.toSet()) {
      final cached = _cache.containsKey(place);
      final coords = await getCoordinates(place);
      if (coords != null) {
        results[place] = coords;
      }
      if (!cached) {
        await Future.delayed(const Duration(milliseconds: 1100));
      }
    }
    return results;
  }
}
