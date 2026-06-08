import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../widgets/star_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            Text(
              widget.locationName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // ratings
            Row(
              children: [
                Text('Rating: ', style: TextStyle(fontSize: 18)),
                StarRatingWidget(rating: widget.rating), // Using the star rating widget
                //Text(starString, style: TextStyle(fontSize: 18, color: Colors.orange)),
              ],
            ),
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
                      return ListTile(
                        title: StarRatingWidget(rating: data['Rating']), // Display star rating for each review
                        subtitle: Text(data['Review'] ?? 'No review available'),                   
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