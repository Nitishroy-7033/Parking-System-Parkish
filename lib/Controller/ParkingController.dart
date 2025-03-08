import 'package:car_parking_system/Controller/NotificationController.dart';
import 'package:car_parking_system/Models/ParkingModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../Components/ConfirmPop.dart';

class ParkingController extends GetxController {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  String parkingSlot1Id = "A-0";
  String parkingSlot2Id = "A-1";
  String parkingSlot3Id = "A-2";
  String parkingSlot4Id = "A-3";
  String parkingSlot5Id = "A-4";
  String parkingSlot6Id = "A-5";
  String parkingSlot7Id = "A-6";
  String parkingSlot8Id = "A-7";
  String parkingSlot9Id = "A-8";
  RxList<ParkingModel> parkingList = RxList<ParkingModel>();
  RxList<ParkingModel> yourBooking = RxList<ParkingModel>();
  RxBool isYourCarParked = false.obs;
  RxDouble time = 30.0.obs;
  RxDouble amount = 5.0.obs;
  RxBool isLoading = false.obs;
  Rx<ParkingModel> parkingSlot0 = ParkingModel().obs;
  Rx<ParkingModel> parkingSlot1 = ParkingModel().obs;
  Rx<ParkingModel> parkingSlot2 = ParkingModel().obs;
  Rx<ParkingModel> parkingSlot3 = ParkingModel().obs;
  Rx<ParkingModel> parkingSlot4 = ParkingModel().obs;
  Rx<ParkingModel> parkingSlot5 = ParkingModel().obs;
  Rx<ParkingModel> parkingSlot6 = ParkingModel().obs;
  Rx<ParkingModel> parkingSlot7 = ParkingModel().obs;
  Rx<ParkingModel> parkingSlot8 = ParkingModel().obs;
  NotificationController notificationController = Get.put(NotificationController());

  @override
  void onInit() async {
    await getParkingInfo();
    // await dataInit();
    super.onInit();
  }

  Future<void> dataInit() async {
    parkingList = RxList<ParkingModel>([
      ParkingModel(
        id: parkingSlot1Id,
        name: "",
        status: "available",
        price: "0",
        parkingStatus: "available",
        slotNumber: "A-0",
      ),
      ParkingModel(
        id: parkingSlot2Id,
        name: "",
        status: "available",
        price: "0",
        parkingStatus: "available",
        slotNumber: "A-1",
      ),
      ParkingModel(
        id: parkingSlot3Id,
        name: "",
        status: "available",
        price: "0",
        parkingStatus: "available",
        slotNumber: "A-2",
      ),
      ParkingModel(
        id: parkingSlot4Id,
        name: "",
        status: "available",
        price: "0",
        parkingStatus: "available",
        slotNumber: "A-3",
      ),
      ParkingModel(
        id: parkingSlot5Id,
        name: "",
        status: "available",
        price: "0",
        parkingStatus: "available",
        slotNumber: "A-4",
      ),
      ParkingModel(
        id: parkingSlot6Id,
        name: "",
        status: "available",
        price: "0",
        parkingStatus: "available",
        slotNumber: "A-5",
      ),
      ParkingModel(
        id: parkingSlot7Id,
        name: "",
        status: "available",
        price: "0",
        parkingStatus: "available",
        slotNumber: "A-6",
      ),
      ParkingModel(
        id: parkingSlot8Id,
        name: "",
        status: "available",
        price: "0",
        parkingStatus: "available",
        slotNumber: "A-7",
      ),
      ParkingModel(
        id: parkingSlot8Id,
        name: "",
        status: "available",
        price: "0",
        parkingStatus: "available",
        slotNumber: "A-8",
      ),
    ]);
    for (var item in parkingList) {
      await db.collection("parking").doc(item.id).set(item.toJson());
    }
    print("Parking Slots Initialized");
    notificationController.createNotification("Parking Slots Initialized", "Parking slots have been initialized.");
  }

  Future<void> getParkingInfo() async {
    isLoading.value = true;
    parkingList.clear();
    await db.collection("parking").get().then((value) {
      for (var item in value.docs) {
        parkingList.add(ParkingModel.fromJson(item.data()));
      }
      isLoading.value = false;
      notificationController.createNotification("Parking Info Loaded", "Parking information has been successfully loaded.");
    }, onError: (e) {
      print(e);
      isLoading.value = false;
      notificationController.createNotification("Error", "Error loading parking information: $e");
    });
  }

  Future<void> bookSlot(
    String name,
    String vehicalNumber,
    String slotId,
    BuildContext context,
    String fromTime,
    String toTime,
  ) async {
    try {
      var updatedSlot = ParkingModel(
        id: slotId,
        name: name,
        status: "booked",
        price: "0",
        parkingStatus: "booked",
        slotNumber: slotId,
        vehicalNumber: vehicalNumber,
        totalAmount: "0",
        parkingFromTime: fromTime,
        parkingToTime: toTime,
      );
      await db.collection("parking").doc(slotId).update(
            updatedSlot.toJson(),
          );
      await db
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection("parking")
          .doc(slotId)
          .set(
            updatedSlot.toJson(),
          );
      await getParkingInfo();
      BookedPopup(context, slotId, amount.value.toString(),
          time.value.toString(), name, vehicalNumber);
      notificationController.createNotification("${slotId} Slot Booked", "You have booked a slot.");
    } catch (e) {
      print(e);
      notificationController.createNotification("Booking Failed", "Failed to book the parking slot: $e");
    }
  }

  Future<void> personalBooking() async {
    isLoading.value = true;
    yourBooking.clear();
    await db
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection("parking")
        .get()
        .then((value) {
      for (var item in value.docs) {
        yourBooking.add(ParkingModel.fromJson(item.data()));
      }
    });
    isLoading.value = false;
    notificationController.createNotification("Personal Booking", "Your personal booking has been updated.");
  }

  Future<void> checkout(String slotId) async {
    isLoading.value = true;
    await db.collection("parking").doc(slotId).update(
      {
        "id": slotId,
        "name": "",
        "slotNumber": slotId,
        "parkingStatus": "available",
        "vehicalNumber": "",
        "totalAmount": "",
        "totalTime": "",
      },
    );
    await db
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("parking")
        .doc(slotId)
        .delete();
    await personalBooking();
    await getParkingInfo();
    notificationController.createNotification("${slotId} Checkout", "Slot no ${slotId} is now available.");
    isLoading.value = false;
  }

  Future<void> parked(String slotId) async {
    isLoading.value = true;
    await db.collection("parking").doc(slotId).update(
      {
        "parkingStatus": "parked",
      },
    );
    await db
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("parking")
        .doc(slotId)
        .update(
      {
        "parkingStatus": "parked",
      },
    );
    await personalBooking();
    await getParkingInfo();
    notificationController.createNotification("Your car is parked ${slotId} Slot Booked", "You have successfully parked your car.");
    isLoading.value = false;
  }

  Future<void> cancelBooking(String slotId) async {
    isLoading.value = true;
    await db.collection("parking").doc(slotId).update(
      {
        "id": slotId,
        "name": "",
        "slotNumber": slotId,
        "parkingStatus": "available",
        "vehicalNumber": "",
        "totalAmount": "",
        "totalTime": "",
      },
    );
    await db
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("parking")
        .doc(slotId)
        .delete();
    await personalBooking();
    await getParkingInfo();
    notificationController.createNotification("Booking Cancelled", "Your parking slot booking has been cancelled.");
    isLoading.value = false;
  }

  Future<void> checkingCarisParkedOrNot() async {
    for (var car in yourBooking) {
      if (car.parkingStatus == "parked") {
        isYourCarParked.value = true;
        notificationController.createNotification("Car Status", "Your car is parked.");
        return;
      } else {
        isYourCarParked.value = false;
        notificationController.createNotification("Car Status", "Your car is not parked.");
        return;
      }
    }
  }
}
