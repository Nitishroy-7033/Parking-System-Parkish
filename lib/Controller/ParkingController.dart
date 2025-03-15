import 'package:car_parking_system/Controller/NotificationController.dart';
import 'package:car_parking_system/Models/ParkingModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';

import '../Components/ConfirmPop.dart';

class ParkingController extends GetxController {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  late Razorpay _razorpay;
  // Parking Slots
  final int totalSlots = 9;
  List<String> parkingSlotIds = List.generate(9, (index) => "A-$index");

  RxList<ParkingModel> parkingList = RxList<ParkingModel>();
  RxList<ParkingModel> yourBooking = RxList<ParkingModel>();
  RxBool isYourCarParked = false.obs;
  RxDouble time = 30.0.obs;
  RxDouble amount = 5.0.obs;
  RxBool isLoading = false.obs;

  Rx<DateTime> fromTime = DateTime.now().obs;
  Rx<DateTime> toTime = DateTime.now().add(const Duration(minutes: 30)).obs;

  final NotificationController notificationController =
      Get.put(NotificationController());

  @override
  void onInit() async {
    await getParkingInfo();
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  void makePayment(String name, String vehicalNumber, String slotId,
      BuildContext context, DateTime fromDateTime, DateTime toDateTime) {
    var options = {
      'key': 'rzp_test_1WIrDb9DdvtUNE',
      'amount': (amount.value * 100).toInt(),
      'name': 'Acme Corp.',
      'description': 'Parking Slot Booking',
      'prefill': {'contact': '7033161175', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      },
    };

    try {
      _razorpay.open(options);

      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
          (PaymentSuccessResponse response) {
        handlePaymentSuccess(response, name, vehicalNumber, slotId, context,
            fromDateTime, toDateTime);
      });
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
    }
  }

  Future<void> dataInit() async {
    parkingList.assignAll(
      List.generate(
        totalSlots,
        (index) => ParkingModel(
          id: parkingSlotIds[index],
          name: "",
          status: "available",
          price: "0",
          parkingStatus: "available",
          slotNumber: parkingSlotIds[index],
        ),
      ),
    );

    for (var item in parkingList) {
      await db.collection("parking").doc(item.id).set(item.toJson());
    }

    print("Parking Slots Initialized");
    notificationController.createNotification(
        "Parking Slots Initialized", "Parking slots have been initialized.");
  }

  Future<void> getParkingInfo() async {
    isLoading.value = true;
    try {
      var value = await db.collection("parking").get();
      parkingList.assignAll(
          value.docs.map((item) => ParkingModel.fromJson(item.data())));
      notificationController.createNotification("Parking Info Loaded",
          "Parking information has been successfully loaded.");
    } catch (e) {
      notificationController.createNotification(
          "Error", "Error loading parking information: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bookSlot(
    String name,
    String vehicalNumber,
    String slotId,
    BuildContext context,
    DateTime fromDateTime,
    DateTime toDateTime,
  ) async {
    var options = {
      'key': 'rzp_test_1WIrDb9DdvtUNE',
      'amount': amount * 100,
      'name': 'Acme Corp.',
      'description': 'Parking Slot Booking',
      'prefill': {'contact': '7033161175', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      },
    };
    try {
      _razorpay.open(options);
            print("Payemnt Starting⭐");
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
          (PaymentSuccessResponse response) {
            print("Payemtn done 💹✅");
        handlePaymentSuccess(response, name, vehicalNumber, slotId, context, fromDateTime, toDateTime);
      });
    } catch (e) {
      print(e);
      notificationController.createNotification(
          "Booking Failed", "Failed to book the parking slot: $e");
    }
  }

  void handlePaymentSuccess(
      PaymentSuccessResponse response,
      String name,
      String vehicalNumber,
      String slotId,
      BuildContext context,
      DateTime fromDateTime,
      DateTime toDateTime) async {
    try {
      var updatedSlot = ParkingModel(
        id: slotId,
        name: name,
        status: "booked",
        price: amount.value.toString(),
        parkingStatus: "booked",
        slotNumber: slotId,
        vehicalNumber: vehicalNumber,
        totalAmount: amount.value.toString(),
        parkingFromTime: fromDateTime.toString(),
        parkingToTime: toDateTime.toString(),
      );

      await db.collection("parking").doc(slotId).update(updatedSlot.toJson());
      await db
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection("parking")
          .doc(slotId)
          .set(updatedSlot.toJson());

      await getParkingInfo();

      BookedPopup(
        context,
        slotId,
        amount.value.toString(),
        fromDateTime.toString(),
        toDateTime.toString(),
        name,
        vehicalNumber,
      );

      notificationController.createNotification("${slotId} Slot Booked",
          "You have booked a slot from ${fromDateTime.toLocal()} to ${toDateTime.toLocal()}.");

      Get.snackbar("Success", "Payment successful: ${response.paymentId}");
    } catch (e) {
      Get.snackbar("Error", "Booking failed after payment: $e");
    }
  }

  Future<void> personalBooking() async {
    isLoading.value = true;
    try {
      var value = await db
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection("parking")
          .get();
      yourBooking.assignAll(
          value.docs.map((item) => ParkingModel.fromJson(item.data())));
      notificationController.createNotification(
          "Personal Booking", "Your personal booking has been updated.");
    } catch (e) {
      notificationController.createNotification(
          "Error", "Error fetching personal booking: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkout(String slotId) async {
    isLoading.value = true;
    try {
      await db.collection("parking").doc(slotId).update({
        "id": slotId,
        "name": "",
        "slotNumber": slotId,
        "parkingStatus": "available",
        "vehicalNumber": "",
        "totalAmount": "",
        "totalTime": "",
      });

      await db
          .collection("users")
          .doc(auth.currentUser!.uid)
          .collection("parking")
          .doc(slotId)
          .delete();

      await personalBooking();
      await getParkingInfo();
      notificationController.createNotification(
          "$slotId Checkout", "Slot no $slotId is now available.");
    } catch (e) {
      notificationController.createNotification(
          "Checkout Failed", "Failed to checkout slot: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> parked(String slotId) async {
    isLoading.value = true;
    try {
      await db
          .collection("parking")
          .doc(slotId)
          .update({"parkingStatus": "parked"});
      await db
          .collection("users")
          .doc(auth.currentUser!.uid)
          .collection("parking")
          .doc(slotId)
          .update({"parkingStatus": "parked"});

      await personalBooking();
      await getParkingInfo();
      notificationController.createNotification(
          "$slotId Slot Booked", "You have successfully parked your car.");
    } catch (e) {
      notificationController.createNotification(
          "Error", "Failed to mark car as parked: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelBooking(String slotId) async {
    isLoading.value = true;
    try {
      await db.collection("parking").doc(slotId).update({
        "id": slotId,
        "name": "",
        "slotNumber": slotId,
        "parkingStatus": "available",
        "vehicalNumber": "",
        "totalAmount": "",
        "totalTime": "",
      });

      await db
          .collection("users")
          .doc(auth.currentUser!.uid)
          .collection("parking")
          .doc(slotId)
          .delete();

      await personalBooking();
      await getParkingInfo();
      notificationController.createNotification(
          "Booking Cancelled", "Your parking slot booking has been cancelled.");
    } catch (e) {
      notificationController.createNotification(
          "Error", "Failed to cancel booking: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkingCarIsParkedOrNot() async {
    for (var car in yourBooking) {
      if (car.parkingStatus == "parked") {
        isYourCarParked.value = true;
        notificationController.createNotification(
            "Car Status", "Your car is parked.");
        return;
      }
    }
    isYourCarParked.value = false;
    notificationController.createNotification(
        "Car Status", "Your car is not parked.");
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
