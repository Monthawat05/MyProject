import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/featured_trips.dart';

class FeaturedTripService {
  static List<FeaturedTrip> decode(Map<String, dynamic>? data) {
    if (data == null) return featuredTrips;
    return (data['trips'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .where((item) => item['enabled'] == true)
        .map(FeaturedTrip.fromMap)
        .toList();
  }

  static Stream<List<FeaturedTrip>> watch() => FirebaseFirestore.instance
      .collection('app_content')
      .doc('featured_trips')
      .snapshots()
      .map((snapshot) => decode(snapshot.data()));
}
