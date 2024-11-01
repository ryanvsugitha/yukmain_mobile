import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

class AdminSelectLocation extends StatefulWidget {
  const AdminSelectLocation({super.key});

  @override
  State<AdminSelectLocation> createState() => _AdminSelectLocationState();
}

class _AdminSelectLocationState extends State<AdminSelectLocation> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        centerTitle: true,
      ),
      body: FlutterLocationPicker(
        markerIcon: const Icon(Icons.location_pin, color: Colors.red, size: 40,),
        selectedLocationButtonTextstyle: const TextStyle(fontSize: 18),
        selectLocationButtonText: 'Set Venue Location',
        initZoom: 11,
        minZoomLevel: 5,
        maxZoomLevel: 18,
        trackMyPosition: true,
        onPicked: (pickedData) {
          List latLong = [pickedData.latLong.latitude, pickedData.latLong.longitude];
          Navigator.pop(context, latLong);
        },
      )
    );
  }
}