import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foodiespot/screens/Home.dart';
import 'package:foodiespot/screens/QrCodeScanner.dart';
import 'package:get/get.dart';
import 'package:foodiespot/screens/Login.dart';
import 'package:foodiespot/screens/Registration.dart';
import 'controller/AuthController.dart';
import 'screens/SplashScreen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    //options: DefaultFirebaseOptions.currentPlatform, // Initialize Firebase properly
  );



  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home:  BarcodeScannerPage(),
    );
  }
}