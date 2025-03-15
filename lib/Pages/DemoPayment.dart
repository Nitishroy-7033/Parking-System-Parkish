import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/PymentController.dart';

class PaymentScreen extends StatelessWidget {
  final PaymentController controller = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Razorpay Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => controller.makePayment(1), 
          child: const Text("Pay ₹100"),
        ),
      ),
    );
  }
}
