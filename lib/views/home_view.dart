import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/location_service.dart';
import 'location_page.dart';
import '../widgets/searchbar.dart';
import '../widgets/main_star_display.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          //title: const Text('Surf Spots'),
          backgroundColor: Colors.orange,
        ),
        body: Column(
          children: [
            // Search bar
            LocationSearchBar(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
   
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: LocationService().getLocations(),
                builder: (context, snapshot) {
                  // 1: Waiting for data
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // 2: Error occurred
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading locations'));
                  }
                  // 3: Data loaded successfully BUT empty.
                  final locations = snapshot.data?.docs ?? [];
                  if (locations.isEmpty) {
                    return const Center(child: Text('No locations added yet.'));
                  }
                  
                  //4: Data loaded successfully with content.
                  // final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
                  final documents = locations.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['timestamp'] == null) return false; // Skip documents without timestamp
                    final String locationName = (data['LocationName'] ?? '').toString().toLowerCase();
                    return locationName.contains(_searchQuery);
                  }).toList();

                  // Safeguard check for empty results after filtering
                  if (documents.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'Synchronizing new location data or no matches found...',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: documents.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      // document snapshot information:
                      final docSnapshot = documents[index];
                      final String docId = docSnapshot.id; // Unique document ID for navigation
                    
                      final Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;
                      
                      final String locationName = data['LocationName'] ?? 'Unknown Location';
                      final String review = data['Review'] ?? 'No review provided.';
                      final int rating = data['Rating'] ?? 0;
                      final double avgRating = data['AverageRating'] ?? 0.0;

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
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.brown,
                              child: const Icon(Icons.location_on, color: Colors.orange),
                            ),
                            title: Text(locationName),
                            //subtitle: Text(review),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: MainStarRatingWidget(rating: avgRating),
                            ),
                          ),
                      ),
                    );
                  },
                );
              },
            ),
          ), // End of Expanded
        ], // End of Column children
      ), // End of Column body
    );
  }
}