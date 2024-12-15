import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/NotificationController.dart';
import '../../Models/NotificationModel.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Create an instance of the NotificationController
    final notificationController = Get.put(NotificationController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationController.getNotification(), // Stream of notifications
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications available.'));
          }

          // Get the list of notifications
          var notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];

              return ListTile(
                leading: Icon(Icons.notifications),
                title: Text(
                  notification.title!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: Text(
                  notification.des!,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
