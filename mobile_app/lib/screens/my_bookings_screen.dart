import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../services/booking_service.dart';
import 'tracking_screen.dart'; // For the Map feature

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
    _bookingsFuture = _bookingService.getMyBookings();
  }

  // Helper to format the date nicely (Local Time)
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final localDate = date.toLocal(); // Convert UTC to Phone Time
      return DateFormat('MMM dd, yyyy - hh:mm a').format(localDate);
    } catch (e) {
      return dateString;
    }
  }

  // ---------------------------------------------------
  // NEW: Interactive Rating Dialog
  // ---------------------------------------------------
  void _showRatingDialog(BuildContext context, int bookingId) {
    int selectedStars = 0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        // We use StatefulBuilder so the Stars update INSIDE the dialog when tapped
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Rate Service", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("How was your experience?"),
                  const SizedBox(height: 20),
                  
                  // THE STAR ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            selectedStars = index + 1;
                          });
                        },
                        icon: Icon(
                          index < selectedStars ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  
                  // THE COMMENT BOX
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: "Write a review (optional)...",
                      border: OutlineInputBorder(),
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
                  onPressed: selectedStars == 0 ? null : () async { // Disable if 0 stars
                    // 1. Call Backend
                    await _bookingService.rateJob(
                      bookingId, 
                      selectedStars, 
                      commentController.text
                    );
                    
                    // 2. Close & Refresh
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      setState(() {
                        _bookingsFuture = _bookingService.getMyBookings();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Thanks for your review!")),
                      );
                    }
                  },
                  child: const Text("Submit Review"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: Colors.blue.shade100,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return const Center(child: Text("No bookings yet."));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final status = booking['status'];
              
              // Color Logic
              Color statusColor = Colors.orange;
              IconData statusIcon = Icons.hourglass_empty;
              
              if (status == 'ACCEPTED') {
                statusColor = Colors.blue;
                statusIcon = Icons.thumb_up;
              } else if (status == 'COMPLETED') {
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
              } else if (status == 'REJECTED') {
                statusColor = Colors.red;
                statusIcon = Icons.cancel;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withOpacity(0.2),
                        child: Icon(statusIcon, color: statusColor),
                      ),
                      title: Text(
                        booking['service_category'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Provider: ${booking['provider']['email']}"),
                          const SizedBox(height: 4),
                          Text(
                            "Requested: ${_formatDate(booking['scheduled_date'])}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      trailing: Text(
                        status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    
                    // ACTION BUTTONS ROW
                    if (status == 'ACCEPTED' || status == 'COMPLETED')
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // TRACK BUTTON (Only if Accepted)
                            if (status == 'ACCEPTED')
                              FilledButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const TrackingScreen()),
                                  );
                                },
                                icon: const Icon(Icons.map),
                                label: const Text("Track"),
                                style: FilledButton.styleFrom(backgroundColor: Colors.blue),
                              ),

                            // RATE BUTTON (Only if Completed & Not Rated)
                            if (status == 'COMPLETED' && booking['rating'] == null)
                              OutlinedButton.icon(
                                onPressed: () => _showRatingDialog(context, booking['id']),
                                icon: const Icon(Icons.star, color: Colors.orange),
                                label: const Text("Rate Service"),
                              ),

                            // SHOW RATING (If already rated)
                            if (booking['rating'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.orange.shade200),
                                ),
                                child: Text(
                                  "You rated: ⭐ ${booking['rating']}",
                                  style: TextStyle(
                                    color: Colors.orange.shade800, 
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
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