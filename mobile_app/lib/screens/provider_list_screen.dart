import 'package:flutter/material.dart';
import '../services/provider_service.dart';
import 'provider_portfolio_screen.dart'; // We will create this next


class ProviderListScreen extends StatefulWidget {
  final String categoryName;
  final String city; // NEW

  const ProviderListScreen({super.key, required this.categoryName, required this.city});
  

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {

  final _providerService = ProviderService();
  late Future<List<dynamic>> _providersFuture;

  @override
  void initState() {
    super.initState();
    _providersFuture = _providerService.getProvidersByRole(widget.categoryName, widget.city);
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("${widget.categoryName}s Nearby", style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          
          // Provider List
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _providersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                
                final providers = snapshot.data ?? [];
                if (providers.isEmpty) return const Center(child: Text("No providers found nearby."));

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: providers.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final worker = providers[index];
                    return _ProviderCard(worker: worker, category: widget.categoryName);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final dynamic worker;
  final String category;

  const _ProviderCard({required this.worker, required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Go to Portfolio Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderPortfolioScreen(worker: worker, category: category),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Profile Pic (Simulated with Initials)
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.black12,
              child: Text(worker['email'][0].toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54)),
            ),
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(worker['email'].toString().split('@')[0], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      Text(" 4.8 (Verified)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      Text(" 2.5 km away", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}