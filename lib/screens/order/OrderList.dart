import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/orderController.dart';
import '../../utils/constant.dart';
import 'OrderDetailScreen.dart';


class OrderListScreen extends StatelessWidget {
  OrderListScreen({Key? key}) : super(key: key);

  // Make sure we get the controller here
  final OrderController _orderController = Get.isRegistered<OrderController>()
      ? Get.find<OrderController>()
      : Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    // Fetch orders when the screen is opened
    // Force fetch orders when the screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _orderController.fetchUserOrders();
    });

    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading:false,
        backgroundColor: const Color(0xFFFF9B43),
        centerTitle: true,
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (_orderController.isLoadingOrders.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (_orderController.allOrders.isEmpty) {
          return _buildEmptyOrdersView();
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_orderController.activeOrders.isNotEmpty) ...[
                  const Text(
                    'Active Orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._orderController.activeOrders.map((order) => _buildOrderItem(order, true)),
                  const SizedBox(height: 24),
                ],
                if (_orderController.completedOrders.isNotEmpty) ...[
                  const Text(
                    'Past Orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._orderController.completedOrders.map((order) => _buildOrderItem(order, false)),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyOrdersView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order history will appear here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order, bool isActive) {
    // Get the first item image for display
    final items = order['items'] as List<dynamic>;
    String imageUrl = '';
    String mainItemName = '';

    if (items.isNotEmpty) {
      imageUrl = (items[0] as Map<String, dynamic>)['image'] as String? ?? '';
      mainItemName = (items[0] as Map<String, dynamic>)['name'] as String? ?? 'Unknown';
    }

    String orderStatus = order['order_status'] as String? ?? 'pending';
    Color statusColor;

    switch (orderStatus.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'in progress':
        statusColor = Colors.blue;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    String formattedDate = 'Processing';
    if (order['order_time'] != null) {
      final timestamp = order['order_time'];
      if (timestamp is DateTime) {
        formattedDate = '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Get.to(() => OrderDetailsScreen(order: order));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Order image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image, color: Colors.white),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Order details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order ID and Table
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order['order_id'] ?? ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Table ${order['table_nu'] ?? ''}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Main item
                    Text(
                      mainItemName,
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Status and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            orderStatus.capitalize ?? orderStatus,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        // Total price
                        Text(
                          '\$${(order['total_price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFFF9B43),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}