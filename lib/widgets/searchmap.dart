import 'package:flutter/material.dart' ;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_webservice_ex/places.dart';

class SearchMapPage extends SearchDelegate<Prediction?> {
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: dotenv.env['CLOUD_API'] ?? "");

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // You can implement the logic to show search results here.
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty)  {
      return const Center(
        child: Text('No suggestions available.'),
      );
    }

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