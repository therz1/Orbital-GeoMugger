import 'package:flutter/material.dart' ;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice_ex/places.dart';
import 'package:geolocator/geolocator.dart';
import 'placeSearchDelegate.dart';


class MapSelectorPage extends StatefulWidget {
  final LatLng? initialLocation;
  const MapSelectorPage({
    super.key,
    this.initialLocation
  });
  @override
  State<MapSelectorPage> createState() => _MapSelectorPageState();
}

class _MapSelectorPageState extends State<MapSelectorPage> {
  final String _apikey = dotenv.env['CLOUD_API'] ?? ""; // Replace with your actual API key

  GoogleMapController? _mapController;
  LatLng? _pickedLocation;
  LatLng? _currentLocation;

  Set<Marker> _markers = {};
  BitmapDescriptor? _currentLocationIcon;
  bool _hasPermission = false;
  
  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
    _loadCustomMarker();
    _checkPermission();

    Geolocator.getPositionStream().listen((Position position) {
      if (mounted){
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _updateMarkers();
        });
      }
    });
  }

  Future<void> _loadCustomMarker() async {
    _currentLocationIcon = await BitmapDescriptor.asset(
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
        _currentLocation = LatLng(position.latitude, position.longitude);
        _updateMarkers();
      }
    }
  }

  void _updateMarkers(){
    _markers = {};  

    if (_currentLocation != null){
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          icon: _currentLocationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      );
    }

    if (_pickedLocation != null){
      _markers.add(
        Marker(
          markerId: const MarkerId('picked_location'),
          position: _pickedLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Picked Location'),
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
                    _updateMarkers();
                  });
                  if (_mapController != null){
                    _mapController?.animateCamera(CameraUpdate.newLatLng(_pickedLocation!));
                  }
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
          // key forces refresh when permission changes
          key: ValueKey(_hasPermission),
          onMapCreated: (controller) => _mapController = controller,
          initialCameraPosition: const CameraPosition(
            target: LatLng(1.3521, 103.8198), // Default to Singapore
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
             _mapController?.animateCamera(CameraUpdate.newLatLng(_pickedLocation!));
          },
        ),
    );
  }
}