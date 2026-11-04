import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip_model.dart';

class DatabaseService {
  static final CollectionReference _tripsCollection = FirebaseFirestore.instance
      .collection('trips');

  static Future<void> saveTrip(TripModel trip) async {
    await _tripsCollection.add(trip.toMap());
  }

  static Future<void> updateItinerary(TripModel trip, String itinerary) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid != trip.userId || trip.id == null) {
      throw StateError('ไม่สามารถแก้ไขทริปนี้ได้');
    }
    if (itinerary.trim().isEmpty) {
      throw ArgumentError('แผนทริปต้องไม่ว่าง');
    }
    await _tripsCollection.doc(trip.id).update({'itinerary': itinerary.trim()});
  }

  // ดึงเฉพาะทริปของผู้ใช้ที่ login อยู่เท่านั้น
  static Stream<List<TripModel>> getTrips() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _tripsCollection.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final trips = snapshot.docs
          .map(
            (doc) =>
                TripModel.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();

      trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return trips;
    });
  }

  static Future<void> deleteTrip(String id) async {
    await _tripsCollection.doc(id).delete();
  }
}
