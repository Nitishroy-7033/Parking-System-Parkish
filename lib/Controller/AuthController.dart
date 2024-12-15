import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Pages/Auth/LoginPage.dart';
import '../Pages/GoogleMap/GoogleMap.dart';
import 'NotificationController.dart';

class AuthController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLogin = false.obs;
  final auth = FirebaseAuth.instance;
  TextEditingController loginEmail = TextEditingController();
  TextEditingController loginPwd = TextEditingController();
  TextEditingController signupEmail = TextEditingController();
  TextEditingController signupName = TextEditingController();
  TextEditingController signupPwd = TextEditingController();

  final NotificationController notificationController = Get.put(NotificationController());

  Future<void> loginWithEmailPassword() async {
    if (loginEmail.text.isEmpty || loginPwd.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all fields.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      await auth.signInWithEmailAndPassword(
        email: loginEmail.text.trim(),
        password: loginPwd.text.trim(),
      );

      // Add a login notification
      await notificationController.createNotification(
        "Login Successful",
        "Welcome back, ${auth.currentUser?.email}!",
      );

      Get.offAll(
        GoogleMapPage(),
        transition: Transition.fadeIn,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseAuthErrorMessage(e);
      Get.snackbar(
        "Login Failed",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "An unexpected error occurred. Please try again later.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithEmailPassword() async {
    if (signupEmail.text.isEmpty || signupPwd.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all fields.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      await auth.createUserWithEmailAndPassword(
        email: signupEmail.text.trim(),
        password: signupPwd.text.trim(),
      );

      // Add a sign-up notification
      await notificationController.createNotification(
        "Sign-Up Successful",
        "Welcome to the app, ${signupEmail.text.trim()}!",
      );

      Get.offAll(
        GoogleMapPage(),
        transition: Transition.fadeIn,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseAuthErrorMessage(e);
      Get.snackbar(
        "Sign-Up Failed",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "An unexpected error occurred. Please try again later.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      // Add a logout notification
      await notificationController.createNotification(
        "Logout Successful",
        "${auth.currentUser?.email} has logged out.",
      );

      await auth.signOut();
      Get.offAll(LoginPage());
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to sign out. Please try again later.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Helper function to map FirebaseAuthException to user-friendly messages
  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "The email address is not valid.";
      case 'user-disabled':
        return "This user account has been disabled.";
      case 'user-not-found':
        return "No user found with this email.";
      case 'wrong-password':
        return "Incorrect password. Please try again.";
      case 'email-already-in-use':
        return "This email is already in use. Please use a different email.";
      case 'weak-password':
        return "The password is too weak. Please choose a stronger password.";
      case 'operation-not-allowed':
        return "This operation is not allowed. Please contact support.";
      default:
        return "An unknown error occurred. Please try again.";
    }
  }
}
