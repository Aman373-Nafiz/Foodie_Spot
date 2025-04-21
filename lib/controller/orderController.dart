import 'package:flutter/material.dart';
import 'package:foodiespot/controller/tableController.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../screens/OrderConfirmationScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  // For order placement
  final Rx<Map<String, dynamic>> mainFoodItem = Rx<Map<String, dynamic>>({});
  final RxList<Map<String, dynamic>> additionalItems = <Map<String, dynamic>>[].obs;
  final RxInt mainItemQuantity = 1.obs;
  final RxMap<String, int> additionalItemQuantities = <String, int>{}.obs;
  final RxString selectedTable = ''.obs;
  // Replace single selection with a set of selected IDs
  final RxSet<String> selectedAddonIds = <String>{}.obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> popularAdditionalItems = <Map<String, dynamic>>[].obs;

  // For managing pizza sizes for additional items
  final RxMap<String, String> additionalItemSizes = <String, String>{}.obs;

  // For tracking current prices of additional items
  final RxMap<String, double> additionalItemCurrentPrices = <String, double>{}.obs;

  // For managing main item pizza size
  final RxString mainItemSize = 'Small'.obs;
  final RxDouble mainItemCurrentPrice = 0.0.obs;

  // For orders list
  final RxList<Map<String, dynamic>> allOrders = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingOrders = false.obs;
  final RxBool hasActiveOrders = false.obs;
  final RxInt activeOrdersCount = 0.obs;

  // Current user UID
  final RxString currentUserUID = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Get the current user's UID
    _loadCurrentUserUID();
    // Initial fetch of orders when app starts
    fetchUserOrders();
    // Set up listener for real-time updates
    _setupOrdersListener();
  }

  // Load the current user's UID from SharedPreferences
  Future<void> _loadCurrentUserUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('userUID');
    if (uid != null && uid.isNotEmpty) {
      currentUserUID.value = uid;
    }
  }

  // Getter for active orders
  RxList<Map<String, dynamic>> get activeOrders => allOrders
      .where((order) =>
  order['order_status'] != 'completed' && order['order_status'] != 'cancelled')
      .toList()
      .obs;

  // Getter for completed orders
  RxList<Map<String, dynamic>> get completedOrders => allOrders
      .where((order) => order['order_status'] == 'completed')
      .toList()
      .obs;

  // Initialize for food item order
  void initialize(Map<String, dynamic> foodItem) {
    // Clear previous state
    mainFoodItem.value = {};
    additionalItems.clear();
    mainItemQuantity.value = 1;
    additionalItemQuantities.clear();
    selectedTable.value = '';
    selectedAddonIds.clear(); // Clear the set of selected IDs
    additionalItemSizes.clear();
    additionalItemCurrentPrices.clear();
    popularAdditionalItems.clear();

    // Now initialize with new food item
    mainFoodItem.value = Map<String, dynamic>.from(foodItem);
    final TableController tableController = Get.find<TableController>();
    if (tableController.tableNumbers.isNotEmpty) {
      selectedTable.value = tableController.tableNumbers[0];
    }

    // Initialize main food item price based on size if it's a pizza
    if (isPizza(foodItem)) {
      mainItemSize.value = foodItem['selected_size'] ?? 'Small';
      if (foodItem['price'] is List && (foodItem['price'] as List).isNotEmpty) {
        mainItemCurrentPrice.value = _parsePrice(foodItem['display_price']) > 0
            ? _parsePrice(foodItem['display_price'])
            : _getPriceForSizeAsDouble(foodItem, mainItemSize.value);
        mainFoodItem.update((val) {
          val!['display_price'] = mainItemCurrentPrice.value.toStringAsFixed(2);
          val['selected_size'] = mainItemSize.value;
        });

      } else {
        mainItemCurrentPrice.value = _parsePrice(foodItem['price']);
        mainFoodItem.update((val) {
          val!['display_price'] = mainItemCurrentPrice.value.toStringAsFixed(2);
          val['selected_size'] = mainItemSize.value;
        });
      }
    } else {
      // For non-pizza items
      mainItemCurrentPrice.value = _parsePrice(foodItem['price']);
      mainFoodItem.update((val) {
        val!['display_price'] = mainItemCurrentPrice.value.toStringAsFixed(2);
      });
    }

    fetchPopularAdditionalItems();
  }

  Future<void> fetchPopularAdditionalItems() async {
    try {
      final snapshot = await _firestore.collection('Foods').get();
      List<Map<String, dynamic>> items = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        //if (data['name'] == mainFoodItem.value['name']) continue;
        data['id'] = doc.id;
        items.add(data);
        additionalItemQuantities[doc.id] = 1;

        // Initialize the size for pizza items
        if (isPizza(data)) {
          additionalItemSizes[doc.id] = 'Small';

          // Initialize price based on size
          if (data['price'] is List && (data['price'] as List).isNotEmpty) {
            additionalItemCurrentPrices[doc.id] = _parsePrice((data['price'] as List)[0]);
          }
        } else {
          // For non-pizza items
          additionalItemCurrentPrices[doc.id] = _parsePrice(data['price']);
        }
      }

      popularAdditionalItems.value = items;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load additional items',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Check if item is a pizza
  bool isPizza(Map<String, dynamic> item) {
    return item['category'].toString().toLowerCase() == 'pizza';
  }

  // Modified to toggle an item in the set instead of replacing
  void toggleAdditionalItem(Map<String, dynamic> item) {
    final id = item['id'] as String;

    if (selectedAddonIds.contains(id)) {
      // Remove item if already selected
      selectedAddonIds.remove(id);
      additionalItems.removeWhere((element) => element['id'] == id);
    } else {
      // Add item if not selected
      selectedAddonIds.add(id);
      additionalItems.add(Map<String, dynamic>.from(item));
      additionalItemQuantities[id] = 1;

      // Initialize size and price for pizza items
      if (isPizza(item)) {
        additionalItemSizes[id] = 'Small';

        // Set initial price based on size
        if (item['price'] is List && (item['price'] as List).isNotEmpty) {
          additionalItemCurrentPrices[id] = _parsePrice((item['price'] as List)[0]);
        } else {
          additionalItemCurrentPrices[id] = _parsePrice(item['price']);
        }
      } else {
        // For non-pizza items, set the regular price
        additionalItemCurrentPrices[id] = _parsePrice(item['price']);
      }
    }

    update();
  }

  // Helper method to parse price from various formats
  double _parsePrice(dynamic priceValue) {
    if (priceValue == null) return 0.0;

    if (priceValue is num) {
      return priceValue.toDouble();
    } else if (priceValue is String) {
      return double.tryParse(priceValue.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
    } else if (priceValue is List && priceValue.isNotEmpty) {
      return _parsePrice(priceValue[0]);
    }
    return 0.0;
  }

  // Update size for main food item (if it's a pizza)
  void setMainItemSize(String size) {
    if (isPizza(mainFoodItem.value)) {
      mainItemSize.value = size;
      mainItemCurrentPrice.value = _getPriceForSizeAsDouble(mainFoodItem.value, size);


      mainFoodItem.update((val) {
        val!['display_price'] = mainItemCurrentPrice.value.toStringAsFixed(2);
        val['selected_size'] = size;
      });

      update();
    }
  }

  // Update size for additional item
  void setAdditionalItemSize(String itemId, String size) {
    additionalItemSizes[itemId] = size;

    final item = popularAdditionalItems.firstWhere(
          (element) => element['id'] == itemId,
      orElse: () => {},
    );

    if (item.isNotEmpty) {
      if (isPizza(item)) {
        additionalItemCurrentPrices[itemId] = _getPriceForSizeAsDouble(item, size);
      } else {
        additionalItemCurrentPrices[itemId] = _parsePrice(item['price']);
      }

      // Update the size and price in the additionalItems list
      for (int i = 0; i < additionalItems.length; i++) {
        if (additionalItems[i]['id'] == itemId) {
          additionalItems[i]['selected_size'] = size;
          additionalItems[i]['display_price'] = additionalItemCurrentPrices[itemId];
        }
      }

      update();
    }
  }

  // Get the current size for the main item
  String getMainItemSize() {
    return mainItemSize.value;
  }

  // Get the current size for an additional item
  String getAdditionalItemSize(String itemId) {
    return additionalItemSizes[itemId] ?? 'Small';
  }

  // Get the current price for the main item as a formatted string
  String getMainItemPrice() {
    return mainItemCurrentPrice.value.toStringAsFixed(2);
  }

  // Get the current price for an additional item as a formatted string
  String getCurrentItemPrice(String itemId) {
    double price = additionalItemCurrentPrices[itemId] ?? 0.0;
    return price.toStringAsFixed(2);
  }

  // Get price based on size for pizza items as a formatted string
  String getPriceForSize(Map<String, dynamic> item, String size) {
    double price = _getPriceForSizeAsDouble(item, size);
    return price.toStringAsFixed(2);
  }

  // Get price based on size for pizza items as a double
  double _getPriceForSizeAsDouble(Map<String, dynamic> item, String size) {
    if (!isPizza(item)) {
      // For non-pizza items, return regular price
      return _parsePrice(item['price']);
    }

    // For pizza items
    if (item['price'] is List) {
      final List<dynamic> prices = item['price'] as List;

      switch (size) {
       // case "Small":
        case "6":
          return prices.length > 0 ? _parsePrice(prices[0]) : 15.00; // Default price for small
       // case "Medium":
        case "9":
          return prices.length > 1 ? _parsePrice(prices[1]) : 17.50; // Default price for medium
        //case "Large":
        case "12":
          return prices.length > 2 ? _parsePrice(prices[2]) : 21.70; // Default price for large
        default:
          return prices.length > 0 ? _parsePrice(prices[0]) : 15.00; // Default to small
      }
    }

    // Fallback default prices if price list is not available
    switch (size) {
      case 'Small':
        return 15.00; // 6" pizza
      case 'Medium':
        return 17.50; // 9" pizza
      case 'Large':
        return 21.70; // 12" pizza
      default:
        return 15.00;
    }
  }

  // Check if an item is selected
  bool isItemSelected(String itemId) {
    return selectedAddonIds.contains(itemId);
  }

  void incrementMainItemQuantity() {
    if (mainItemQuantity.value < 10) {
      mainItemQuantity.value++;
    }
  }

  void decrementMainItemQuantity() {
    if (mainItemQuantity.value > 1) {  // Changed from 0 to 1 to prevent ordering 0 items
      mainItemQuantity.value--;
    }
  }

  void incrementAdditionalItemQuantity(String itemId) {
    if ((additionalItemQuantities[itemId] ?? 1) < 10) {
      additionalItemQuantities[itemId] = (additionalItemQuantities[itemId] ?? 1) + 1;
    }
  }

  void decrementAdditionalItemQuantity(String itemId) {
    if ((additionalItemQuantities[itemId] ?? 1) > 1) {
      additionalItemQuantities[itemId] = (additionalItemQuantities[itemId] ?? 1) - 1;
    }
  }

  void setSelectedTable(String tableNumber) {
    selectedTable.value = tableNumber;
    update();
  }

  double calculateTotalPrice() {
    double total = 0.0;

    total += mainItemCurrentPrice.value * mainItemQuantity.value;

    for (var item in additionalItems) {
      String itemId = item['id'];
      double itemPrice = additionalItemCurrentPrices[itemId] ?? 0.0;
      int quantity = additionalItemQuantities[itemId] ?? 1;
      total += itemPrice * quantity;
    }

    return total;
  }

  Future<void> placeOrder() async {
    if (selectedTable.value.isEmpty) {
      Get.snackbar('Error', 'Please select a table number',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // Load user UID again if needed
      if (currentUserUID.value.isEmpty) {
        await _loadCurrentUserUID();
      }

      // Generate a new UUID for this order
      final String orderId = _uuid.v4().substring(0,4) ;

      // Build the list of ordered items
      List<Map<String, dynamic>> orderItems = [];

      // Add main item
      orderItems.add({
        'id': mainFoodItem.value['id'] ?? orderId,
        'name': mainFoodItem.value['name'],
        'price': mainItemCurrentPrice.value.toStringAsFixed(2),
        'quantity': mainItemQuantity.value,
        'size': isPizza(mainFoodItem.value) ? mainItemSize.value : null,
        'image': mainFoodItem.value['image'],
      });

      // Add additional items
      for (var item in additionalItems) {
        String itemId = item['id'];
        String size = additionalItemSizes[itemId] ?? 'Small';
        double price = additionalItemCurrentPrices[itemId] ?? 0.0;

        orderItems.add({
          'id': itemId,
          'name': item['name'],
          'price': price.toStringAsFixed(2),
          'quantity': additionalItemQuantities[itemId] ?? 1,
          'size': isPizza(item) ? size : null,
          'image': item['image'],
        });
      }

      // Order document data with user_id added
      final orderData = {
        'order_id': orderId,
        'table_nu': selectedTable.value,
        'order_status': 'pending',
        'order_time': FieldValue.serverTimestamp(),
        'total_price': calculateTotalPrice(),
        'items': orderItems,
        'user_id': currentUserUID.value,
      };

      // Debug print to verify data
      print('Placing order with ID: $orderId, User: ${currentUserUID.value}');

      // Set the document with the orderId
      await _firestore.collection('Orders').doc(orderId).set(orderData);

      isLoading.value = false;

      // Reset order data AFTER successful submission
      Get.offAll(() => OrderConfirmationScreen(orderData: orderData));

      // Fetch orders after placing a new one
      fetchUserOrders();

      // Reset the controller state for next order
      _resetOrderState();

    } catch (e) {
      isLoading.value = false;
      print('Error placing order: $e');
      Get.snackbar('Error', 'Failed to place order: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Add a helper method to reset the state
  void _resetOrderState() {
    mainFoodItem.value = {};
    additionalItems.clear();
    mainItemQuantity.value = 1;
    additionalItemQuantities.clear();
    selectedTable.value = '';
    selectedAddonIds.clear(); // Clear the set of selected IDs
  }

  // Fetch orders for the current user only
  Future<void> fetchUserOrders() async {
    try {
      isLoadingOrders.value = true;

      // Make sure we have the current user's UID
      if (currentUserUID.value.isEmpty) {
        await _loadCurrentUserUID();
      }

      print('Fetching orders for user: ${currentUserUID.value}');

      // If still no UID, show empty orders
      if (currentUserUID.value.isEmpty) {
        print('No user UID available, showing empty orders');
        allOrders.clear();
        activeOrdersCount.value = 0;
        hasActiveOrders.value = false;
        isLoadingOrders.value = false;
        return;
      }

      // Query orders for the current user only
      final snapshot = await _firestore.collection('Orders')
          .where('user_id', isEqualTo: currentUserUID.value)
          .get();

      List<Map<String, dynamic>> orders = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['order_id'] = data['order_id'] ?? doc.id;

        // Only include orders for this user
        String orderUserId = data['user_id'] ?? '';
        if (orderUserId != currentUserUID.value) {
          continue;
        }

        // Process timestamps
        if (data['order_time'] is Timestamp) {
          data['order_time'] = (data['order_time'] as Timestamp).toDate();
        }

        orders.add(data);
        print('Found order: ${data['order_id']} for user $orderUserId');
      }

      // Sort by date (newest first)
      orders.sort((a, b) {
        var aTime = a['order_time'];
        var bTime = b['order_time'];

        // Handle null or different types
        if (aTime == null) return 1;
        if (bTime == null) return -1;

        return bTime.compareTo(aTime);
      });

      // Update the orders list
      allOrders.value = orders;

      // Update active orders count
      activeOrdersCount.value = orders.where((order) =>
      order['order_status'] != 'completed' &&
          order['order_status'] != 'cancelled').length;

      hasActiveOrders.value = activeOrdersCount.value > 0;

      isLoadingOrders.value = false;

      print('Fetched ${orders.length} orders, ${activeOrdersCount.value} active');

    } catch (e) {
      isLoadingOrders.value = false;
      print('Error fetching orders: $e');
      Get.snackbar('Error', 'Failed to load orders',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Set up real-time listener for orders, filtplaceered by current user
  // Set up real-time listener for orders, filtered by current user
  void _setupOrdersListener() {
    // First, load the current user's UID
    _loadCurrentUserUID().then((_) {
      print('Setting up orders listener for user: ${currentUserUID.value}');

      // Only set up the listener if we have a UID
      if (currentUserUID.value.isNotEmpty) {
        _firestore.collection('Orders')
            .snapshots()
            .listen((snapshot) {
          // Don't filter in the query, instead update all orders and filter in getters
          fetchUserOrders();
        }, onError: (error) {
          print('Error in orders listener: $error');
        });
      } else {
        print('Cannot set up orders listener: No user UID available');
      }
    });
  }

  // Cancel an order
  Future<void> cancelOrder(String orderId) async {
    try {
      isLoading.value = true;

      await _firestore.collection('Orders').doc(orderId).update({
        'order_status': 'cancelled',
        'cancelled_at': FieldValue.serverTimestamp(),
      });

      isLoading.value = false;
      Get.snackbar('Success', 'Order cancelled successfully',
          backgroundColor: Colors.green, colorText: Colors.white);

      // Update orders list
      fetchUserOrders();
    } catch (e) {
      isLoading.value = false;
      print('Error cancelling order: $e');
      Get.snackbar('Error', 'Failed to cancel order',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Track order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('Orders').doc(orderId).update({
        'order_status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Refresh orders list
      fetchUserOrders();
    } catch (e) {
      print('Error updating order status: $e');
      Get.snackbar('Error', 'Failed to update order status',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Get a specific order
  Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
    try {
      final doc = await _firestore.collection('Orders').doc(orderId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting order details: $e');
      return null;
    }
  }

  @override
  void onClose() {
    // Cleanup if needed
    super.onClose();
  }
}