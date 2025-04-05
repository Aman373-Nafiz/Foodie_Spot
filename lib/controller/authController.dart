import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:foodiespot/screens/Home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/Login.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find(); // Access controller anywhere
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxBool isPasswordVisible = false.obs; // Password visibility
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
      Get.to(() => RestaurantHomePage());
    }
  }

  // Toggle remember me value
  void toggleRememberMe(bool value) {
    rememberMe.value = value;
  }

  // Password Reset Function
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

      // Save user data including name
      await saveUserData(email, fullName);

      Get.snackbar(
          "Success",
          "Account created successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white
      );

      Get.offAll(() => RestaurantHomePage());
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

      // Fetch the user's name from SharedPreferences or use previously stored name
      String userName = await getUserNameByEmail(email);

      // Save user state with name
      await saveUserLoginState(email, userName);

      Get.snackbar(
          "Success",
          "Logged in successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white
      );

      Get.to(() => RestaurantHomePage()); // Navigate to Home using offAll
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

  // Save user data to SharedPreferences (including name)
  Future<void> saveUserData(String email, String fullName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', fullName);

    // Also save to email-based key for future logins
    await prefs.setString('userName_$email', fullName);
  }

  // Get user's name by email
  Future<String> getUserNameByEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Try to get the name specifically stored for this email
    String? name = prefs.getString('userName_$email');

    // If no name is found for this email, return default
    return name ?? 'User';
  }

  // Save user login state to SharedPreferences with name
  Future<void> saveUserLoginState(String email, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', name);
  }

  // Get user's name from SharedPreferences
  Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');

    if (email != null) {
      // Try to get name by email-specific key first
      String? nameByEmail = prefs.getString('userName_$email');
      if (nameByEmail != null && nameByEmail.isNotEmpty) {
        // If found, update the current userName for consistency
        await prefs.setString('userName', nameByEmail);
        return nameByEmail;
      }
    }

    // Fall back to regular userName
    return prefs.getString('userName') ?? 'User';
  }

  // Get user's email from SharedPreferences
  Future<String> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail') ?? 'user@example.com';
  }

  // Clear user login state
  Future<void> clearUserLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    // Note: We're intentionally NOT removing the email-specific userName entries
    // so they persist across logins
  }

  // Logout User
  Future<void> signOut() async {
    await _auth.signOut();
    await clearUserLoginState();
    Get.to(Login());
  }
}