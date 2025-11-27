import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  late Razorpay _razorpay;
  final Function(String) onSuccess;
  final Function(String) onFailure;

  // REPLACE THIS WITH YOUR RAZORPAY KEY ID
  final String _keyId = "rzp_test_RjseYqAaskzoql"; 

  PaymentService({required this.onSuccess, required this.onFailure}) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void openCheckout(int amount, String email, String phone) {
    var options = {
      'key': _keyId,
      'amount': amount * 100, // Razorpay takes amount in Paise (500 * 100 = 50000 paise)
      'name': 'Smart Services',
      'description': 'Service Booking Charge',
      'prefill': {'contact': phone, 'email': email},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      onFailure("Error starting payment: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment ID comes back here (e.g., "pay_29384723")
    onSuccess(response.paymentId ?? "Success");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onFailure("Payment Failed: ${response.message}");
  }

  void dispose() {
    _razorpay.clear();
  }
}