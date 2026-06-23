import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geo_mugger/services/hottest_spots_service.dart';
import 'package:geo_mugger/views/location_page.dart';

class HottestSpotsSection extends StatefulWidget {
  const HottestSpotsSection({super.key});

  @override
  State<HottestSpotsSection> createState() => _HottestSpotsSectionState();
}

class _HottestSpotsSectionState extends State<HottestSpotsSection> {
  late Future<List<String>> _hottestIdsFuture;

  @override
  void initState() {
    super.initState();
    _hottestIdsFuture = HottestSpotsService().fetchHottestSpotIds();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Hottest Study Spot >',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 160,
          child: FutureBuilder<List<String>>(
            future: _hottestIdsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("no spots found"));
              }
              final List<String> orderedIds = snapshot.data!;

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('locations')
                    .where(FieldPath.documentId, whereIn: orderedIds)
                    .get(),
                builder: (context, firestoreSnapshot) {
                  if (!firestoreSnapshot.hasData) {
                    return const SizedBox();
                  }

                  final docMap = {
                    for (var doc in firestoreSnapshot.data!.docs) doc.id: doc
                  };
                  final sortedDocs = [
                    for (var id in orderedIds) if (docMap.containsKey(id)) docMap[id]!
                  ];

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    itemCount: sortedDocs.length,
                    itemBuilder: (context, index) {
                      final docData = sortedDocs[index].data() as Map<String, dynamic>;
                      final String name = docData['LocationName'] ?? 'Unknown Location';
                      final String imageUrl = docData['ImageUrl'] ?? '';
                      final double rating = (docData['AverageRating'] ?? 0.0).toDouble();
                      final docSnapshot = sortedDocs[index];
                      final String docId = docSnapshot.id;
                      final String review = docData['Review'] ?? "see user reviews";

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap:() {
                          //reusing logic from home_view.dart
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LocationDetailPage(
                                locationID: docId,
                                locationName: name,
                                review: review,
                                rating: rating.toInt(),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                    image: imageUrl.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(imageUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                ),
                              ), //
                              const SizedBox(height: 6),
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 15, color: Colors.amber),
                                  const SizedBox(width: 2),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}