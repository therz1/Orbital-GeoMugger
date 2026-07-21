import 'dart:async';
import 'package:flutter/material.dart' ;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:geolocator/geolocator.dart';
import 'placeSearchDelegate.dart';


class MapSelectorPage extends StatefulWidget {
  final maps.LatLng? initialLocation;
  const MapSelectorPage({
    super.key,
    this.initialLocation
  });
  @override
  State<MapSelectorPage> createState() => _MapSelectorPageState();
}

class _MapSelectorPageState extends State<MapSelectorPage> {
  final String _apikey = dotenv.env['CLOUD_API'] ?? ""; // Replace with your actual API key

  maps.GoogleMapController? _mapController;
  maps.LatLng? _pickedLocation;
  maps.LatLng? _currentLocation;

  Set<maps.Marker> _markers = {};
  maps.BitmapDescriptor? _currentLocationIcon;
  bool _hasPermission = false;
  
  StreamSubscription<Position>? _positionStream;
  late FlutterGooglePlacesSdk _places;

  @override
  void dispose() {
    _positionStream?.cancel(); // 3. Cancel the subscription
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _places = FlutterGooglePlacesSdk(dotenv.env['CLOUD_API']!);
    
    _pickedLocation = widget.initialLocation;
    _loadCustomMarker();
    _checkPermission();

    _positionStream = Geolocator.getPositionStream().listen((Position position) {
      if (mounted){
        setState(() {
          _currentLocation = maps.LatLng(position.latitude, position.longitude);
          _updateMarkers();
        });
      }
    });
  }

  Future<void> _loadCustomMarker() async {
    _currentLocationIcon = await maps.BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/current_location.png',
    );
    setState(() {}); // Refresh the UI after loading the custom marker
  }

  Future<void> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    
    LocationPermission permissionGranted = await Geolocator.checkPermission();

    if (permissionGranted == LocationPermission.denied) {
      permissionGranted = await Geolocator.requestPermission();
      if (permissionGranted == LocationPermission.denied) {
        return;
      }
    }

    if (permissionGranted == LocationPermission.always || permissionGranted == LocationPermission.whileInUse) {
      if (mounted){
        setState(() => _hasPermission = true);

        Position position = await Geolocator.getCurrentPosition();
        _currentLocation = maps.LatLng(position.latitude, position.longitude);
        _updateMarkers();
      }
    }
  }

  void _updateMarkers(){
    _markers = {};  

    if (_currentLocation != null){
      _markers.add(
        maps.Marker(
          markerId: const maps.MarkerId('current_location'),
          position: _currentLocation!,
          icon: _currentLocationIcon ?? maps.BitmapDescriptor.defaultMarkerWithHue(maps.BitmapDescriptor.hueBlue),
          infoWindow: const maps.InfoWindow(title: 'Current Location'),
        ),
      );
    }

    if (_pickedLocation != null){
      _markers.add(
        maps.Marker(
          markerId: const maps.MarkerId('picked_location'),
          position: _pickedLocation!,
          icon: maps.BitmapDescriptor.defaultMarkerWithHue(maps.BitmapDescriptor.hueRed),
          infoWindow: const maps.InfoWindow(title: 'Picked Location'),
        ),
      );
    }
  }

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
              //final places = GoogleMapsPlaces(apiKey: _apikey);
              final AutocompletePrediction? p = await showSearch<AutocompletePrediction?>(
                context: context,
                delegate: PlaceSearchDelegate(_places),
              );

              if (p != null){
                final detail = await _places.fetchPlace(
                  p.placeId,
                  fields: [PlaceField.Location],
                );
                final lat = detail.place?.latLng?.lat;
                final lng = detail.place?.latLng?.lng;

                // Searched Location exists - now we will move to it.
                if (lat != null && lng != null){
                  setState(() {
                    _pickedLocation = maps.LatLng(lat, lng);
                    _updateMarkers();
                  });

                  _mapController?.animateCamera(
                    maps.CameraUpdate.newLatLng(_pickedLocation!)
                  );
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
        maps.GoogleMap(
          // key forces refresh when permission changes
          key: ValueKey(_hasPermission),
          onMapCreated: (controller) => _mapController = controller,
          initialCameraPosition: const maps.CameraPosition(
            target: maps.LatLng(1.3521, 103.8198), // Default to Singapore
            zoom: 12,
          ),
          myLocationEnabled: _hasPermission,
          myLocationButtonEnabled: _hasPermission,

          markers: _markers,
          onTap: (pos) {
            setState(() {
              _pickedLocation = pos;
              _updateMarkers();
            });
             _mapController?.animateCamera(maps.CameraUpdate.newLatLng(_pickedLocation!));
          },
        ),
    );
  }
}