import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  RxBool isDark = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme(); // Load saved theme when the controller is initialized
  }

  // Method to toggle theme
  void changeTheme() async {
    isDark.value = !isDark.value;
    await _saveTheme(isDark.value);
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Load the saved theme from SharedPreferences when the app starts
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDark.value = prefs.getBool('isDark') ?? false; // Default to light theme if no saved preference
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Save the selected theme to SharedPreferences
  Future<void> _saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', isDarkMode);
  }
}
