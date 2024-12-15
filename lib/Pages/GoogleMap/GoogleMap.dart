import 'dart:async';

import 'package:car_parking_system/Controller/AuthController.dart';
import 'package:car_parking_system/Pages/AboutUs/AboutUs..dart';
import 'package:car_parking_system/Pages/Home/HomePage.dart';
import 'package:car_parking_system/Pages/ProfilePage/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../Controller/ParkingController.dart';

class GoogleMapPage extends StatelessWidget {
  const GoogleMapPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Completer<GoogleMapController> controller = Completer();
    const LatLng center = LatLng(22.493864, 88.347684);
    ParkingController parkingController = Get.put(ParkingController());
    AuthController authController = Get.put(AuthController());
    Set<Marker> markers = {
      Marker(
        onTap: () {
          Get.to(HomePage());
        },
        visible: true,
        markerId: MarkerId('parking_1'),
        position: LatLng(22.493864, 88.347684),
      ),
      Marker(
        onTap: () {
          Get.to(HomePage());
        },
        visible: true,
        markerId: MarkerId('parking_2'),
        position: LatLng(22.504672, 88.335627),
      ),
      Marker(
        onTap: () {
          Get.to(HomePage());
        },
        visible: true,
        markerId: MarkerId('parking_3'),
        position: LatLng(22.512919, 88.355896),
      ),
      Marker(
        onTap: () {
          Get.to(HomePage());
        },
        visible: true,
        markerId: MarkerId('parking_4'),
        position: LatLng(22.523067, 88.348681),
      ),
      Marker(
        onTap: () {},
        visible: true,
        markerId: MarkerId('parking_5'),
        position: LatLng(22.524653, 88.364484),
      ),
    };
    return Scaffold(
      appBar: AppBar(
        title: Text('Parking Stations'),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(ProfilePage());
            },
            icon: Icon(Icons.person),
          ),
          IconButton(
            onPressed: () {
              Get.to(AboutUs());
            },
            icon: Icon(Icons.info),
          ),
        ],
      ),
      body: GoogleMap(
        buildingsEnabled: true,
        compassEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: const CameraPosition(
          target: center,
          zoom: 14.0,
        ),
        markers: markers,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          controller = controller;
        },
      ),
    );
  }
}
