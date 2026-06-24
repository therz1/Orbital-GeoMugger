import 'package:cloud_firestore/cloud_firestore.dart';


class HottestSpotsService {

  final DocumentReference _docRef = FirebaseFirestore.instance
    .collection('metadata').doc('hottest_spots');

  Future<List<String>> fetchHottestSpotIds() async {
    try {
      final response = await _docRef.get();

      if (response.exists && response.data() != null){
        final Map<String, dynamic> data = response.data() as Map<String, dynamic>;
        List<dynamic> ids = data["hottest_spot_ids"] ?? [];
        print("debug: $ids");
        return List<String>.from(ids);
      }
      return [];
    } catch (e) {
      print("error fetching hottest spots from python $e");
      return [];
    }
    }
  }
