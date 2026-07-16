import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' ;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DestinationPage extends StatefulWidget {
  final LatLng? destination;
  const DestinationPage({
    super.key,
    this.destination
  });
  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage>{
  @override
  void initState(){
    super.initState();
    _navigation();
  }

  Future<void> _navigation() async {
    if (widget.destination == null) return;
    final double lat = widget.destination!.latitude;
    final double lng = widget.destination!.longitude;

    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${lat},${lng}&travelmode=driving'
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      debugPrint("Counld not launch.");
    }
  }

  @override
  Widget build(BuildContext context){
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}