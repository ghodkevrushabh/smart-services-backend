import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/provider_service.dart';
import '../services/booking_service.dart';
import '../services/payment_service.dart';
import '../widgets/success_dialog.dart';
import 'provider_portfolio_screen.dart';

class ProviderListScreen extends StatefulWidget {
  final String categoryName;
  // REMOVED: final String city; (No longer needed, we use GPS)
  final int bookingFee; 

  const ProviderListScreen({
    super.key, 
    required this.categoryName, 
    // REMOVED: required this.city,
    required this.bookingFee 
  });

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final _providerService = ProviderService();
  late Future<List<dynamic>> _providersFuture;
  late PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    // UPDATED: Now we only pass the Category. 
    // The Service handles GPS location automatically.
    _providersFuture = _providerService.getProvidersByRole(widget.categoryName);
    
    _paymentService = PaymentService(
      onSuccess: (pid) => _handlePaymentSuccess(pid),
      onFailure: (err) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red)),
    );
  }

  int? _selectedWorkerId; 

  void _startPayment(int workerId) {
    setState(() => _selectedWorkerId = workerId);
    
    // SMART LOGIC:
    // If fee is 0 (like Maids), skip payment and book directly.
    if (widget.bookingFee == 0) {
      _handlePaymentSuccess("FREE_BOOKING");
    } else {
      // If fee exists (Plumber), charge it.
      _paymentService.openCheckout(widget.bookingFee, "boss@agency.com", "9876543210");
    }
  }

  void _handlePaymentSuccess(String paymentId) async {
    if (_selectedWorkerId == null) return;
    final bookingService = BookingService();
    final success = await bookingService.createBooking(_selectedWorkerId!, widget.categoryName);

    if (mounted && success) {
      showSuccessDialog(context, onDismiss: () => Navigator.pop(context));
    }
  }

  void _handlePaymentError(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${widget.categoryName}s Nearby", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(widget.bookingFee == 0 ? "Free Booking" : "Booking Fee: ₹${widget.bookingFee}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ), 
        backgroundColor: Colors.white, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.black)
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _providersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final providers = snapshot.data ?? [];
          
          if (providers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 50, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  const Text("No providers found nearby.", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 5),
                  const Text("(Try increasing range or changing location)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: providers.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final worker = providers[index];
              return _ProviderCard(
                worker: worker, 
                category: widget.categoryName,
                price: widget.bookingFee, 
                onQuickBook: () => _startPayment(worker['id']),
              ).animate().fadeIn(delay: (100 * index).ms).slideX();
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
    // Calculate distance if available (Optional UI enhancement)
    // Note: To show "2.5 km away", you would need to calculate distance 
    // between user loc and worker loc here using the 'geolocator' package.
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderPortfolioScreen(
              worker: worker, 
              category: category,
              price: price,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24, 
              backgroundColor: Colors.blue.shade50, 
              child: Text(worker['email'][0].toUpperCase(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(worker['email'].split('@')[0], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber), 
                      Text(" 4.8", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                      Text(" • Nearby", style: TextStyle(fontSize: 12, color: Colors.green)),
                    ]
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: onQuickBook,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: Text(price == 0 ? "Book Free" : "Book ₹$price"),
            ),
          ],
        ),
      ),
    );
  }
}