import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable lists for different food categories
  final RxList<Map<String, dynamic>> popularFoods = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> newlyAdded = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> chefSpecials = <Map<String, dynamic>>[].obs;

  // Observable list for all foods (used for search)
  final RxList<Map<String, dynamic>> allFoods = <Map<String, dynamic>>[].obs;

  // Observable map for food categories (for category list)
  final RxMap<String, List<Map<String, dynamic>>> categories = <String, List<Map<String, dynamic>>>{}.obs;

  // Observable for search query and suggestions
  final RxString searchQuery = ''.obs;
  final RxList<Map<String, dynamic>> searchSuggestions = <Map<String, dynamic>>[].obs;
  final RxBool showSuggestions = false.obs;

  // Observable loading state
  final RxBool isLoading = true.obs;

  FoodController() {
    onInit();
  }

  @override
  void onInit() {
    super.onInit();
    fetchFoods();

    // Debounce search query for better performance
    debounce(
        searchQuery,
            (_) => updateSearchSuggestions(),
        time: const Duration(milliseconds: 300)
    );
  }

  // Fetch all foods from Firestore
  Future<void> fetchFoods() async {
    try {
      isLoading.value = true;

      // Get data from Firestore once
      final snapshot = await _firestore.collection('Foods').get();

      // Clear existing data
      popularFoods.clear();
      newlyAdded.clear();
      chefSpecials.clear();
      allFoods.clear();
      categories.clear();

      // Initialize categories map
      final Map<String, List<Map<String, dynamic>>> tempCategories = {};

      // Process each document
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data

        // Add to allFoods list
        allFoods.add(data);

        // Add to specific category
        final category = data['category'] as String;
        if (!tempCategories.containsKey(category)) {
          tempCategories[category] = [];
        }
        tempCategories[category]?.add(data);

        // Add to popular foods if applicable
        if (data['popular_food'] == true) {
          popularFoods.add(data);
        }

        // Add to newly added if applicable
        if (data['recent_added'] == true) {
          newlyAdded.add(data);
        }

        // Add to chef specials if applicable
        if (data['chef_special'] == true) {
          chefSpecials.add(data);
        }
        update();
      }

      // Update categories
      categories.value = tempCategories;

      // Update loading state
      isLoading.value = false;
    } catch (e) {
      print('Error fetching foods: $e');
      isLoading.value = false;

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to load food data. Please check your connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Get price for a specific food item - FIXED
  double getPrice(Map<String, dynamic> food) {
    // For pizza with different sizes
    if (food['category'] == 'pizza' && food['price'] is List && (food['price'] as List).isNotEmpty) {
      var firstPrice = food['price'][0];
      if (firstPrice is num) {
        return firstPrice.toDouble();
      } else if (firstPrice is String) {
        return double.tryParse(firstPrice) ?? 9.99;
      }
      return 9.99; // Default pizza price
    }
    // For single numeric price
    else if (food['price'] is num) {
      return (food['price'] as num).toDouble();
    }
    // For string price
    else if (food['price'] is String) {
      return double.tryParse(food['price']) ?? 8.99;
    }
    // For list of prices but not pizza
    else if (food['price'] is List && (food['price'] as List).isNotEmpty) {
      var firstPrice = food['price'][0];
      if (firstPrice is num) {
        return firstPrice.toDouble();
      } else if (firstPrice is String) {
        return double.tryParse(firstPrice) ?? 8.99;
      }
    }

    // Default price if price is missing or invalid
    if (food['category'] == 'burger') {
      return 7.99; // Default burger price
    } else if (food['category'] == 'salad' || food['category'] == 'healthy') {
      return 6.99; // Default salad price
    }

    return 5.99; // General default price
  }

  // Get size for pizza
  String getSize(Map<String, dynamic> food) {
    // Only for pizza
    if (food['category'] == 'pizza' && food['size'] is List && (food['size'] as List).isNotEmpty) {
      // Return the first size in the list (6 inches)
      return '${food['size'][0] ?? 6}" size';
    }
    return '';
  }

  // Get description for a food item with proper text handling
  String getDescription(Map<String, dynamic> food) {
    // First try desc field
    if (food['desc'] != null && food['desc'].toString().isNotEmpty) {
      return food['desc'].toString();
    }
    // Then try description field (alternative field name)
    else if (food['description'] != null && food['description'].toString().isNotEmpty) {
      return food['description'].toString();
    }

    // Fallback description based on category
    final category = food['category'].toString().toLowerCase();
    if (category == 'burger') {
      return 'Delicious burger with fresh ingredients and special sauce.';
    } else if (category == 'pizza') {
      return 'Authentic Italian pizza with premium toppings and melted cheese.';
    } else if (category == 'salad' || category == 'healthy') {
      return 'Fresh and healthy salad made with seasonal ingredients.';
    }

    // Very generic fallback
    return '${food['category']} speciality';
  }

  // Update search suggestions based on search query
  void updateSearchSuggestions() {
    if (searchQuery.value.isEmpty) {
      searchSuggestions.clear();
      showSuggestions.value = false;
    } else {
      final query = searchQuery.value.toLowerCase();
      searchSuggestions.value = allFoods.where((food) {
        final name = food['name'].toString().toLowerCase();
        final category = food['category'].toString().toLowerCase();
        return name.contains(query) || category.contains(query);
      }).toList();
      showSuggestions.value = searchSuggestions.isNotEmpty;
    }
  }

  // Method to handle search query changes
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Method to handle suggestion selection
  void selectSuggestion(Map<String, dynamic> suggestion) {
    searchQuery.value = suggestion['name'] as String;
    showSuggestions.value = false;
  }

  // Clear search
  void clearSearch() {
    searchQuery.value = '';
    searchSuggestions.clear();
    showSuggestions.value = false;
  }
}