import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodiespot/utils/constant.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controller/qr_codeController.dart';
class BarcodeScannerPage extends StatelessWidget {
  const BarcodeScannerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScannerController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: controller.toggleTorch,
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: controller.switchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller.scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;

              // Process only if we're still scanning
              if (!controller.isScanning.value) return;

              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;

                if (code != null) {
                  debugPrint('QR Code found! $code');
                  controller.processQRCode(code);
                  break;
                }
              }
            },
          ),

          // Scanning overlay
          Center(
            child: Obx(() => Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: controller.isScanning.value ? Colors.blue : Colors.green,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            )),
          ),

          // Status indicator
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  controller.isScanning.value ? 'Scanning...' : 'Processing...',
                  style: const TextStyle(color: Colors.white),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}