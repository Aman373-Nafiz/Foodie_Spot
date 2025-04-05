import 'package:flutter/material.dart';
import 'package:foodiespot/utils/constant.dart';
import 'package:get/get.dart';
import '../controller/AuthController.dart';
import '../widget/CustomButton.dart';
import '../widget/CustomTextField.dart';
import '../utils/validators.dart';
import 'Registration.dart';


class Login extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isPasswordVisible = false.obs;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.11),

                // Logo
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/foodiespot.png',
                      height: screenHeight * 0.11,
                      width: screenHeight * 0.11,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // Welcome Text
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.007),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black45
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),


                CustomTextField(
                  controller: emailController,
                  label: "Email",
                  icon: Icons.email_outlined,
                  isObscure: false,
                  validator: Validators.validateEmail,
                ),

                SizedBox(height: screenHeight * 0.023),


                Obx(() => CustomPasswordField(
                  controller: passwordController,
                  label: "Password",
                  icon: Icons.lock_outline,
                  isObscure: !isPasswordVisible.value,
                  validator: Validators.validatePassword,
                  onToggleVisibility: () {
                    isPasswordVisible.value = !isPasswordVisible.value;
                  },
                )),

                SizedBox(height: screenHeight * 0.012),

                // Remember Me + Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Obx(() => Checkbox(
                          value: authController.rememberMe.value,
                          onChanged: (value) {
                            authController.toggleRememberMe(value!);
                          },
                        )),
                        Text(
                          'Remember me',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _showForgotPasswordDialog(context),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.046),

                // Sign In Button
                Center(
                  child: CustomButton(
                    text: "Sign in",
                    color: AppColors.primary,
                    width: screenWidth * 0.9,
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        authController.signIn(
                            emailController.text.trim(),
                            passwordController.text.trim()
                        );
                      }
                    },
                  ),
                ),

                SizedBox(height: 10),

                // Sign Up Navigation
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => Registration());
                    },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 14),
                        children: [
                          TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: AppColors.textPrimary)
                          ),
                          TextSpan(
                            text: "Sign up",
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController resetEmailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
              'Reset Password',
              style: TextStyle(fontWeight: FontWeight.bold)
          ),
          content: Container(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter your email address to receive a password reset link',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: resetEmailController,
                    validator: Validators.validateEmail,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  authController.resetPassword(resetEmailController.text.trim());
                }
              },
              child: Text(
                'Reset',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}