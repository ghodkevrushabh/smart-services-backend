import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'provider_list_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> service;
  final String userCity;

  const ServiceDetailScreen({
    super.key, 
    required this.service, 
    required this.userCity
  });

  @override
  Widget build(BuildContext context) {
    // Mock Portfolio Images
    final List<String> portfolio = [
      "https://images.unsplash.com/photo-1581578731117-10d75d5ce3a2?auto=format&fit=crop&w=400&q=80",
      "https://images.unsplash.com/photo-1621905476017-17bf88cdad4d?auto=format&fit=crop&w=400&q=80",
      "https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?auto=format&fit=crop&w=400&q=80",
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. Big Hero Image Header (Now using Local Asset)
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: service['color'],
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    service['name'], 
                    style: GoogleFonts.poppins(
                      color: Colors.black87, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                  centerTitle: true,
                  background: Hero(
                    tag: service['name'],
                    child: Container(
                      color: service['color'],
                      padding: const EdgeInsets.all(40),
                      child: Image.asset(
                        service['path'],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Description & Portfolio
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price & Rating Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Starts at", 
                                style: TextStyle(color: Colors.grey[600], fontSize: 14)
                              ),
                              // --- UPDATED DYNAMIC PRICE LOGIC ---
                              Text(
                                service['price'] == 0 ? "Free Estimate" : "₹${service['price']}", 
                                style: TextStyle(
                                  color: service['dark'], 
                                  fontSize: 24, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              // -----------------------------------
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.star, color: Colors.orange, size: 20),
                                SizedBox(width: 4),
                                Text("4.8", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(" (120)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 30),
                      const Divider(),
                      const SizedBox(height: 30),

                      Text("About this Service", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(
                        "Premium quality ${service['name']} services delivered by verified professionals in $userCity. We ensure safety protocols, transparent pricing, and on-time completion.",
                        style: GoogleFonts.poppins(fontSize: 15, height: 1.6, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 30),
                      
                      Text("Recent Work", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: portfolio.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 160,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(portfolio[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ).animate().fadeIn(delay: (100 * index).ms).slideX();
                          },
                        ),
                      ),
                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3. Sticky Bottom Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProviderListScreen(
                        categoryName: service['name'],
                        city: userCity,
                      )),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text("Find Providers", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}