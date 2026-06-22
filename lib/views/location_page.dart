import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../widgets/star_display.dart';
import '../widgets/main_star_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'add_review_page.dart';

class LocationDetailPage extends StatefulWidget {
  final String locationID; 
  final String locationName;
  final String review;
  final int rating;

  // The constructor requires the data fields passed from the clicked card
  const LocationDetailPage({
    super.key,
    required this.locationID,
    required this.locationName,
    required this.review,
    required this.rating,
  });

  @override
  State<LocationDetailPage> createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  @override
  Widget build(BuildContext context) {
    //final String starString = '⭐' * widget.rating; // Convert rating to star string
    final String currentUser = FirebaseAuth.instance.currentUser?.uid ?? ''; // Get current user ID for bookmark check

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
        actions: [
          // CHECKS IF SAVED OR NOT
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('saved_locations')
                .where('userId', isEqualTo: currentUser)
                .where('locationId', isEqualTo: widget.locationID)
                .snapshots(),
            builder: (context, snapshot) {
              // Default state while waiting for network stream check
              bool isSaved = false;

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                isSaved = true; // Document exists -> Item is bookmarked!
              }
              return IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border
                ),
                tooltip: 'Save Location?',
                onPressed: () async {
                  final String? result = await LocationService().toggleSaveLocation(
                    locationId: widget.locationID,
                    locationName: widget.locationName,
                    rating: widget.rating,
                  );
                  // Implement bookmark functionality here
                  if (context.mounted && result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result), duration: const Duration(seconds: 2)),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),

      // SHOWS ALL DETAILS 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                      .collection('locations')
                      .doc(widget.locationID)
                      .snapshots(),
              builder:(context, snapshot) {
                double avgRating = 0.0;
                String imgUrl = '';

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  final rawRating = data?['averageRating'] ?? 0;
                  avgRating = (rawRating).toDouble();
                  imgUrl = data?['imageUrl'] ?? '';
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Banner
                    if (imgUrl.isNotEmpty)...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: imgUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,

                          // Loading placeholder
                          placeholder:(context, url) => Container( 
                              height: 200,
                              color: Colors.grey[100],
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth:2, color: Colors.orange),
                              ),
                          ),
                         
                          // Error Display
                          errorWidget: (context, url, error) => Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                              ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Text(
                      widget.locationName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row (
                      children: [
                        const Text('Rating: ', style: TextStyle(fontSize: 18)),
                        MainStarRatingWidget(rating: avgRating),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),           
            const Divider(height: 16, thickness: 1),

            // add a review section
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddReviewPage(
                        locationId: widget.locationID,
                        locationName: widget.locationName,
                        review: widget.review,
                        rating: widget.rating,
                      ),
                    ),
                  );
                },
                child: const Text('Add Review?'),
              ),
            ),
            const Divider(height: 16, thickness: 1),

            // Reviews
            
            const Text(
              'Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: LocationService().getReviews(widget.locationID),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error loading reviews');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;
                      final String imgUrl = data['imageUrl'] ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column (
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              if (imgUrl.isNotEmpty)...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: imgUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,

                                    // Loading placeholder
                                    placeholder:(context, url) => Container( 
                                        height: 200,
                                        color: Colors.grey[100],
                                        child: const Center(
                                          child: CircularProgressIndicator(strokeWidth:2, color: Colors.orange),
                                        ),
                                    ),
                                  
                                    // Error Display
                                    errorWidget: (context, url, error) => Container(
                                        height: 200,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                        ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                  
                              Row (
                                children: [
                                  StarRatingWidget(rating: data['rating']),
                                  const Spacer(),
                                  Text(
                                    data['timestamp'] != null 
                                        ? (data['timestamp'] as Timestamp).toDate().toString().substring(0, 10)
                                        : '',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['review'] ?? 'No review available',
                              ), 
                              const SizedBox(height: 20),
                            ]
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}