import 'package:flutter/material.dart';
import '../services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final String starString = '⭐' * widget.rating; // Convert rating to star string
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

            Row(
              children: [
                Text('Rating: ', style: TextStyle(fontSize: 18)),
                Text(starString, style: TextStyle(fontSize: 18, color: Colors.orange)),
              ],
            ),
            const Divider(height: 16, thickness: 1),

            const Text(
              'Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(widget.review, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}