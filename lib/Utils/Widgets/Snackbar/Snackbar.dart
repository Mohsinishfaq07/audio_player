import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showsnackbar(String title, String subtitle) {
  Get.snackbar(
    title,
    subtitle,
    animationDuration: Duration(milliseconds: 500),
    snackPosition: SnackPosition.BOTTOM,
    colorText: Colors.black,
  );
}
