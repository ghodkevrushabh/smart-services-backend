import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Updated to accept optional title, message, and callback
void showSuccessDialog(BuildContext context, {String title = "Booking Confirmed", String message = "Your provider has been notified.", VoidCallback? onDismiss}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/images/success.json', 
              width: 150, 
              height: 150, 
              repeat: false,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.check_circle, color: Colors.green, size: 80),
            ),
            const SizedBox(height: 20),
            Text(
              title, 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message, 
              textAlign: TextAlign.center, 
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (onDismiss != null) onDismiss();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Done", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}