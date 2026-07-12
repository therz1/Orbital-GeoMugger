import 'package:flutter/material.dart';
import 'package:google_maps_webservice_ex/places.dart'; // Ensure you use the updated package

// This class is what showSearch expects
class PlaceSearchDelegate extends SearchDelegate<Prediction?> {
  final GoogleMapsPlaces _places;

  PlaceSearchDelegate(this._places);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = "")];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) {
    // Your logic to call _places.autocomplete(query)
    // and return a ListView of suggestions goes here
    return FutureBuilder<PlacesAutocompleteResponse>(
      future: _places.autocomplete(query, components: [Component(Component.country, "sg")]),
      builder: (context, snapshot){
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: snapshot.data!.predictions.length,
          itemBuilder: (context, index) {
            final prediction = snapshot.data!.predictions[index];
            return ListTile(
              title: Text(prediction.description ?? ""),
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