import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RecommendationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<String>> _getUserPreferredTags(String userId) async {
    try {
      final doc = await _db.collection('user').doc(userId).get();
      if(doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final preferredTags = data['preferredTags'];
        if(preferredTags is List) {
          return List<String>.from(preferredTags);
        }
      }
    } catch(e) {
      debugPrint('Error fetching preferred tags:$e');
    }
    return [];
  }


  Future<Map<String, Map<String, int>>> _getLocationWithTags() async {
    final Map<String, Map<String, int>> result = {};

    try {
      final querySnapshot = await _db.collection('locations').get();

      for (var doc in querySnapshot.docs) {
        final locationData = doc.data();
        final String locationId = doc.id;
        final dynamic rawAllTags = locationData['allTags'];

        final Map<String, int> tagCount = {};

        if(rawAllTags is Map) {
          rawAllTags.forEach((tagName, tagInfo) {
            if (tagInfo is Map) {
              final countVal = tagInfo['count'];
              tagCount[tagName.toString()] = (countVal is num) ? countVal.toInt() : 1;
            } else {
              tagCount[tagName.toString()] = 1;
            }
          });
        }

        result[locationId] = tagCount;
      }
    } catch (e) {
      debugPrint('Error fetchic loc $e');
    }
    return result;
  }

  double _weightedJaccardSim(
  List<String> userTags, Map<String, int> locationTagCount) {
    final Set<String> user = userTags.toSet();
    final Set<String> loc = locationTagCount.keys.toSet();

    final Set<String> commonTags = loc.intersection(user);
    final double numerator = commonTags.length.toDouble();
    final double denominator = loc.union(user).length.toDouble();

    if (denominator == 0.0) {
      return 0.0;
    }
    const double multiplier = 0.05;

    int weight = 0;
    
    for (var tag in commonTags) {
      weight += locationTagCount[tag] ?? 0;
    }

    final double weightMultiplier = 1.0 + (weight * multiplier);
    return (numerator/denominator) * weightMultiplier;
  }

  Future<void> generateAndSaveRecc(String userId) async {
    try {
      final userTags = await _getUserPreferredTags(userId);
      final locationData = await _getLocationWithTags();

      final List<String> sortedLocationIds = locationData.keys.toList()..sort((a,b) {
        final scoreA = _weightedJaccardSim(userTags, locationData[a]!);
        final scoreB = _weightedJaccardSim(userTags, locationData[b]!);
        return scoreB.compareTo(scoreA);
      });

      final List<String> top10Spots = sortedLocationIds.take(10).toList();

      await _db.collection('user').doc(userId).set( {
        'recommendedSpots': top10Spots,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    } catch(e) {
      debugPrint('Error generating recommendations: $e');
    }
  }

  




}