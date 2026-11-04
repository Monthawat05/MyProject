import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageLookupException implements Exception {
  final String message;
  const ImageLookupException(this.message);
}

class ImageService {
  static final Map<String, String> _queryCache = {};
  static final Map<String, String> _imageCache = {};
  static final Map<String, Future<String?>> _coverRequests = {};

  static Future<String?> getDestinationImage(String destination) async {
    final name = destination.trim();
    if (name.isEmpty) return null;
    final pending = _coverRequests[name];
    if (pending != null) return pending;
    final request = _findDestinationImage(name);
    _coverRequests[name] = request;
    try {
      return await request;
    } finally {
      _coverRequests.remove(name);
    }
  }

  static Future<String?> _findDestinationImage(String name) async {
    // Common names work even when the AI translation service is unavailable.
    const destinationNames = {
      'ญี่ปุ่น': 'Japan',
      'เกาหลี': 'South Korea',
      'เกาหลีใต้': 'South Korea',
      'ไทย': 'Thailand',
      'กรุงเทพ': 'Bangkok Thailand',
      'กรุงเทพฯ': 'Bangkok Thailand',
      'กรุงเทพมหานคร': 'Bangkok Thailand',
      'เชียงใหม่': 'Chiang Mai Thailand',
      'ภูเก็ต': 'Phuket Thailand',
      'กระบี่': 'Krabi Thailand',
      'โตเกียว': 'Tokyo Japan',
      'โอซาก้า': 'Osaka Japan',
      'โอซากา': 'Osaka Japan',
      'เกียวโต': 'Kyoto Japan',
    };
    final knownQuery = destinationNames[name];
    if (knownQuery != null) return getPlaceImage(knownQuery);
    final translated = await _englishQueries([name]);
    return getPlaceImage(translated[name] ?? name);
  }

  // Translate a batch once, including names from previously saved trips.
  static Future<Map<String, String>> _englishQueries(
    List<String> places,
  ) async {
    final missing = places
        .where(
          (p) =>
              RegExp(r'[\u0E00-\u0E7F]').hasMatch(p) &&
              !_queryCache.containsKey(p),
        )
        .toList();
    final key = dotenv.env['GEMINI_API_KEY'];
    if (missing.isEmpty || key == null || key.isEmpty) return _queryCache;
    try {
      final configured = dotenv.env['GEMINI_MODEL']?.trim();
      final model = configured == null || configured.isEmpty
          ? 'gemini-3.5-flash-lite'
          : configured;
      final response = await http
          .post(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
            ),
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': key,
            },
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {
                      'text':
                          'Translate these place names into concise English photo search queries. '
                          'Use the actual landmark name and city, never substitute a different place. '
                          'Return a JSON object mapping each exact original string to its English query: '
                          '${jsonEncode(missing)}',
                    },
                  ],
                },
              ],
              'generationConfig': {'responseMimeType': 'application/json'},
            }),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final parts = data['candidates'][0]['content']['parts'] as List;
        final text = parts
            .whereType<Map>()
            .where((p) => p['thought'] != true && p['text'] is String)
            .map((p) => p['text'] as String)
            .join();
        final start = text.indexOf('{');
        final end = text.lastIndexOf('}');
        final translated = jsonDecode(text.substring(start, end + 1));
        if (translated is Map) {
          for (final place in missing) {
            final value = translated[place];
            if (value is String && value.trim().isNotEmpty) {
              _queryCache[place] = value.trim();
            }
          }
        }
      } else {
        debugPrint('ImageService: translation HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ImageService: translation failed (${e.runtimeType})');
      // Photo lookup can still use the original name if translation is unavailable.
    }
    return _queryCache;
  }

  static Future<String?> getPlaceImage(String query) async {
    if (_imageCache.containsKey(query)) return _imageCache[query];
    try {
      final accessKey = dotenv.env['UNSPLASH_ACCESS_KEY'];
      if (accessKey == null || accessKey.trim().isEmpty) {
        throw const ImageLookupException('ยังไม่ได้ตั้งค่า API สำหรับค้นหารูป');
      }

      final url = Uri.parse(
        'https://api.unsplash.com/search/photos?query=${Uri.encodeComponent(query)}&per_page=1',
      );

      final response = await http
          .get(url, headers: {'Authorization': 'Client-ID ${accessKey.trim()}'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          final image = results[0]['urls']['regular'] as String;
          _imageCache[query] = image;
          return image;
        }
      } else {
        debugPrint('ImageService: Unsplash HTTP ${response.statusCode}');
        throw ImageLookupException(
          response.statusCode == 401
              ? 'API key สำหรับค้นหารูปไม่ถูกต้อง'
              : response.statusCode == 403 || response.statusCode == 429
              ? 'บริการรูปปฏิเสธคำขอหรือโควตาเต็ม กรุณาลองภายหลัง'
              : 'บริการค้นหารูปขัดข้อง (${response.statusCode})',
        );
      }
      return null;
    } on ImageLookupException {
      rethrow;
    } catch (e) {
      // Authentication is in the header, so the exception URI contains no key.
      debugPrint(
        'ImageService: Unsplash connection error (${e.runtimeType}): $e',
      );
      throw const ImageLookupException(
        'โหลดรูปไม่สำเร็จ กรุณาตรวจสอบอินเทอร์เน็ตแล้วลองอีกครั้ง',
      );
    }
  }

  // ดึงรูปหลายสถานที่พร้อมกัน
  static Future<Map<String, String>> getPlaceImages(List<String> places) async {
    final Map<String, String> results = {};

    Map<String, String> queries = {};
    try {
      queries = await _englishQueries(places);
    } catch (e) {
      debugPrint('ImageService: translation pre-process failed ($e)');
    }

    dynamic lastException;
    bool hasAnySuccess = false;
    final uniquePlaces = places.toSet();

    for (final place in uniquePlaces) {
      try {
        final queryText = queries[place] ?? place;
        final imageUrl = await getPlaceImage(queryText);
        if (imageUrl != null) {
          results[place] = imageUrl;
          hasAnySuccess = true;
        }
        if (uniquePlaces.length > 1) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      } catch (e) {
        debugPrint(
          'ImageService: failed to get image for $place (${e.runtimeType}): $e',
        );
        lastException = e;
      }
    }

    // If we failed to get even a single image and there was an exception, rethrow it
    if (!hasAnySuccess && lastException != null) {
      throw lastException;
    }

    if (!hasAnySuccess &&
        places.any(
          (p) =>
              RegExp(r'[\u0E00-\u0E7F]').hasMatch(p) && !queries.containsKey(p),
        )) {
      throw const ImageLookupException(
        'แปลชื่อสถานที่สำหรับค้นหารูปไม่สำเร็จ กรุณาลองโหลดรูปอีกครั้ง',
      );
    }

    return results;
  }
}
