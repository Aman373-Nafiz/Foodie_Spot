import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import '../screens/SplashScreen.dart';

class ScannerController extends GetxController {
  final MobileScannerController scannerController = MobileScannerController();
  RxBool isScanning = true.obs;

  // Define the expected QR code value here
  final String expectedQRValue = "FoodieSpot Test QR Code";

  @override
  void onInit() {
    super.onInit();
    startScanner();
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }

  void startScanner() async {
    try {
      await scannerController.start();
    } catch (e) {
      debugPrint('Failed to start scanner: $e');
      Get.snackbar(
        'Error',
        'Failed to start scanner: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void toggleTorch() {
    try {
      scannerController.toggleTorch();
    } catch (e) {
      debugPrint('Error toggling torch: $e');
    }
  }

  void switchCamera() {
    try {
      scannerController.switchCamera();
    } catch (e) {
      debugPrint('Error switching camera: $e');
    }
  }

  void processQRCode(String code) {
    // Stop scanning to prevent multiple detections
    isScanning.value = false;

    // Check if the scanned code matches the expected value
    if (code == expectedQRValue) {
      // If matched, navigate to splash screen
      Get.offAll(() => SplashScreen());
    } else {
      // If not matched, show error message
      Get.snackbar(
        'Invalid QR Code',
        'The scanned QR code does not match the expected value.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Resume scanning after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        isScanning.value = true;
      });
    }
  }
}