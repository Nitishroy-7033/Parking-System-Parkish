import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../Models/NotificationModel.dart';

class NotificationController extends GetxController{

 final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  RxList<NotificationModel> notificationList = RxList<NotificationModel>();
 Future<void> createNotification(String title, String des) async {
  try {
    
    if (title.isEmpty) {
      throw Exception("Title cannot be empty.");
    }
    if (des.isEmpty) {
      throw Exception("Description cannot be empty.");
    }
    var id = Uuid().v4();
    var newNotification = NotificationModel(
      id: id,
      title: title,
      des: des,
      createdAt: DateTime.now().toString(), 
    );
    var data = newNotification.toJson();
    await db
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("notifications")
        .doc(id)
        .set(data);
    print("Notification created successfully.");
  } catch (ex) {
    
    print("Error creating notification: $ex");
    Get.snackbar(
      "Error",
      ex.toString(),
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
    );
  }
}

Stream<List<NotificationModel>> getNotification() {
  try {
    return db
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("notifications")
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs.map((doc) {
            return NotificationModel.fromJson(doc.data());
          }).toList();
        });
  } catch (e) {
    print("Error fetching notifications: $e");
    return Stream.value([]);
  }
}

}