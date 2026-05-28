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

  Stream<QuerySnapshot> getLocations() {
    return _firestore.collection('locations').orderBy('timestamp', descending: true).snapshots();
  }
}