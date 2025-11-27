import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // The Map Widget
import 'package:latlong2/latlong.dart'; // For Coordinates (Latitude/Longitude)

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  // Ramu's Location (Hardcoded to a spot in Mumbai/Pune for demo)
  // You can change these numbers to your city's coordinates!
  final LatLng _ramuLocation = const LatLng(18.5204, 73.8567); // Pune, India

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tracking Ramu..."),
        backgroundColor: Colors.blue.shade100,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _ramuLocation, // Start map at Ramu
          initialZoom: 13.0, // Zoom level (City view)
        ),
        children: [
          // 1. The Map Tiles (The visual map images)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.smart_services',
          ),
          
          // 2. The Markers (The Pins)
          MarkerLayer(
            markers: [
              Marker(
                point: _ramuLocation,
                width: 80,
                height: 80,
                child: const Column(
                  children: [
                    Icon(Icons.location_on, color: Colors.red, size: 40),
                    Text("Ramu", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}