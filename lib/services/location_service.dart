import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> addLocation({
    //required String locationId,
    required String locationName,
    required String review,
    required int rating,
    required List<Map<String, String>> userSelectedTags,
    XFile? imageFile,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return 'User not authenticated.';
      }

      final String locationId = _firestore.collection('locations').doc().id;
      final DocumentReference locationRef = _firestore.collection('locations').doc(locationId);
      final DocumentReference reviewRef = locationRef.collection('reviews').doc();
      final DocumentReference imageRef = locationRef.collection('images').doc();

      String? downloadUrl;

      if(imageFile != null){
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference storageRef = _storage.ref().child('location_images').child('${locationId}_$fileName');

        if (kIsWeb) {
          // Read file bytes out into local runtime memory arrays
          final Uint8List rawBytes = await imageFile.readAsBytes();
          UploadTask uploadTask = storageRef.putData(
            rawBytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          TaskSnapshot storageSnapshot = await uploadTask;
          downloadUrl = await storageSnapshot.ref.getDownloadURL();
        } else {
          // Mobile fallback strategy using native File pointers
          UploadTask uploadTask = storageRef.putFile(File(imageFile.path));
          TaskSnapshot storageSnapshot = await uploadTask;
          downloadUrl = await storageSnapshot.ref.getDownloadURL();
        }
    }
      
      final WriteBatch batch = _firestore.batch();

      Map<String, dynamic> allTags = {};
      for(var tag in userSelectedTags) {
        String tagName = tag['name']!;
        String tagCategory = tag['category']!;
        allTags[tagName] = {'category': tagCategory, 'count' : 1};
      }

      List<Map<String, dynamic>> topTags = userSelectedTags.take(5).map((tag) => {
        'name': tag['name']!,
        'category': tag['category']!,
      }).toList();

      batch.set(locationRef, {
        'LocationId': locationId,
        'LocationName': locationName,
        'AverageRating': rating.toDouble(), // Initial average rating is the first review's rating
        'ReviewCount': 1, // Initial review count is 1
        'ImageUrl': downloadUrl ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'allTags': allTags,
        'topTags': topTags,
      });

      batch.set(reviewRef, {
        'userId': currentUser.uid,
        'Rating': rating,
        'Review': review,
        'imageUrl': downloadUrl ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (downloadUrl != null){
        batch.set(imageRef, {
          'userId': currentUser.uid,
          'imageUrl': downloadUrl, 
          'reviewId': reviewRef.id,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

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
    XFile? imageFile,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return 'User not authenticated.';
      }

      final locationRef = _firestore.collection('locations').doc(locationId);
      final reviewRef = locationRef.collection('reviews').doc();
      final imageRef = locationRef.collection('images').doc();

      String? downloadUrl;
      if(imageFile != null){
          String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
          Reference storageRef = _storage.ref().child('location_images').child('${locationId}_$fileName');

          if (kIsWeb) {
            // Read file bytes out into local runtime memory arrays
            final Uint8List rawBytes = await imageFile.readAsBytes();
            UploadTask uploadTask = storageRef.putData(
              rawBytes,
              SettableMetadata(contentType: 'image/jpeg'),
            );
            TaskSnapshot storageSnapshot = await uploadTask;
            downloadUrl = await storageSnapshot.ref.getDownloadURL();
          } else {
            // Mobile fallback strategy using native File pointers
            UploadTask uploadTask = storageRef.putFile(File(imageFile.path));
            TaskSnapshot storageSnapshot = await uploadTask;
            downloadUrl = await storageSnapshot.ref.getDownloadURL();
          }
        }

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
          'imageUrl': downloadUrl ?? '',
          'timestamp': FieldValue.serverTimestamp(),
        });

       // update the average rating and review count in the main location document
        transaction.update(locationRef, {
          'AverageRating': newAvg,
          'ReviewCount': newCount,
        });

        if (downloadUrl != null){
          transaction.set(imageRef, {
            'userId': currentUser.uid,
            'imageUrl': downloadUrl, 
            'reviewId': reviewRef.id,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      });
      return null; // Review added and average rating updated successfully
    } catch (e) {
      return 'Failed to update average rating. Please try again.';
    }
  }

  Future <void> updateLocationTags({
    required String locationId,
    required List<Map<String, String>> userSelectedTags,
  }) async{
    if(userSelectedTags.isEmpty) return;
    final DocumentReference locationRef = _firestore.collection('locations').doc(locationId);
    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(locationRef);

      if(!snapshot.exists) {
        throw Exception("location does not exist");
      }

      final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>? ?? {};
      final Map<String, dynamic> allTags = data['allTags'] != null
        ? Map<String, dynamic>.from(data['allTags'] as Map) : {};

        for(var tags in userSelectedTags) {
          String tagName = tags['name']!;
          String tagCategory = tags['category']!;

          if(allTags.containsKey(tagName)) {
            allTags[tagName]['count'] = (allTags[tagName]['count'] ?? 0) + 1;
          } else {
            allTags[tagName] = {'category': tagCategory, 'count': 1};
          } 
        }

     final List<Map<String, dynamic>> sortedTagList = allTags.entries.map((entry) {
        final Map<String, dynamic> tagVal = Map<String, dynamic>.from(entry.value as Map);
        return {
          'name': entry.key,
          'category': tagVal['category'] ?? 'Vibes',
          'count' : tagVal['count']?? 1 ,
        };
      }).toList();

      sortedTagList.sort((a,b) => b['count'].compareTo(a['count']));
      List<Map<String,dynamic>> updatedTopTags = sortedTagList.take(5)
            .map((item) => {'name' : item['name'], 'category': item['category']}).toList();
      transaction.update(locationRef,{'allTags': allTags, 'topTags': updatedTopTags});
      });
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
