import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> addLocation({
    required String locationId,
    required String locationName,
    required String review,
    required int rating,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return 'User not authenticated.';
      }

      final DocumentReference locationRef = _firestore.collection('locations').doc();
      final DocumentReference reviewRef = locationRef.collection('reviews').doc();
      final WriteBatch batch = _firestore.batch();
      batch.set(locationRef, {
        'LocationName': locationName,
        'AverageRating': rating.toDouble(), // Initial average rating is the first review's rating
        'ReviewCount': 1, // Initial review count is 1
        'timestamp': FieldValue.serverTimestamp(),
      });

      batch.set(reviewRef, {
      'userId': currentUser.uid,
      'Rating': rating,
      'Review': review,
      'timestamp': FieldValue.serverTimestamp(),
    });
      await batch.commit();
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

  Future<String?> addReviewAndUpdateAverage({
    required String locationId,
    required String review,
    required int rating,
    required String userId,
  }) async {
    try {
      final locationRef = _firestore.collection('locations').doc(locationId);
      final reviewRef = locationRef.collection('reviews').doc();

      await _firestore.runTransaction((transaction) async {
        final locationSnapshot = await transaction.get(locationRef);
        Map<String, dynamic> locationData = {};
        if (locationSnapshot.exists) {
          locationData = locationSnapshot.data() as Map<String, dynamic>;
        }

        // updating average rating with new review
        final double currentAvg = (locationData['AverageRating'] ?? 0).toDouble();
        final int currentCount = (locationData['ReviewCount'] ?? 0).toInt();
        
        final int newCount = currentCount + 1;
        final double newAvg = currentAvg + ((rating - currentAvg) / newCount);
        
        // Add the new review to 'reviews' subcollection
        transaction.set(reviewRef, {
          'Review': review,
          'Rating': rating,
          'userId': userId,
          'timestamp': FieldValue.serverTimestamp(),
        });

       // update the average rating and review count in the main location document
        transaction.update(locationRef, {
          'AverageRating': newAvg,
          'ReviewCount': newCount,
        });
      });
      return null; // Review added and average rating updated successfully
    } catch (e) {
      return 'Failed to update average rating. Please try again.';
    }
  }

/*
  Future<double> getAverageRating(String locationId) async {
    try {
      final QuerySnapshot reviewsSnapshot = await _firestore
          .collection('locations')
          .doc(locationId)
          .collection('reviews')
          .get();
      
      if (reviewsSnapshot.docs.isEmpty) {
        return 0.0; // No reviews, average rating is 0
      }

      double totalRating = 0;
      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final num rating = data['Rating'] ?? 0;
        totalRating += rating.toInt();
      }
      return (totalRating / reviewsSnapshot.docs.length); // Return average rating rounded to nearest double
    } catch (e) {
      return 0.0; // In case of error, return 0
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
*/
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
