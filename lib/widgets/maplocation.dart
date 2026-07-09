import 'package:flutter/material.dart' ;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class MapSelectorPage extends StatefulWidget {
  @override
  _MapSelectorPageState createState() => _MapSelectorPageState();
}

class _MapSelectorPageState extends State<MapSelectorPage> {
  final String _apikey = dotenv.env['CLOUD_API'] ?? ""; // Replace with your actual API key

  GoogleMapController? _mapController;
  LatLng? _pickedLocation;
  Set<Marker> _markers = {};

  /*
  @override
  
  Future<void> _handleSearch() async {
    Prediction? p = await GooglePlacesAutocomplete.show(
      context: context,
      apikey: _apikey,
      mode: Mode.overlay,
      language: "en",
      components: [Component(Component.country, "sg")],
    );

    if (p != null){
      GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: _apikey);
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      setState(() {
        _pickedLocation = LatLng(lat, lng);
        _markers = {
          Marker(
            markerId: const MarkerId('picked_location'),
            position: _pickedLocation!,
          ),
        };
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(_pickedLocation!));
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location on Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(context, _pickedLocation),
          ),
        ],
      ),


      body: 
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(1.3521, 103.8198), // Default to Singapore
            zoom: 12,
          ),
          onTap: (pos) {
            setState(() {
              _pickedLocation = pos;
              _markers = {                          
                Marker(
                  markerId: const MarkerId('picked_location'),
                  position: pos,
                ),              
              };
            });
          },
        ),
    );
  }
}