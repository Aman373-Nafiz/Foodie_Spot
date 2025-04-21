import 'package:flutter/material.dart';
import 'package:foodiespot/controller/orderController.dart';
import 'package:get/get.dart';
import '../controller/AuthController.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final AuthController _authController = Get.find<AuthController>();
  final OrderController orderController = Get.find< OrderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading:false,
        backgroundColor: const Color(0xFFFF9B43),
        centerTitle: true,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
              color: Color(0xFFFF9B43),
            ));
          }

          if (snapshot.hasError) {
            return Center(child: Text(
              'Error loading profile data',
              style: TextStyle(color: Colors.red[700]),
            ));
          }

          final userData = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // User Avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFFF9B43),
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    userData['name'] ?? 'Foodie User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    userData['email'] ?? 'user@example.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Order Statistics
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF9B43),
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildOrderStatRow('Total Orders', userData['totalOrders'] ?? '0'),
                          const Divider(),
                          _buildOrderStatRow('Active Orders', userData['activeOrders'] ?? '0',
                              iconColor: Colors.green),
                          const Divider(),
                          _buildOrderStatRow('Past Orders', userData['pastOrders'] ?? '0',
                              iconColor: Colors.blue),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // User Information
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF9B43),
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildInfoRow('Name', userData['name'] ?? 'Not set', Icons.person),
                          const Divider(),
                          _buildInfoRow('Email', userData['email'] ?? 'Not set', Icons.email),

                          //_buildInfoRow('Phone', userData['phone'] ?? 'Not set', Icons.phone),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 46),

                  // Logout Button
                  ElevatedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9B43),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadUserData() async {
    final name = await _authController.getUserName();
    final email = await _authController.getUserEmail();
    final activeOrders = orderController.activeOrders.length;  // Mock data
    final pastOrders = orderController.completedOrders.length;
    final totalOrders = activeOrders+pastOrders;// Mock data
    //final phone = '+1 (555) 123-4567'; // Mock data or implement getUserPhone() method

    return {
      'name': name,
      'email': email,
      'totalOrders': totalOrders.toString(),
      'activeOrders': activeOrders.toString(),
      'pastOrders': pastOrders.toString(),
      //'phone': phone,
    };
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFFF9B43),
            size: 22,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatRow(String label, String value, {Color iconColor = Colors.amber}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            label.contains('Active') ? Icons.pending_actions :
            label.contains('Past') ? Icons.history : Icons.shopping_bag,
            color: iconColor,
            size: 22,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _authController.signOut();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}