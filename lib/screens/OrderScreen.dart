import 'package:flutter/material.dart';
import 'package:foodiespot/screens/Home.dart';
import 'package:foodiespot/screens/MainScreen.dart';
import 'package:get/get.dart';
import '../controller/orderController.dart';
import '../controller/tableController.dart';

class OrderScreen extends StatelessWidget {
  final Map<String, dynamic> foodItem;
  final OrderController orderController;
  final TableController tableController;

  OrderScreen({Key? key, required this.foodItem}) :
        orderController = Get.isRegistered<OrderController>()
            ? Get.find<OrderController>()
            : Get.put(OrderController()),
        tableController = Get.isRegistered<TableController>()
            ? Get.find<TableController>()
            : Get.put(TableController()),
        super(key: key) {

    // First, fetch table numbers independently of food item initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Make sure tables are fetched before anything else
      tableController.fetchTableNumbers().then((_) {
        // Only after tables are fetched, initialize food item
        orderController.initialize(foodItem);

        // If there's no selected table but tables are available, select the first one
        if (orderController.selectedTable.value.isEmpty &&
            tableController.tableNumbers.isNotEmpty) {
          orderController.setSelectedTable(tableController.tableNumbers[0]);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>MainScreen())),
        ),
        title: const Text('Order Details', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Obx(() {
        // Show loading indicator while waiting for tables to load
        // if (tableController.isLoading.value) {
        //   // return const Center(
        //   //   child: CircularProgressIndicator(color: Colors.orange),
        //   // );
        // }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show table selection at the top, before the food item
                  _buildMainFoodItem(orderController, foodItem),
                  const SizedBox(height: 24),
                  _buildTableSelection(orderController),

                  const SizedBox(height: 24),
                  _buildAdditionalItems(orderController),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)],
                ),
                child: ElevatedButton(
                  onPressed: orderController.isLoading.value
                      ? null
                      : () => orderController.placeOrder(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: orderController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Confirm Order - \$${orderController.calculateTotalPrice().toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMainFoodItem(OrderController controller, Map<String, dynamic> foodItem) {
    // Existing code...
    final name = foodItem['name'] as String? ?? 'Food Item';
    final description = foodItem['desc'] as String? ?? 'Delicious food item';
    final imageUrl = foodItem['image'] as String? ?? '';
    final price = controller.getMainItemPrice();
    final selectedSize = controller.getMainItemSize();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food image and name
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.restaurant, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description.length > 80
                          ? '${description.substring(0, 80)}...'
                          : description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$$price',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        if (selectedSize.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                selectedSize,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => controller.decrementMainItemQuantity(),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.remove, color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${controller.mainItemQuantity.value}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => controller.incrementMainItemQuantity(),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  Widget _buildTableSelection(OrderController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Table Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Obx(() {
          if (tableController.tableNumbers.isEmpty) {
            return Column(
              children: [
                //const Center(child: Text('No tables available', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => tableController.fetchTableNumbers(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Refresh Tables'),
                ),
              ],
            );
          }

          return SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tableController.tableNumbers.length,
              itemBuilder: (context, index) {
                final table = tableController.tableNumbers[index];

                return Obx(() {
                  final isSelected = controller.selectedTable.value == table;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => controller.setSelectedTable(table),
                      child: Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange : Colors.white,
                          border: Border.all(color: isSelected ? Colors.orange : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          table,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          );
        }),
      ],
    );
  }


  // Rest of the widget methods remain the same...
  Widget _buildSizeSelector(String itemId, Map<String, dynamic> item, OrderController controller) {
    // Existing code...
    List<String> sizes = ['Small', 'Medium', 'Large'];
    if (item['size'] != null && item['size'] is List) {
      sizes = (item['size'] as List).map((e) => e.toString()).toList();
    }

    final currentSize = controller.getAdditionalItemSize(itemId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Size', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: sizes.map((size) {
            final isSelected = currentSize == size;

            return GestureDetector(
              onTap: () {
                controller.setAdditionalItemSize(itemId, size);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange : Colors.white,
                  border: Border.all(color: isSelected ? Colors.orange : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdditionalItems(OrderController controller) {
    // Existing code...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add More Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.popularAdditionalItems.length,
          itemBuilder: (context, index) {
            final item = controller.popularAdditionalItems[index];
            final itemId = item['id'];
            final isSelected = controller.selectedAddonIds.contains(itemId);
            final isPizza = controller.isPizza(item);

            String priceStr = '';
            if (isPizza) {
              final size = controller.getAdditionalItemSize(itemId);
              priceStr = '\$${controller.getPriceForSize(item, size)}';
            } else {
              // For non-pizza items
              if (item['price'] is num) {
                priceStr = '\$${(item['price'] as num).toStringAsFixed(2)}';
              } else if (item['price'] is String) {
                priceStr = '\$${item['price']}';
              } else if (item['price'] is List && (item['price'] as List).isNotEmpty) {
                final first = (item['price'] as List)[0];
                priceStr = '\$${first is num ? first.toStringAsFixed(2) : first}';
              } else {
                priceStr = '\$0.00';
              }
            }

            return GestureDetector(
              onTap: () => controller.toggleAdditionalItem(item),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: isSelected ? Colors.orange : Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['image'] ?? '',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.restaurant, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  Text(
                                      isSelected ?
                                      '\$${controller.getCurrentItemPrice(itemId)}' :
                                      priceStr,
                                      style: const TextStyle(color: Colors.orange)
                                  ),
                                  if (isPizza && isSelected)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          controller.getAdditionalItemSize(itemId),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (item['category'] != null)
                                Text(
                                  item['category'],
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (!isSelected)
                          IconButton(
                            onPressed: () => controller.toggleAdditionalItem(item),
                            icon: const Icon(Icons.add_circle_outline, color: Colors.orange),
                          )
                        else
                          IconButton(
                            onPressed: () => controller.toggleAdditionalItem(item),
                            icon: const Icon(Icons.check_circle, color: Colors.orange),
                          ),
                      ],
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      // Size selector for pizza items
                      if (isPizza) ...[
                        _buildSizeSelector(itemId, item, controller),
                        const SizedBox(height: 12),
                      ],
                      // Quantity selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Quantity:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => controller.decrementAdditionalItemQuantity(itemId),
                                icon: _quantityButton(Icons.remove),
                              ),
                              Text(
                                '${controller.additionalItemQuantities[itemId] ?? 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                onPressed: () => controller.incrementAdditionalItemQuantity(itemId),
                                icon: _quantityButton(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}