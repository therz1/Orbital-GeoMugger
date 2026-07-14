import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geo_mugger/views/location_page.dart';
import 'package:geo_mugger/widgets/main_star_display.dart';

class RecommendedSpot extends StatelessWidget {
  const RecommendedSpot({super.key});

  Future<List<DocumentSnapshot>> _fetchLocation(List<dynamic> locationId) async {
    if (locationId.isEmpty) return [];

    List<DocumentSnapshot> locations = [];
    for(var id in locationId) {
      var doc = await FirebaseFirestore.instance.collection('locations').doc(id).get();
      if(doc.exists) {
        locations.add(doc);
      }
    }
    return locations;
  }
    Color _tagColor(String cateogry) {
    switch(cateogry) {
      case 'Vibes':
        return const Color.fromARGB(255, 2, 224, 254);
      case 'Amenities':
        return const Color.fromARGB(255, 255, 153, 0);
      case 'Facilities near-by':
        return const Color.fromARGB(255, 112, 187, 69);
      default:
        return Colors.transparent;
    }
  }

  Widget _buildFallbackIcon() {
    return Container(
      color: Colors.orange[50],
      child: const Icon(
        Icons.location_on, 
        color: Colors.orange, 
        size: 28
      ),
    );
  } 
  @override

  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return StreamBuilder<DocumentSnapshot> (
      stream: FirebaseFirestore.instance.collection('user')
      .doc(user?.uid).snapshots(),
      builder: (context, userSnapshot) {
        if(!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return Center(child: CircularProgressIndicator(color: Colors.black));
        }
        final userData = userSnapshot.data!.data() as Map<String, dynamic> ?;
        final List<dynamic> recommendedIds = userData?['recommendedSpots'] ?? [];

        if(recommendedIds.isEmpty) {
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text("wait for update for location to show",
              textAlign: TextAlign.center, 
              style: TextStyle(color: Colors.grey),
              ),
              ),
          );
        }
        return FutureBuilder<List<DocumentSnapshot>> (
          future: _fetchLocation(recommendedIds),
          builder: (context, locationSnapshot) {
            if(locationSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.black));

            }

            final locations = locationSnapshot.data ?? [];
// moved logic from home-view here
            return ListView.builder(
              itemCount: locations.length,
              shrinkWrap: true,
              padding: EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final docSnapshot = locations[index ];
                final String docId = docSnapshot.id; // Unique document ID for navigation
              
                final Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
                
                final String locationName = data['locationName'] ?? 'Unknown Location';
                final String review = data['review'] ?? 'No review provided.';
                final int rating = data['rating'] ?? 0;
                final num rawRating = data['averageRating'] ?? 0;
                final double avgRating = rawRating.toDouble();
                final String imgUrl = data['imageUrl'] ?? '';

                final List<dynamic> topTags = data['topTags'] ?? [];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      // Navigate to the detail page with the location data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocationDetailPage(
                            locationID: docId,
                            locationName: locationName,
                            review: review,
                            rating: rating,
                            imgUrl: imgUrl,
                            avgRating: avgRating,
                            topTags: topTags, // Pass the topTags to the detail page
                          ),
                        ),
                      );
                    },

                    child: ListTile(
                      isThreeLine: topTags.isNotEmpty,
                      leading: SizedBox(
                        width: 60,
                        height: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imgUrl.isNotEmpty ? CachedNetworkImage(
                            imageUrl: imgUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[100],
                              child: const Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => _buildFallbackIcon(),
                          )
                          : _buildFallbackIcon(),
                        ),
                      ),
                      title: Text(locationName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: MainStarRatingWidget(rating: avgRating),
                      ),

                      if (topTags.isNotEmpty) 
                      Wrap(
                        spacing: 4.0,
                        runSpacing: 4.0,
                        children: topTags.take(5).map((tagItem) {
                          final Map<String, dynamic> tag = Map<String, dynamic>.from(tagItem as Map);
                          final String name = tag['name'] ?? '';
                          final String category = tag['category'] ?? '';
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: _tagColor(category),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              name,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                          ),
                        // ==================================================================
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        );
      },
    );
  }
}

                  

  
