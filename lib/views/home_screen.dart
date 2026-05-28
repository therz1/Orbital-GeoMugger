import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_location_page.dart';

// File contains the home screen after successful login.
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoMugger'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
            },
          )
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
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
          final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;
              
              final String locationName = data['LocationName'] ?? 'Unknown Location';
              //final String review = data['Review'] ?? 'No review provided.';
              final int rating = data['Rating'] ?? 0;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.brown,
                    child: const Icon(Icons.location_on, color: Colors.orange),
                  ),
                  title: Text(locationName),
                  //subtitle: Text(review),
                  subtitle: Text('Rating: ${'⭐' * rating}'),
                ),
              );
             }
          );
        },
      ),


      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add_location_alt, color: Colors.white),
        onPressed: () async{
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLocationPage()),
          );
        },
      ),
    );
  }

  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoMugger Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Welcome to the GeoMugger Dashboard!'),
      ),
    );
  }
  */
}