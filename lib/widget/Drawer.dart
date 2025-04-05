import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controller/AuthController.dart';
import '../utils/constant.dart';

Widget buildDrawer(BuildContext context) {
  final AuthController authController = Get.put(AuthController());
  return Drawer(
    child: FutureBuilder<String>(
      future: authController.getUserName(),
      builder: (context, snapshot) {
        // Get user name from snapshot (or use default if not loaded yet)
        String userName = snapshot.data ?? 'User';
        String initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

        return FutureBuilder<String>(
          future: authController.getUserEmail(),
          builder: (context, emailSnapshot) {

            String email = emailSnapshot.data ?? 'user@example.com';

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                // Drawer Header matching app bar
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // User email - now using the email from AuthController
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Drawer Items
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    // Close drawer
                    Navigator.pop(context);
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    // Close drawer first
                    Navigator.pop(context);

                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                authController.signOut(); // Call logout function
                              },
                              child: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    ),
  );
}
