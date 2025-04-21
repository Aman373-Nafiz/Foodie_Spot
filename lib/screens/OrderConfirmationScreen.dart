import 'package:flutter/material.dart';
import 'package:foodiespot/screens/MainScreen.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'Home.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderConfirmationScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(orderData['items']);
    final total = orderData['total_price'];
    final table = orderData['table_nu'];
    final status = orderData['order_status'];
    final orderId = orderData['order_id'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Confirmed"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Main scrollable content area
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text("Order Confirmed",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Text("Order ID: $orderId", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text("Table Number: $table"),
                    const SizedBox(height: 8),
                    Text("Status: $status"),
                    const Divider(height: 32),
                    const Text("Items:", style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    ...items.map((item) => ListTile(
                      leading: Image.network(item['image'],
                          width: 50, height: 50, fit: BoxFit.cover),
                      title: Text(item['name']),
                      subtitle: Text("Qty: ${item['quantity']}"),
                      trailing: Text("\$${item['price']}",
                          style: TextStyle(fontSize: 14)),
                    )),
                    const Divider(height: 36),
                    Text("Total Price: \$${total.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24), // Add some padding at the bottom
                  ],
                ),
              ),
            ),
          ),
          // Fixed bottom button that doesn't scroll
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                Get.offAll(MainScreen(), transition: Transition.fadeIn, duration: Duration(seconds: 1));
              },
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Center(
                    child: Text(
                      "Return",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                  )
              ),
            ),
          )
        ],
      ),
    );
  }
}