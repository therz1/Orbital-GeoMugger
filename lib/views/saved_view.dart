import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geo_mugger/widgets/tag_filter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_page.dart';
import '../widgets/main_star_display.dart';
import '../services/location_service.dart';


class SavedView extends StatefulWidget {
  const SavedView({super.key});
  @override
  State<SavedView> createState() => _SavedViewState();
}

class _SavedViewState extends State<SavedView> {   
  Map <String, List<String>> _tagMap = {};
  final List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _fetchTags();
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

  Future<void> _fetchTags() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('metadata').doc('tags_list').get();
      if(doc.exists) {
        setState(() {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _tagMap = data.map((key, value) => MapEntry(key, List<String>.from(value),));
        });
      }
    } catch(error) {
      debugPrint("Error fetching tag Map : $error");
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
    return StreamBuilder<QuerySnapshot>(
      stream: LocationService().getSavedLocations(), 
      builder: (context, snapshot) {
        // 1. Waiting for data
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator(color:Colors.orange));
        }
        
        // 2. Error occured
        if (snapshot.hasError){
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error loading saved spots: ${snapshot.error}'),
            ),
          );
        }

        // 3. Data loaded but empty
        final savedDocs = snapshot.data?.docs ?? [];
        if (savedDocs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text("No bookmarked locations yet.", style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: savedDocs.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final Map<String, dynamic> data = savedDocs[index].data() as Map<String, dynamic>;

            final String locationName = data['locationName'] ?? 'Unknown Location';
            final String review = data['review'] ?? '';
            final int rating = data['rating'] ?? 0;
            final String realLocationId = data['locationId'] ?? '';
            final num rawRating = data['averageRating'] ?? 0;
            final double avgRating = rawRating.toDouble();
            final String imgUrl = data['imageUrl'] ?? '';
            // Handles geolocation
            LatLng geoLocation = const LatLng(1.3521, 103.8198); // Default fallback

            final dynamic locationData = data['geoLocation'];

            if (locationData is String && locationData.isNotEmpty) {
              final parts = locationData.split(',');
                        
              // Check that the split actually created at least two parts
              if (parts.length >= 2) {
                final lat = double.tryParse(parts[0].trim());
                final lng = double.tryParse(parts[1].trim());

                if (lat != null && lng != null) {
                  geoLocation = LatLng(lat, lng);
                }
              } else {
                // This handles strings like "1.3521" (no comma)
                debugPrint("Invalid location format found: $locationData");
              }
            } else if (locationData is GeoPoint) {
              geoLocation = LatLng(locationData.latitude, locationData.longitude);
            }

            final GeoPoint geoPoint = GeoPoint(
              geoLocation.latitude, 
              geoLocation.longitude
            );

            // Directly extract tags from the existing 'data' snapshot
            final List<dynamic> topTags = data['topTags'] ?? [];

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationDetailPage(
                        locationID: realLocationId,
                        locationName: locationName,
                        review: review,
                        rating: rating,
                        imgUrl: imgUrl,
                        avgRating: avgRating,
                        topTags: topTags,
                        geoLocation: geoPoint,
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
                  
                  
                  // Thumbnail 
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
                            ],
                ),
              ),
            ),
            );
          },
        );
      },
    );
  }
}