import 'package:cloud_firestore/cloud_firestore.dart';


class UserStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//retrieve data from firebase for no.of saved spots and reviews for user
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      //querying the right data!
      final AggregateQuerySnapshot reviewSnapshot = await _firestore
      .collectionGroup('reviews').where('userId', isEqualTo: userId).count().get();

      final AggregateQuerySnapshot savedSnapshot = await _firestore
      .collection('saved_locations').where('userId', isEqualTo: userId).count().get();

      return {
        'spotsReviewed' : reviewSnapshot.count ?? 0,
        'spotsSaved': savedSnapshot.count ?? 0,
      };
    } catch(e) {
      print('Error fetching user stats: $e');
      return {
        'spotsReviewed':0,
        'spotsSaved':0,
      };
    }

  }

}