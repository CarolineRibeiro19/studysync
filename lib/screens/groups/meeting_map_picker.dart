import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class MeetingMapPicker extends StatefulWidget {
  final LatLng? initialLocation;

  const MeetingMapPicker({super.key, this.initialLocation});

  @override
  State<MeetingMapPicker> createState() => _MeetingMapPickerState();
}

class _MeetingMapPickerState extends State<MeetingMapPicker> {
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Localização'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop(_selectedLocation);
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _selectedLocation ?? const LatLng(40.6405, -8.6538), // Default to Aveiro, Portugal
          initialZoom: 13.0,
          onTap: (tapPosition, latLng) {
            setState(() {
              _selectedLocation = latLng;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // Standard OpenStreetMap
            userAgentPackageName: 'com.example.studysync', // Replace with your package name
          ),
          if (_selectedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedLocation!,
                  width: 80,
                  height: 80,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}