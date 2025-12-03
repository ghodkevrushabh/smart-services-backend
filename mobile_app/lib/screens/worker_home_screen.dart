import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // For Calling
import '../services/booking_service.dart';
import 'login_screen.dart';
import 'chat_screen.dart'; // Import Chat
import 'nearby_map_screen.dart'; // Reuse map for navigation context

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> with SingleTickerProviderStateMixin {
  final _bookingService = BookingService();
  late Future<List<dynamic>> _jobsFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refreshJobs();
  }

  void _refreshJobs() {
    setState(() {
      _jobsFuture = _bookingService.getMyBookings();
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  Future<void> _updateJob(int id, String status) async {
    final success = await _bookingService.updateStatus(id, status);
    if (success) {
      _refreshJobs();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Job $status")));
    }
  }

  // Helper to filter jobs by status
  List<dynamic> _filterJobs(List<dynamic> allJobs, String status) {
    if (status == 'PENDING') return allJobs.where((j) => j['status'] == 'PENDING').toList();
    if (status == 'ACTIVE') return allJobs.where((j) => j['status'] == 'ACCEPTED').toList();
    if (status == 'COMPLETED') return allJobs.where((j) => j['status'] == 'COMPLETED' || j['status'] == 'REJECTED').toList();
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text("Partner Dashboard", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
             Text("Online • Majalgaon", style: TextStyle(color: Colors.green, fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshJobs),
          IconButton(icon: const Icon(Icons.logout, color: Colors.red), onPressed: _logout),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: "Requests"),
            Tab(text: "Active"),
            Tab(text: "History"),
          ],
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _jobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final allJobs = snapshot.data ?? [];

          return TabBarView(
            controller: _tabController,
            children: [
              _buildJobList(_filterJobs(allJobs, 'PENDING'), isRequest: true),
              _buildJobList(_filterJobs(allJobs, 'ACTIVE'), isActive: true),
              _buildJobList(_filterJobs(allJobs, 'COMPLETED'), isHistory: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildJobList(List<dynamic> jobs, {bool isRequest = false, bool isActive = false, bool isHistory = false}) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text("No jobs here", style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        final customer = job['customer'];
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Service Type & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                      child: Text(job['service_category'], style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                    // Hardcoded for MVP - In real app, fetch from DB
                    const Text("Earn ₹450", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Customer Details
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: Text(customer['email'][0].toUpperCase(), style: const TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customer['full_name'] ?? "Customer", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(customer['city'] ?? "Unknown Location", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // ACTION BUTTONS
                if (isRequest)
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () => _updateJob(job['id'], 'REJECTED'), child: const Text("Reject"))),
                      const SizedBox(width: 10),
                      Expanded(child: FilledButton(
                        onPressed: () => _updateJob(job['id'], 'ACCEPTED'), 
                        style: FilledButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text("Accept")
                      )),
                    ],
                  ),

                if (isActive)
                  Row(
                    children: [
                      // CHAT BUTTON (FIXED)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (ctx) => ChatScreen(
                              otherUserId: customer['id'], 
                              otherUserName: customer['full_name'] ?? "Customer"
                            )));
                          },
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text("Chat"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // COMPLETE BUTTON
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _updateJob(job['id'], 'COMPLETED'), 
                          icon: const Icon(Icons.check),
                          label: const Text("Complete Job"),
                          style: FilledButton.styleFrom(backgroundColor: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  
                 if (isHistory)
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(job['status'] == 'COMPLETED' ? Icons.check_circle : Icons.cancel, 
                         color: job['status'] == 'COMPLETED' ? Colors.green : Colors.red, size: 16),
                       const SizedBox(width: 5),
                       Text(job['status'], style: TextStyle(fontWeight: FontWeight.bold, color: job['status'] == 'COMPLETED' ? Colors.green : Colors.red))
                     ],
                   )
              ],
            ),
          ),
        );
      },
    );
  }
}