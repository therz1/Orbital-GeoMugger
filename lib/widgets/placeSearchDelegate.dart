import 'package:flutter/material.dart';
// import 'package:google_maps_webservice_ex/places.dart'; // Ensure you use the updated package
import 'package:google_places_sdk_plus/google_places_sdk_plus.dart';

// This class is what showSearch expects
class PlaceSearchDelegate extends SearchDelegate<AutocompletePrediction?> {
  final FlutterGooglePlacesSdk _places;

  PlaceSearchDelegate(this._places);

  @override
  List<Widget>? buildActions(BuildContext context) {
    // Defines the icon on the right side of the search bar
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = "",
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // Defines the icon on the left side (usually a back button)
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // This is shown when the user hits the "Enter/Search" button.
    // For a simple selector, you can just return an empty container or 
    // re-run the suggestions logic.
    return buildSuggestions(context);
  }
  @override
  Widget buildSuggestions(BuildContext context) {
    // Calls _places.autocomplete(query) and return a ListView of suggestions goes here
    
    // 1. Avoid spamming API for empty queries
    if (query.isEmpty){
      return const Center(child: Text("Enter Location"));
    }
    
    return FutureBuilder<FindAutocompletePredictionsResponse>(
      future: _places.findAutocompletePredictions(
        query, 
        countries: ['sg']
      ),
      
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return const Center(child: Text("Error fetching suggestions"));
        }
        
        if (!snapshot.hasData || snapshot.data!.predictions.isEmpty){
          return const Center(child: Text("No results found"));
        }

        final predictions = snapshot.data!.predictions;
        return ListView.builder(
          itemCount: snapshot.data!.predictions.length,
          itemBuilder: (context, index) {
            final prediction = predictions[index];
            return ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(prediction.fullText ?? ''),
              onTap: () {
                close(context, prediction);
              },
            );
          },
        );
      },
    );
  }
}

/*
This widget exists purely to satisfy the type requirements of showSearch, 
which expects a SearchDelegate. The actual search logic is implemented in 
the buildSuggestions method
*/