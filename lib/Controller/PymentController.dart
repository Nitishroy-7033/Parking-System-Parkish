import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentController extends GetxController {
  late Razorpay _razorpay;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  void makePayment(int amount) {
    var options = {
      'key': 'rzp_test_1WIrDb9DdvtUNE', 
      'amount': amount * 100, 
      'name': 'Acme Corp.',
      'description': 'Fine T-Shirt',
      'prefill': {'contact': '7033161175', 'email': 'test@razorpay.com'},
      'external': {'wallets': ['paytm']},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    Get.snackbar("Success", "Payment successful: ${response.paymentId}");
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar("Failed", "Error: ${response.message}");
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar("External Wallet", "Selected: ${response.walletName}");
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}
