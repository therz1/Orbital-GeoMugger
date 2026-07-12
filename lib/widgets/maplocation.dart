import 'package:flutter/material.dart' ;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice_ex/places.dart';
import 'placeSearchDelegate.dart';


class MapSelectorPage extends StatefulWidget {
  @override
  _MapSelectorPageState createState() => _MapSelectorPageState();
}

class _MapSelectorPageState extends State<MapSelectorPage> {
  final String _apikey = dotenv.env['CLOUD_API'] ?? ""; // Replace with your actual API key

  GoogleMapController? _mapController;
  LatLng? _pickedLocation;
  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location on Map'),
        actions: [
          // Search bar for locations
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final places = GoogleMapsPlaces(apiKey: _apikey);
              final Prediction? p = await showSearch<Prediction?>(
                context: context,
                delegate: PlaceSearchDelegate(places),
              );

              if (p != null){
                final detail = await GoogleMapsPlaces(apiKey: _apikey).getDetailsByPlaceId(p.placeId!);
                final lat = detail.result?.geometry?.location.lat;
                final lng = detail.result?.geometry?.location.lng;

                if (lat != null && lng != null){
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
            },
          ),
          
          //submit button to confirm the selected location
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(context, _pickedLocation),
          ),
        ],
      ),


      body: 
        GoogleMap(
          onMapCreated: (controller) => _mapController = controller,
          initialCameraPosition: const CameraPosition(
            target: LatLng(1.3521, 103.8198), // Default to Singapore
            zoom: 12,
          ),
          markers: _markers,
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