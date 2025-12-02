import 'package:flutter/material.dart';
import '../services/provider_service.dart';
import '../services/booking_service.dart';
import '../services/payment_service.dart';
import '../widgets/success_dialog.dart';
import 'provider_portfolio_screen.dart';

class ProviderListScreen extends StatefulWidget {
  final String categoryName;
  final String city; // Added City

  const ProviderListScreen({super.key, required this.categoryName, required this.city});

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final _providerService = ProviderService();
  late Future<List<dynamic>> _providersFuture;
  late PaymentService _paymentService;
  
  // Standard Pricing (Since AI is removed)
  final int _standardPrice = 499;

  @override
  void initState() {
    super.initState();
    _providersFuture = _providerService.getProvidersByRole(widget.categoryName, widget.city);
    
    _paymentService = PaymentService(
      onSuccess: (paymentId) => _handlePaymentSuccess(paymentId),
      onFailure: (error) => _handlePaymentError(error),
    );
  }

  int? _selectedWorkerId; 

  void _startPayment(int workerId) {
    setState(() => _selectedWorkerId = workerId);
    _paymentService.openCheckout(_standardPrice, "boss@agency.com", "9876543210");
  }

  void _handlePaymentSuccess(String paymentId) async {
    if (_selectedWorkerId == null) return;
    final bookingService = BookingService();
    final success = await bookingService.createBooking(_selectedWorkerId!, widget.categoryName);

    if (mounted && success) {
      showSuccessDialog(
        context,
        title: "Booking Confirmed",
        message: "Your provider has been notified.",
        onDismiss: () => Navigator.pop(context)
      );
    }
  }

  void _handlePaymentError(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("${widget.categoryName}s Nearby"), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black), titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
      body: FutureBuilder<List<dynamic>>(
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
              return _ProviderCard(
                worker: worker, 
                category: widget.categoryName,
                price: _standardPrice,
                onQuickBook: () => _startPayment(worker['id']),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final dynamic worker;
  final String category;
  final int price;
  final VoidCallback onQuickBook;

  const _ProviderCard({required this.worker, required this.category, required this.price, required this.onQuickBook});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderPortfolioScreen(
              worker: worker, 
              category: category,
              price: price, // Passing the price correctly now
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: Colors.blue.shade50, child: Text(worker['email'][0].toUpperCase(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(worker['email'].split('@')[0], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Row(children: [Icon(Icons.star, size: 14, color: Colors.amber), Text(" 4.8", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
                ],
              ),
            ),
            FilledButton(
              onPressed: onQuickBook,
              style: FilledButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text("Book ₹$price"),
            ),
          ],
        ),
      ),
    );
  }
}