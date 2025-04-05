import 'package:flutter/material.dart';
import 'package:foodiespot/screens/login.dart';
import 'package:get/get.dart';
import '../controller/AuthController.dart';
import '../widget/CustomInputField.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final FocusNode fullNameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  final RxBool isPasswordVisible = false.obs;
  bool agreeToTerms = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    fullNameFocus.dispose();
    emailFocus.dispose();
    phoneFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const ScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.078),
              child: Column(
                children: [
                  // Logo
                  Column(
                    children: [
                      const Icon(Icons.restaurant_menu,
                          color: Color(0xFFFF9B43), size: 60),
                      const SizedBox(height: 5),
                      const Text(
                        "FoodieSpot",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.028),

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Column(
                              children: [
                                Text(
                                  "Create Account",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Join us to explore amazing food",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 14),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Full Name
                          CustomInputField(
                            controller: fullNameController,
                            label: "Full Name",
                            icon: Icons.person,
                            hint: "Enter your full name",
                            focusNode: fullNameFocus,
                            nextFocusNode: emailFocus,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              if (value.length < 3) {
                                return 'Name must be at least 3 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          // Email
                          CustomInputField(
                            controller: emailController,
                            label: "Email Address",
                            icon: Icons.email,
                            hint: "Enter your email",
                            focusNode: emailFocus,
                            nextFocusNode: phoneFocus,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          // Password with toggle
                          Obx(() {
                            return CustomInputField(
                              controller: passwordController,
                              label: "Password",
                              icon: Icons.lock,
                              hint: "Enter your password",
                              focusNode: passwordFocus,
                              nextFocusNode: phoneFocus,
                              obscureText: !isPasswordVisible.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.black54,
                                ),
                                onPressed: () {
                                  isPasswordVisible.value =
                                  !isPasswordVisible.value;
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                            );
                          }),

                          const SizedBox(height: 10),

                          // Phone Number
                          CustomInputField(
                            controller: phoneNumberController,
                            label: "Phone Number",
                            icon: Icons.phone,
                            hint: "Enter phone number",
                            focusNode: phoneFocus,
                            nextFocusNode: null,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (!RegExp(r'^\+?[0-9]{8,15}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          // Terms and Conditions
                          Row(
                            children: [
                              Checkbox(
                                  value: agreeToTerms,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      agreeToTerms = value ?? false;
                                    });
                                  }),
                              Expanded(
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 13),
                                    children: [
                                      TextSpan(text: "I agree to the "),
                                      TextSpan(
                                        text: "Terms of Service",
                                        style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: " and "),
                                      TextSpan(
                                        text: "Privacy Policy",
                                        style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Create Account Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                if (_formKey.currentState!.validate()) {
                                  if (!agreeToTerms) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please agree to the Terms of Service and Privacy Policy'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  authController.signUp(
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                    fullNameController.text.trim(),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF9B43),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text(
                                "Create Account",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Already have an account? Log in
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Get.to(Login());
                              },
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                  children: [
                                    TextSpan(text: "Already have an account? "),
                                    TextSpan(
                                      text: "Log in",
                                      style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
