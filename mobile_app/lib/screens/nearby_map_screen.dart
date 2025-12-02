import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math'; // To scatter markers randomly
import '../services/provider_service.dart';
import '../services/location_service.dart';
import 'provider_portfolio_screen.dart';

class NearbyMapScreen extends StatefulWidget {
  const NearbyMapScreen({super.key});

  @override
  State<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends State<NearbyMapScreen> {
  LatLng? _myLocation;
  List<dynamic> _providers = [];
  bool _isLoading = true;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    // 1. Get User Location
    final locationService = LocationService();
    final locData = await locationService.getCurrentLocation();
    
    // SAFETY CHECK: If user left the screen, stop here.
    if (!mounted) return; 

    if (locData['lat'] != null) {
      setState(() {
        _myLocation = LatLng(
          double.parse(locData['lat']!), 
          double.parse(locData['lng']!)
        );
      });

      // 2. Get Workers in this City
      final providerService = ProviderService();
      final plumbers = await providerService.getProvidersByRole('Plumber', locData['city']!);
      final electricians = await providerService.getProvidersByRole('Electrician', locData['city']!);
      
      // SAFETY CHECK AGAIN (Because await took time)
      if (!mounted) return;

      setState(() {
        _providers = [...plumbers, ...electricians];
        _isLoading = false;
      });
    }
  }

  // Helper to create a random offset so markers don't stack on top of each other
  LatLng _getRandomOffset(LatLng center) {
    final random = Random();
    // Move roughly 0-500 meters away
    double latOffset = (random.nextDouble() - 0.5) * 0.01; 
    double lngOffset = (random.nextDouble() - 0.5) * 0.01;
    return LatLng(center.latitude + latOffset, center.longitude + lngOffset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Pros"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      body: _isLoading || _myLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _myLocation!,
                initialZoom: 14.0,
              ),
              children: [
                // 1. The Map Layer
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.smart_services',
                ),

                // 2. The Markers Layer
                MarkerLayer(
                  markers: [
                    // MY LOCATION (Blue Dot)
                    Marker(
                      point: _myLocation!,
                      width: 60,
                      height: 60,
                      child: const Column(
                        children: [
                          Icon(Icons.my_location, color: Colors.blue, size: 30),
                          Text("You", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                        ],
                      ),
                    ),

                    // WORKER MARKERS
                    ..._providers.map((worker) {
                      // Assign a "fake" nearby location for the demo
                      final workerLoc = _getRandomOffset(_myLocation!);
                      
                      return Marker(
                        point: workerLoc,
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () {
                            // Show Bottom Sheet on Click
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => _WorkerPreviewCard(worker: worker),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Center(
                              child: Text(
                                worker['email'][0].toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.center_focus_strong, color: Colors.white),
        onPressed: () {
          if (_myLocation != null) {
            _mapController.move(_myLocation!, 14.0);
          }
        },
      ),
    );
  }
}

// A Small Card that pops up when you click a Map Pin
class _WorkerPreviewCard extends StatelessWidget {
  final dynamic worker;
  const _WorkerPreviewCard({required this.worker});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade100,
                  child: Text(worker['email'][0].toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(worker['email'].split('@')[0], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text("Verified Pro", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const Column(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    Text("4.8", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context); // Close popup
                  // Go to full profile
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProviderPortfolioScreen(
                        worker: worker, 
                        category: "General", // Defaulting for map view
                        price: 500, 
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 15)),
                child: const Text("View Profile & Book"),
              ),
            )
          ],
        ),
      ),
    );
  }
}