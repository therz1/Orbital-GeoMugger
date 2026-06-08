import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> addLocation({
    required String locationName,
    required String review,
    required int rating,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return 'User not authenticated.';
      }

      await _firestore.collection('locations').add({
        'LocationName': locationName,
        'Review': review,
        'Rating': rating,
        'userId': currentUser.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return null; // Location added successfully
    } catch (e) {
      return 'Failed to save location. Please try again.';
    }
  }

  // Bookmarking functionality
  Future<String?> toggleSaveLocation({
    required String locationId,
    required String locationName,
    required int rating,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return 'User not authenticated.';
      }

      final QuerySnapshot existingSave = await _firestore
          .collection('saved_locations')
          .where('userId', isEqualTo: currentUser.uid)
          .where('locationId', isEqualTo: locationId)
          .get();
      
      if (existingSave.docs.isNotEmpty) {
        await _firestore.collection('saved_locations').doc(existingSave.docs.first.id).delete();
        return 'Location removed from saved list.';
      } else {
        await _firestore.collection('saved_locations').add({
          'userId': currentUser.uid,
          'locationId': locationId,
          'LocationName': locationName,
          'Rating': rating,
          'timestamp': FieldValue.serverTimestamp(),
        });
        return 'Location saved successfully.';
      }
    } catch (e) {
      return 'Failed to save location. Please try again.';
    }
  }

  Future<int?> getAverageRating(String locationId) async {
    try {
      final QuerySnapshot reviewsSnapshot = await _firestore
          .collection('locations')
          .doc(locationId)
          .collection('reviews')
          .get();
      int sum = reviewsSnapshot.docs.length;     
      if (reviewsSnapshot.docs.isEmpty) {
        return 0; // No reviews, average rating is 0
      }
      double totalRating = 0;
      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final num rating = data['Rating'] ?? 0;
        totalRating += rating.toInt();
      }
      return (totalRating / sum).round(); // Return average rating rounded to nearest integer
    } catch (e) {
      return 0; // In case of error, return 0
    }
  }

  Future<String?> addReview({
    required String locationId,
    required String review,
    required int rating,
  }) async {
    try {
      await _firestore
      .collection('locations')
      .doc(locationId)
      .collection('reviews')
      .add({
        'Review': review,
        'Rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      return 'Failed to add review. Please try again.';
    }
  }

  Stream<QuerySnapshot> getLocations() {
    return _firestore.collection('locations').orderBy('timestamp', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getSavedLocations() {
    final User? currentUser = _auth.currentUser;
    final String userId = currentUser?.uid ?? '';

    return _firestore
    .collection('saved_locations')
    .where('userId', isEqualTo: userId)
    .orderBy('timestamp', descending: true)
    .snapshots();
  }

  Stream<QuerySnapshot> getReviews(String locationId) {
    return _firestore
      .collection('locations')
      .doc(locationId)
      .collection('reviews')
      .orderBy('timestamp', descending: true)
      .snapshots();
  }

}
