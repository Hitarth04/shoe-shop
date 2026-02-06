import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentService {
  // 1. Create a Razorpay instance
  final Razorpay _razorpay = Razorpay();

  // Callbacks to handle the result
  final Function(String) onSuccess;
  final Function(String) onFailure;

  PaymentService({required this.onSuccess, required this.onFailure});

  // 2. Initialize listeners
  void initialize() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // 3. The Trigger Function
  void openCheckout(
      {required double amount, required String mobile, required String email}) {
    // Razorpay takes amount in "Paise" (₹1 = 100 paise)
    var options = {
      // REPLACE WITH YOUR ACTUAL KEY
      'key': dotenv.env['RAZORPAY_KEY_ID'],

      'amount': (amount * 100).toInt(),
      'name': 'Shoe Shop',
      'description': 'Payment for your order',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': mobile, 'email': email},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      onFailure("Error opening checkout: $e");
    }
  }

  // 4. Result Handlers
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    onSuccess(response.paymentId ?? "Success");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onFailure("Payment Failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onSuccess("Wallet Selected: ${response.walletName}");
  }

  void dispose() {
    _razorpay.clear();
  }
}
