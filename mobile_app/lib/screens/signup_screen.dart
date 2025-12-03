import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _isLocating = true; // Track if we are finding location
  
  String _selectedRole = 'CUSTOMER'; 
  String? _selectedCategory;
  String? _detectedCity; // Will store "Pune", "Majalgaon", etc.

  final List<String> _serviceTypes = [
    "Plumber", "Electrician", "AC Repair", "Cleaning", "Maid", "Painter"
  ];

  @override
  void initState() {
    super.initState();
    _detectLocation(); // Start GPS immediately
  }

  // 1. DYNAMIC GPS DETECTION
  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    
    final loc = await LocationService().getCurrentLocation();
    
    if (mounted) {
      setState(() {
        _detectedCity = loc['city']; // e.g. "Majalgaon"
        _isLocating = false;
      });
      print("📍 GPS DETECTED CITY: $_detectedCity");
    }
  }

  void _handleSignUp() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      _showSnack("Please fill all fields", isError: true);
      return;
    }

    if (_selectedRole == 'WORKER' && _selectedCategory == null) {
      _showSnack("Please select your Service Category", isError: true);
      return;
    }

    // STRICT CHECK: Do not allow signup if location failed
    if (_detectedCity == null || _detectedCity == "Unknown") {
      _showSnack("Location not found. Please enable GPS.", isError: true);
      _detectLocation(); // Try again
      return;
    }

    setState(() => _isLoading = true);
    
    // 2. REGISTER WITH REAL GPS CITY
    final success = await _authService.register(
      _emailController.text.trim(), 
      _passController.text.trim(),
      _selectedRole,
      _selectedRole == 'WORKER' ? _selectedCategory! : "",
      _detectedCity! // <--- Sends "Majalgaon" (or wherever you are)
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      _showSnack("Account Created! You are listed in $_detectedCity.", isError: false);
      Navigator.pop(context);
    } else if (mounted) {
      _showSnack("Registration Failed.", isError: true);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Create Account", style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              // 3. SHOW DETECTED LOCATION (Proof it works)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  _isLocating 
                    ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text("Signing up from: ${_detectedCity ?? 'Unknown'}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              ),
              
              const SizedBox(height: 30),

              // ROLE SELECTOR
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    _RoleButton("Customer", "CUSTOMER"),
                    _RoleButton("Service Provider", "WORKER"),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // INPUTS
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email Address", prefixIcon: Icon(Icons.email_outlined))),
              const SizedBox(height: 20),
              TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline))),

              // WORKER CATEGORY
              if (_selectedRole == 'WORKER') ...[
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "What do you do?",
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  value: _selectedCategory,
                  items: _serviceTypes.map((String type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
              ],

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.black),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Sign Up"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _RoleButton(String label, String value) {
    bool isSelected = _selectedRole == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)] : [],
          ),
          child: Center(child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.grey))),
        ),
      ),
    );
  }
}