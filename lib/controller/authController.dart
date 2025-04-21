import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:foodiespot/screens/Home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/Login.dart';
import '../screens/MainScreen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxBool isPasswordVisible = false.obs;
  RxBool rememberMe = false.obs;

  Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    checkUserLoggedIn();
  }

  Future<void> checkUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? savedEmail = prefs.getString('userEmail');

    if (isLoggedIn && savedEmail != null) {
      firebaseUser.value = _auth.currentUser;
      Get.to(() =>  MainScreen());
    }
  }

  void toggleRememberMe(bool value) {
    rememberMe.value = value;
  }

  Future<void> resetPassword(String email) async {
    try {
      if (!GetUtils.isEmail(email)) {
        Get.snackbar(
            "Error",
            "Please enter a valid email address",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white
        );
        return;
      }

      await _auth.sendPasswordResetEmail(email: email);

      Get.snackbar(
          "Success",
          "Password reset link sent to $email",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 5)
      );
    } catch (e) {
      String errorMessage = "Failed to send password reset email";

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = "No user found with this email";
            break;
          case 'invalid-email':
            errorMessage = "Invalid email format";
            break;
          default:
            errorMessage = e.message ?? errorMessage;
        }
      }

      Get.snackbar(
          "Error",
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
    }
  }

  Future<void> signUp(String email, String password, String fullName) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      // Also save the user's UID
      await saveUserData(email, fullName, userCredential.user?.uid);

      Get.snackbar(
          "Success",
          "Account created successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white
      );

      Get.offAll(() => MainScreen());
    } catch (e) {
      Get.snackbar(
          "Error",
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );

      String userName = await getUserNameByEmail(email);

      // Also save the user's UID
      await saveUserLoginState(email, userName, userCredential.user?.uid);

      Get.snackbar(
          "Success",
          "Logged in successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white
      );

      Get.to(() => MainScreen());
    } catch (e) {
      Get.snackbar(
          "Error",
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
    }
  }

  // Updated to also save UID
  Future<void> saveUserData(String email, String fullName, String? uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', fullName);
    if (uid != null) {
      await prefs.setString('userUID', uid);
    }

    await prefs.setString('userName_$email', fullName);
  }

  Future<String> getUserNameByEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('userName_$email');

    return name ?? 'User';
  }

  // Updated to also save UID
  Future<void> saveUserLoginState(String email, String name, String? uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', name);
    if (uid != null) {
      await prefs.setString('userUID', uid);
    }
  }

  Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');

    if (email != null) {
      String? nameByEmail = prefs.getString('userName_$email');
      if (nameByEmail != null && nameByEmail.isNotEmpty) {
        // If found, update the current userName for consistency
        await prefs.setString('userName', nameByEmail);
        return nameByEmail;
      }
    }

    return prefs.getString('userName') ?? 'User';
  }

  Future<String> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail') ?? 'user@example.com';
  }

  // New method to get user UID
  Future<String?> getUserUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userUID');
  }

  Future<void> clearUserLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    await prefs.remove('userUID');
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await clearUserLoginState();
    Get.to(Login());
  }
}