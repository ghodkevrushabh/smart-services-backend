import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/booking_service.dart';
import 'login_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  final _bookingService = BookingService();
  late Future<List<dynamic>> _jobsFuture;

  @override
  void initState() {
    super.initState();
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
    if (mounted) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _updateJob(int id, String status) async {
    final success = await _bookingService.updateStatus(id, status);
    if (success) {
      _refreshJobs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Job marked as $status")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Worker Dashboard"),
        backgroundColor: Colors.orange.shade100,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _jobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) {
            return const Center(child: Text("No jobs assigned yet."));
          }

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              final status = job['status'];
              
              // Status Colors
              Color statusColor = Colors.orange;
              if (status == 'ACCEPTED') statusColor = Colors.blue;
              if (status == 'COMPLETED') statusColor = Colors.green;
              if (status == 'REJECTED') statusColor = Colors.red;

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Job #${job['id']} - ${job['service_category']}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text("Customer: ${job['customer']['email']}"),
                      const SizedBox(height: 4),
                      Text(
                        "Status: $status", 
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )
                      ),
                      const SizedBox(height: 16),
                      
                      // 1. PENDING STATE: Show Accept/Reject
                      if (status == 'PENDING') 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => _updateJob(job['id'], 'REJECTED'),
                              child: const Text("Reject"),
                            ),
                            const SizedBox(width: 10),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () => _updateJob(job['id'], 'ACCEPTED'),
                              child: const Text("Accept Job"),
                            ),
                          ],
                        ),

                      // 2. ACCEPTED STATE: Show Complete Button
                      if (status == 'ACCEPTED')
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(backgroundColor: Colors.blue),
                            onPressed: () => _updateJob(job['id'], 'COMPLETED'),
                            icon: const Icon(Icons.check_circle),
                            label: const Text("Mark Job as Completed"),
                          ),
                        ),
                      
                      // 3. COMPLETED STATE: Show Finished Message
                      if (status == 'COMPLETED')
                         const Center(
                           child: Text(
                             "✅ Job Finished Successfully", 
                             style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
                           ),
                         ),
                         
                      // 4. REJECTED STATE
                      if (status == 'REJECTED')
                         const Center(
                           child: Text(
                             "❌ Job Rejected", 
                             style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)
                           ),
                         ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}