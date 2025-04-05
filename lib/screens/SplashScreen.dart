import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/AuthController.dart';
import 'Login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController authController =
  Get.put(AuthController());

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 3), () {
      checkLoginStatus();
    });
  }

  void checkLoginStatus() async {

    await authController.checkUserLoggedIn();


    if (authController.firebaseUser.value == null) {
      Get.off(() => Login());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/foodiespot.png',
              height: 120,
              width: 120,
            ),
            const SizedBox(height: 20),
            const Text(
              'FoodieSpot',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF9B43),
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9B43)),
            ),
          ],
        ),
      ),
    );
  }
}