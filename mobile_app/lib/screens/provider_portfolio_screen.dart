import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../services/payment_service.dart';
import '../widgets/success_dialog.dart';

class ProviderPortfolioScreen extends StatefulWidget {
  final dynamic worker;
  final String category;

  const ProviderPortfolioScreen({super.key, required this.worker, required this.category});

  @override
  State<ProviderPortfolioScreen> createState() => _ProviderPortfolioScreenState();
}

class _ProviderPortfolioScreenState extends State<ProviderPortfolioScreen> {
  late PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(
      onSuccess: (pid) => _handleBooking(),
      onFailure: (err) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err))),
    );
  }

  void _handleBooking() async {
    final bookingService = BookingService();
    final success = await bookingService.createBooking(widget.worker['id'], widget.category);
    
    if (mounted && success) {
      showSuccessDialog(context); // Uses your local Lottie file
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Provider Profile"), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black), titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.grey.shade50,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.black12,
                    child: Text(widget.worker['email'][0].toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.worker['email'].toString().split('@')[0], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const Text("Professional Agency", style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        const Row(children: [Icon(Icons.star, color: Colors.amber, size: 18), Text(" 4.8 Rating")]),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // 2. About
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("About", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("We are a verified agency providing ${widget.category} services in Mumbai for over 5 years. We ensure safety, hygiene, and on-time completion.", style: const TextStyle(color: Colors.black54, height: 1.5)),
                  
                  const SizedBox(height: 30),
                  
                  // 3. Portfolio Gallery
                  const Text("Recent Work (Portfolio)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _portfolioImage(Colors.grey.shade300),
                        _portfolioImage(Colors.grey.shade400),
                        _portfolioImage(Colors.grey.shade300),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => _paymentService.openCheckout(500, "user@test.com", "9876543210"),
            child: const Text("Book Now • ₹500", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _portfolioImage(Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: const Center(child: Icon(Icons.image, color: Colors.white)),
    );
  }
}