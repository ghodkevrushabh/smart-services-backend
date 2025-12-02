import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../services/payment_service.dart';
import '../widgets/success_dialog.dart';
import 'chat_screen.dart'; // Import Chat

class ProviderPortfolioScreen extends StatefulWidget {
  final dynamic worker;
  final String category;
  final int price;

  const ProviderPortfolioScreen({
    super.key, 
    required this.worker, 
    required this.category,
    required this.price,
  });

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
      showSuccessDialog(context, onDismiss: () => Navigator.pop(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Provider Profile"), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.grey.shade50,
              child: Row(
                children: [
                  CircleAvatar(radius: 40, backgroundColor: Colors.black12, child: Text(widget.worker['email'][0].toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.worker['email'].split('@')[0], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const Text("Verified Pro", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // About
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text("Contact this provider to discuss your ${widget.category} needs.", style: const TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
      // COMMUNICATION BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            // Chat Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => ChatScreen(
                      otherUserId: widget.worker['id'], 
                      otherUserName: widget.worker['email'].split('@')[0]
                    ))
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text("Chat"),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
              ),
            ),
            const SizedBox(width: 10),
            // Book Button
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _paymentService.openCheckout(widget.price, "user@test.com", "9876543210"),
                icon: const Icon(Icons.check),
                label: const Text("Book"),
                style: FilledButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}