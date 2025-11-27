import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'worker_home_screen.dart'; // Import the worker screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 1. Wait for 1.5 seconds (so the user sees the logo)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // 2. Check phone storage for the ID Card
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    // 3. Decide where to go
    if (token != null && token.isNotEmpty) {
      // User is logged in. Now, ARE THEY A WORKER OR CUSTOMER?
      final role = prefs.getString('user_role');
      
      if (role == 'WORKER') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WorkerHomeScreen()),
        );
      } else {
        // Default to Customer Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      // User is new/logged out -> Go to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "Smart Services",
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: Colors.white
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}