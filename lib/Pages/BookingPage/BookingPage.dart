import 'package:car_parking_system/Controller/ParkingController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class BookingPage extends StatelessWidget {
  final String slotName;
  final String slotId;
  const BookingPage({super.key, required this.slotId, required this.slotName});

  @override
  Widget build(BuildContext context) {
    ParkingController parkingController = Get.put(ParkingController());
    TextEditingController nameController = TextEditingController();
    TextEditingController vehicalNumberController = TextEditingController();
    Rx<DateTime> fromTime = DateTime.now().obs;
    Rx<DateTime> toTime = DateTime.now().add(const Duration(minutes: 30)).obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "BOOK SLOT",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Car Animation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'Assets/animation/running_car.json',
                      width: 300,
                      height: 200,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Title
                const Row(
                  children: [
                    Text(
                      "Book Now 😊",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
                Divider(
                  thickness: 1,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 30),
                // Name Input
                const Row(
                  children: [
                    Text("Enter your name"),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          fillColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          filled: true,
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          hintText: "Enter your name",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Vehicle Number Input
                const Row(
                  children: [
                    Text("Enter Vehicle Number"),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: vehicalNumberController,
                        decoration: InputDecoration(
                          fillColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          filled: true,
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.car_rental,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          hintText: "Enter vehicle number",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Row(
                  children: [
                    Text("Select Parking Time "),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("From:"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(), // ✅ Prevent past dates
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            // ✅ Combine selected date and time
                            fromTime.value = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );

                            // ✅ Update duration & amount if `toTime` is set
                            if (toTime.value.isAfter(fromTime.value)) {
                              Duration duration =
                                  toTime.value.difference(fromTime.value);
                              parkingController.time.value =
                                  duration.inMinutes.toDouble();
                              parkingController.amount.value =
                                  (duration.inHours * 10)
                                      .toDouble(); // ₹10 per hour
                            }
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Obx(
                          () => Text(
                            DateFormat('dd MMM yyyy, hh:mm a')
                                .format(fromTime.value),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text("To:"),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: fromTime
                              .value, // ✅ Ensure "To" date is after "From" date
                          firstDate: fromTime.value, // ✅ Prevent past dates
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            toTime.value = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );

                            // ✅ Ensure `toTime` is after `fromTime`
                            if (toTime.value.isAfter(fromTime.value)) {
                              Duration duration =
                                  toTime.value.difference(fromTime.value);
                              parkingController.time.value =
                                  duration.inMinutes.toDouble();
                              parkingController.amount.value =
                                  (duration.inHours * 10)
                                      .toDouble(); // ₹10 per hour
                            } else {
                              Get.snackbar(
                                "Invalid Time",
                                "End time must be after start time",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red.withOpacity(0.1),
                                colorText: Colors.red,
                              );
                            }
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Obx(
                          () => Text(
                            DateFormat('dd MMM yyyy, hh:mm a')
                                .format(toTime.value),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Slot Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Your Slot Name"),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          slotName,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
                // Booking and Payment
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Row(
                          children: [
                            Text("Amount to Be Paid"),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.currency_rupee,
                              size: 40,
                            ),
                            Obx(
                              () => Text(
                                "₹${parkingController.amount.value.toStringAsFixed(1)}",
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        if (nameController.text.isEmpty) {
                          Get.snackbar(
                            "Validation Error",
                            "Name is required!",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.1),
                            colorText: Colors.red,
                          );
                          return;
                        }
                        if (vehicalNumberController.text.isEmpty) {
                          Get.snackbar(
                            "Validation Error",
                            "Vehicle number is required!",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.1),
                            colorText: Colors.red,
                          );
                          return;
                        }

                        // Proceed to Booking
                   
                        parkingController.bookSlot(
                          nameController.text,
                          vehicalNumberController.text,
                          slotId,
                          context,
                          fromTime.value,
                          toTime.value,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "BOOK NOW",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
