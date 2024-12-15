import 'package:car_parking_system/Components/ConfirmPop.dart';
import 'package:car_parking_system/Controller/ParkingController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    RxString fromTime = "10:00 AM".obs;
    RxString toTime = "10:30 AM".obs;

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
                // Slot Time Slider
                const Row(
                  children: [
                    Text("Choose Slot Time (in Minutes)"),
                  ],
                ),
                const SizedBox(height: 20),
                Obx(
                  () => Slider(
                    thumbColor: Theme.of(context).colorScheme.primary,
                    activeColor: Theme.of(context).colorScheme.primary,
                    inactiveColor: Theme.of(context).colorScheme.surface,
                    label: "${parkingController.time.value} m",
                    value: parkingController.time.value,
                    onChanged: (v) {
                      parkingController.time.value = v;
                      parkingController.amount.value = v * 1;
                    },
                    divisions: 6,
                    min: 30,
                    max: 210,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("30"),
                      Text("60"),
                      Text("90"),
                      Text("120"),
                      Text("150"),
                      Text("180"),
                      Text("210"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
                                parkingController.amount.value.toStringAsFixed(2),
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
                        // Validate Name and Vehicle Number
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
