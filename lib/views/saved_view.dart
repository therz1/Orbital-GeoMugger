import 'package:flutter/material.dart';
import '../services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'location_page.dart';

class SavedView extends StatelessWidget {
  const SavedView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: LocationService().getSavedLocations(), 
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator(color:Colors.orange));
        }
        if (snapshot.hasError){
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error loading saved spots: ${snapshot.error}'),
            ),
          );
        }

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

            final String locationName = data['LocationName'] ?? 'Unknown Location';
            final String review = data['Review'] ?? '';
            final int rating = data['Rating'] ?? 0;
            final String realLocationId = data['locationId'] ?? '';

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
                  subtitle: Text('Rating: ${"⭐" * rating}'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}