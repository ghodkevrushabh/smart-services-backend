import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';
import 'login_screen.dart';
import 'provider_list_screen.dart';
import 'my_bookings_screen.dart';
import 'edit_profile_screen.dart';
import 'nearby_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.75);
  int _currentPage = 0;
  int _selectedIndex = 0;
  
  String _currentAddress = "Locating...";
  String _currentCity = "Unknown";

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final locationService = LocationService();
    final locationData = await locationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _currentAddress = locationData['address']!;
        _currentCity = locationData['city']!;
      });
    }
  }

  // --- SMART PRICING DATA ---
  final List<Map<String, dynamic>> services = [
    {
      "name": "Plumber", 
      "path": "assets/images/plumber.jpeg", 
      "color": const Color(0xFFE3F2FD), "dark": Colors.blue,
      "price": 49, "label": "Visiting Charge"
    },
    {
      "name": "Electrician", 
      "path": "assets/images/electrician.jpg", 
      "color": const Color(0xFFFFF8E1), "dark": Colors.orange,
      "price": 49, "label": "Visiting Charge"
    },
    {
      "name": "AC Repair", 
      "path": "assets/images/ac_repair.jpeg", 
      "color": const Color(0xFFE0F7FA), "dark": Colors.cyan,
      "price": 99, "label": "Inspection Fee"
    },
    {
      "name": "Cleaning", 
      "path": "assets/images/cleaning.jpg", 
      "color": const Color(0xFFF3E5F5), "dark": Colors.purple,
      "price": 199, "label": "1 BHK Cleaning"
    },
    {
      "name": "Maid", 
      "path": "assets/images/maid.avif", 
      "color": const Color(0xFFFCE4EC), "dark": Colors.pink,
      "price": 0, "label": "Free Consultation"
    },
    {
      "name": "Painter", 
      "path": "assets/images/painter.jpg", 
      "color": const Color(0xFFE8F5E9), "dark": Colors.green,
      "price": 0, "label": "Free Estimate"
    },
  ];

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  void _onTabChange(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) { 
      Navigator.push(context, MaterialPageRoute(builder: (ctx) => const NearbyMapScreen()));
    } else if (index == 2) { 
      Navigator.push(context, MaterialPageRoute(builder: (ctx) => const MyBookingsScreen()));
    } else if (index == 3) { 
      Navigator.push(context, MaterialPageRoute(builder: (ctx) => const EditProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Current Location", style: TextStyle(color: Colors.grey, fontSize: 12)),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Text(_currentAddress, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _logout(context),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "What service do\nyou need today?",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(),

            const SizedBox(height: 30),

            // 3D CAROUSEL
            SizedBox(
              height: 420, 
              child: PageView.builder(
                controller: _pageController,
                itemCount: services.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  double scale = _currentPage == index ? 1.0 : 0.85;
                  return TweenAnimationBuilder(
                    tween: Tween(begin: scale, end: scale),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    builder: (context, double value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: _Service3DCard(
                      service: services[index],
                      userCity: _currentCity,
                    ),
                  );
                },
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            
            const SizedBox(height: 50),
          ],
        ),
      ),

      // BOTTOM NAV
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.grey[500],
              tabs: const [
                GButton(icon: LineIcons.home, text: 'Home'),
                GButton(icon: LineIcons.mapMarker, text: 'Nearby'),
                GButton(icon: LineIcons.calendar, text: 'Bookings'),
                GButton(icon: LineIcons.user, text: 'Profile'),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: _onTabChange,
            ),
          ),
        ),
      ),
    );
  }
}

class _Service3DCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final String userCity;

  const _Service3DCard({required this.service, required this.userCity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProviderListScreen(
            categoryName: service['name'],
            city: userCity,
            bookingFee: service['price'] ?? 0, // PASSING THE FEE
          )),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 30),
        decoration: BoxDecoration(
          color: service['color'],
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: (service['dark'] as Color).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30, top: -30,
              child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.3)),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service['name'], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  // DYNAMIC LABEL ("Visiting Charge" or "Free Estimate")
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      service['label'] ?? "View Experts", 
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: service['dark'])
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20, right: 10, left: 10, top: 80,
              child: Hero(
                tag: service['name'],
                child: Image.asset(
                  service['path'],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Positioned(
              bottom: 24, right: 24,
              child: CircleAvatar(backgroundColor: Colors.black, radius: 28, child: const Icon(Icons.arrow_forward, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}