import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geo_mugger/widgets/tag_filter.dart';
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: LocationSearchBar(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                  IconButton(icon: Badge(
                    isLabelVisible: _selectedTags.isNotEmpty,
                    label: Text(_selectedTags.length.toString()),
                    child: const Icon(Icons.filter_list, size: 28),
                  ),
                  onPressed: () async {
                    final List<String>? updatedFilter = await showDialog<List<String>>(
                      context: context,
                      builder: (context) => TagFilter(tagMap: _tagMap, initialSelectedTags: _selectedTags, ),
                    );
                    if (updatedFilter != null) {
                      setState(() {
                        _selectedTags.clear();
                        _selectedTags.addAll(updatedFilter);
                      });
                    }
                  },
                  ),
                ],
              ),
            ),
            if (_selectedTags.isNotEmpty) 
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _selectedTags.map((filterName) {
                  return Padding(
                    padding:const EdgeInsets.only(right: 6.0) ,
                    child: InputChip(label: Text(filterName, style: const TextStyle(fontSize: 11)),
                    onDeleted: () {
                      setState(() => _selectedTags.remove(filterName));
                    },
                    ),
                  );
                }).toList(),
              ),
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
                    
                    final bool matchesText = locationName.contains(_searchQuery);
                    bool matchesTags = true; 
                    if(_selectedTags.isNotEmpty) {
                      final Map<String,dynamic> allTagsMap = data['allTags'] != null
                      ? Map<String, dynamic>.from(data['allTags'] as Map) : {};
                      matchesTags = _selectedTags.every((filterTag) => allTagsMap.containsKey(filterTag));
                    }
                      // Default to true if no tags are selecte
                    return matchesText && matchesTags;
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
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            isThreeLine: topTags.isNotEmpty,
                            leading: CircleAvatar(
                              backgroundColor: Colors.brown,
                              child: const Icon(Icons.location_on, color: Colors.orange),
                            ),
                            title: Text(locationName),
                            //subtitle: Text(review),
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
            ),
          ), // End of Expanded
        ], // End of Column children
      ), // End of Column body
    );
  }
}
