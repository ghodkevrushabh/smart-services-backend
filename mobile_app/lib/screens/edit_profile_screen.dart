import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart'; // For Pro Permissions
import '../services/booking_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final _expController = TextEditingController();

  // State
  String? _role;
  String? _email;
  String? _profilePicBase64;
  bool _isLoading = true;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>(); // For Validation

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // --- 1. ROBUST DATA FETCHING ---
  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('user_role');
      final service = BookingService();
      final userData = await service.getUserProfile();

      if (mounted) {
        setState(() {
          _role = role;
          _isLoading = false;
          if (userData != null) {
            _email = userData['email'];
            _nameController.text = userData['full_name'] ?? "";
            _cityController.text = userData['city'] ?? "";
            _bioController.text = userData['bio'] ?? "";
            _expController.text = (userData['experience_years'] ?? "").toString();
            _profilePicBase64 = userData['profile_pic'];
          }
        });
      }
    } catch (e) {
      _showSnack("Failed to load profile: $e", isError: true);
      setState(() => _isLoading = false);
    }
  }

  // --- 2. ADVANCED IMAGE HANDLING ---
  
  Future<void> _initiateImagePick(ImageSource source) async {
    // A. Check Permissions First (Crucial for Android 13+)
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      // Android 13+ uses photos permission, older uses storage
      if (Platform.isAndroid) {
         // Simple check logic for modern android
         status = await Permission.photos.request();
         if(status.isPermanentlyDenied || status.isDenied) {
            // Fallback for older android or specific configs
             status = await Permission.storage.request();
         }
      } else {
        status = await Permission.photos.request();
      }
    }

    if (status.isGranted || status.isLimited) {
      _pickAndCropImage(source);
    } else {
      _showSnack("Permission denied. Please enable in settings.", isError: true);
      openAppSettings();
    }
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      // Pick with compression (50%) to avoid payload errors
      final XFile? pickedFile = await picker.pickImage(source: source, imageQuality: 50);

      if (pickedFile != null) {
        _cropImage(pickedFile.path);
      }
    } catch (e) {
      _showSnack("Error picking image: $e", isError: true);
    }
  }

  Future<void> _cropImage(String path) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        // Professional UI Settings for Cropper
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Adjust Profile Picture',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true, // Profile pics must be square
            hideBottomControls: false,
            activeControlsWidgetColor: Colors.blue,
          ),
          IOSUiSettings(title: 'Adjust Profile Picture'),
        ],
      );

      if (croppedFile != null) {
        final bytes = await File(croppedFile.path).readAsBytes();
        // Validate Size (Max 2MB to be safe)
        if (bytes.lengthInBytes > 2 * 1024 * 1024) {
           _showSnack("Image too large. Please choose a smaller one.", isError: true);
           return;
        }
        
        final String base64String = base64Encode(bytes);
        setState(() {
          _profilePicBase64 = "data:image/jpeg;base64,$base64String";
        });
      }
    } catch (e) {
      _showSnack("Cropping cancelled or failed", isError: true);
    }
  }

  void _deleteImage() {
    setState(() {
      _profilePicBase64 = null;
    });
    Navigator.pop(context); // Close modal
  }

  // --- 3. UI HELPERS ---

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Change Profile Photo", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: Text("Take a Photo", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                onTap: () { Navigator.pop(ctx); _initiateImagePick(ImageSource.camera); },
              ),
              ListTile(
                leading: Container(
                   padding: const EdgeInsets.all(10),
                   decoration: BoxDecoration(color: Colors.purple.shade50, shape: BoxShape.circle),
                   child: const Icon(Icons.photo_library, color: Colors.purple)
                ),
                title: Text("Choose from Gallery", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                onTap: () { Navigator.pop(ctx); _initiateImagePick(ImageSource.gallery); },
              ),
              if (_profilePicBase64 != null)
                ListTile(
                  leading: Container(
                     padding: const EdgeInsets.all(10),
                     decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                     child: const Icon(Icons.delete, color: Colors.red)
                  ),
                  title: Text("Remove Photo", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.red)),
                  onTap: _deleteImage,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- 4. SAVE LOGIC ---
  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    Map<String, dynamic> updateData = {
      'full_name': _nameController.text.trim(),
      'city': _cityController.text.trim(),
      'profile_pic': _profilePicBase64,
    };

    if (_role == 'WORKER') {
      updateData['bio'] = _bioController.text.trim();
      updateData['experience_years'] = int.tryParse(_expController.text) ?? 0;
    }

    final service = BookingService();
    final success = await service.updateProfile(updateData);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        _showSnack("Profile Saved Successfully!");
        Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
      } else {
        _showSnack("Failed to save. Check your connection.", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.black)));
    
    bool isWorker = _role == 'WORKER';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit Profile", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PROFILE AVATAR
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130, height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200, width: 4),
                        image: _profilePicBase64 != null
                          ? DecorationImage(
                              image: MemoryImage(base64Decode(_profilePicBase64!.split(',').last)),
                              fit: BoxFit.cover)
                          : null,
                        color: Colors.grey.shade100
                      ),
                      child: _profilePicBase64 == null 
                          ? Icon(Icons.person_rounded, size: 60, color: Colors.grey.shade400) 
                          : null,
                    ),
                    Positioned(
                      bottom: 0, right: 4,
                      child: GestureDetector(
                        onTap: _showImagePickerModal,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)]
                          ),
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              Center(child: Text(_email ?? "user@email.com", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14))),
              const SizedBox(height: 30),

              // FIELDS
              Text("Personal Info", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              _buildTextField("Full Name", _nameController, Icons.person_outline),
              const SizedBox(height: 15),
              _buildTextField("City", _cityController, Icons.location_city),

              if (isWorker) ...[
                const SizedBox(height: 30),
                Text("Professional Info", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildTextField("Years of Experience", _expController, Icons.work_history_outlined, isNumber: true),
                const SizedBox(height: 15),
                _buildTextField("Bio / Agency Description", _bioController, Icons.description_outlined, maxLines: 3),
              ],

              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSaving 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : Text("Save Changes", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20), // Safe area
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      validator: (value) => value == null || value.isEmpty ? "$label is required" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade600),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}