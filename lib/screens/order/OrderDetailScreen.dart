import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/orderController.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  final OrderController _orderController = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = order['items'] as List<dynamic>? ?? [];
    final String orderStatus = order['order_status'] as String? ?? 'pending';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9B43),
        title: Text('Order #${order['order_id'] ?? ''}',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderStatusCard(orderStatus),
            const SizedBox(height: 16),
            _buildOrderSummary(),
            const SizedBox(height: 24),
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => _buildOrderItemCard(item)),
            const SizedBox(height: 24),
            _buildPriceDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard(String status) {
    IconData statusIcon;
    String statusText;
    Color statusColor;

    switch (status.toLowerCase()) {
      case 'pending':
        statusIcon = Icons.hourglass_empty;
        statusText = 'Your order is pending';
        statusColor = Colors.orange;
        break;
      case 'in progress':
        statusIcon = Icons.restaurant;
        statusText = 'Your order is being prepared';
        statusColor = Colors.blue;
        break;
      case 'completed':
        statusIcon = Icons.check_circle;
        statusText = 'Your order has been completed';
        statusColor = Colors.green;
        break;
      default:
        statusIcon = Icons.info;
        statusText = 'Order status: $status';
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: statusColor,
                  ),
                ),
                if (status.toLowerCase() == 'pending' || status.toLowerCase() == 'in progress')
                  const SizedBox(height: 4),
                 if (status.toLowerCase() == 'pending' )
                   Text(
                     'Estimated time: 15-30 minutes',
                     style: TextStyle(
                       color: Colors.grey[700],
                       fontSize: 14,
                     ),
                   ),
                if( status.toLowerCase() == 'in progress')
                  Text(
                    'Estimated time: 10-20 minutes',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    String formattedDate = 'Processing';
    if (order['order_time'] != null) {
      final timestamp = order['order_time'];
      if (timestamp is DateTime) {
        formattedDate = '${timestamp.day}/${timestamp.month}/${timestamp.year}, ${timestamp.hour}:${timestamp.minute}';
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow('Order ID', '#${order['order_id'] ?? ''}'),
            const Divider(),
            _buildSummaryRow('Table Number', order['table_nu'] ?? ''),
            const Divider(),
            _buildSummaryRow('Order Date', formattedDate),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(dynamic item) {
    final Map<String, dynamic> foodItem = item as Map<String, dynamic>;
    final String name = foodItem['name'] ?? 'Item';
    final String image = foodItem['image'] ?? '';
    final String price = (foodItem['price'] ?? '0.00').toString();
    final int quantity = foodItem['quantity'] ?? 1;
    final String size = foodItem['size'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                image,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (size.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Size: $size',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$quantity x \$$price',
                        style: TextStyle(
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        '\$${(double.tryParse(price.replaceAll('\$', '')) ?? 0 * quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildPriceDetails() {
    final double totalPrice = (order['total_price'] as num?)?.toDouble() ?? 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text('\$${(totalPrice ).toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),

            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9B43),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}