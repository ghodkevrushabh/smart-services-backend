import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/booking_service.dart';
import 'tracking_screen.dart';
import 'provider_portfolio_screen.dart'; // Optional: if needed

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final _bookingService = BookingService();
  late Future<List<dynamic>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _refreshBookings();
  }

  void _refreshBookings() {
    setState(() {
      _bookingsFuture = _bookingService.getMyBookings();
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // --- RATING DIALOG ---
  void _showRatingDialog(BuildContext context, int bookingId) {
    int selectedStars = 0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Rate Service", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("How was your experience?"),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () => setDialogState(() => selectedStars = index + 1),
                      icon: Icon(
                        index < selectedStars ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: "Write a review...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              FilledButton(
                onPressed: selectedStars == 0 ? null : () async {
                  await _bookingService.rateJob(bookingId, selectedStars, commentController.text);
                  if (mounted) {
                    Navigator.pop(ctx);
                    _refreshBookings();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thanks for your review!")));
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Submit"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("My Bookings", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading bookings", style: GoogleFonts.poppins(color: Colors.red)));
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 15),
                  Text("No bookings yet", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final status = booking['status'];
              
              // Status Styling
              Color statusColor = Colors.orange;
              String statusText = "Pending";
              
              if (status == 'ACCEPTED') {
                statusColor = Colors.blue;
                statusText = "Accepted";
              } else if (status == 'COMPLETED') {
                statusColor = Colors.green;
                statusText = "Completed";
              } else if (status == 'REJECTED') {
                statusColor = Colors.red;
                statusText = "Rejected";
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    // HEADER: Date & Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDate(booking['scheduled_date']), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),

                    // BODY: Service Info
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[100],
                            radius: 25,
                            child: Text(booking['service_category'][0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(booking['service_category'], style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text("Provider: ${booking['provider']['email'].split('@')[0]}", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- NEW FOOTER: STRICT ACTION LOGIC ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        children: [
                          // 1. STATUS: PENDING
                          if (status == 'PENDING')
                            const Expanded(
                              child: Text(
                                "Waiting for provider to accept...",
                                style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          // 2. STATUS: ACCEPTED (Track Only)
                          if (status == 'ACCEPTED')
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TrackingScreen())),
                                icon: const Icon(Icons.map, size: 18),
                                label: const Text("Track Provider"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  side: const BorderSide(color: Colors.blue),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),

                          // 3. STATUS: COMPLETED (Unlock Rating)
                          if (status == 'COMPLETED' && booking['rating'] == null)
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => _showRatingDialog(context, booking['id']),
                                icon: const Icon(Icons.star, size: 18),
                                label: const Text("Rate & Review"), // ONLY VISIBLE IF COMPLETED
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),

                          // 4. ALREADY RATED
                          if (booking['rating'] != null)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 8),
                                    Text("You rated ${booking['rating']}/5", style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Payment Reminder (for Completed jobs that need action)
                    if (status == 'COMPLETED' && booking['rating'] == null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.yellow[50],
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.orange[800]),
                            const SizedBox(width: 8),
                            Text("Don't forget to pay the balance!", style: TextStyle(color: Colors.orange[900], fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}