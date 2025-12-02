import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // Uncomment when you add Firebase back
  await Supabase.initialize(
    url: 'https://ihabmygciwqeibkryjkc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImloYWJteWdjaXdxZWlia3J5amtjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5MTkxNTcsImV4cCI6MjA3OTQ5NTE1N30.-riNF8QZfr18pX3bYAhcaBy1AYqlTGnFRReZhgMUIyw', // You must paste your real key here!
  );
  // For now, we just run the app
  runApp(const ProviderScope(child: SmartServicesApp()));
}

class SmartServicesApp extends StatelessWidget {
  const SmartServicesApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Define the Base Color (Google-like Indigo/Blue)
    const seedColor = Color(0xFF4F46E5); 

    return MaterialApp(
      title: 'Smart Services',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        
        // 2. GLOBAL COLOR SCHEME
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          background: Colors.white,
          surface: Colors.white,
        ),

        // 3. GLOBAL TEXT THEME (The "Bold & Fade" Rule)
        textTheme: TextTheme(
          // Big Headers (Bold & Dark)
          headlineMedium: GoogleFonts.poppins(
            fontSize: 28, 
            fontWeight: FontWeight.w700, // Bold
            color: const Color(0xFF111827), // Almost Black
            letterSpacing: -0.5,
          ),
          headlineSmall: GoogleFonts.poppins(
            fontSize: 24, 
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
          // Subtitles (Faded & Smaller)
          bodyLarge: GoogleFonts.poppins(
            fontSize: 16, 
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280), // Cool Grey
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 14, 
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
          ),
          // Button Text
          labelLarge: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600, // Semi-Bold
            color: Colors.white,
          ),
        ),

        // 4. GLOBAL BUTTON THEME (Consistent Shape & Color)
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: seedColor, // Always use the brand color
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0, // Flat is modern
          ),
        ),

        // 5. GLOBAL INPUT THEME
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF3F4F6), // Light Grey background
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // No lines usually
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: seedColor, width: 2),
          ),
          labelStyle: GoogleFonts.poppins(color: const Color(0xFF6B7280)),
          prefixIconColor: const Color(0xFF6B7280),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}