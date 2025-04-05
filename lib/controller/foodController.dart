import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  final RxList<Map<String, dynamic>> popularFoods = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> newlyAdded = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> chefSpecials = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> allFoods = <Map<String, dynamic>>[].obs;
  final RxMap<String, List<Map<String, dynamic>>> categories = <String, List<Map<String, dynamic>>>{}.obs;
  final RxString searchQuery = ''.obs;
  final RxList<Map<String, dynamic>> searchSuggestions = <Map<String, dynamic>>[].obs;
  final RxBool showSuggestions = false.obs;


  final RxBool isLoading = true.obs;

  FoodController() {
    onInit();
  }

  @override
  void onInit() {
    super.onInit();
    fetchFoods();

    debounce(
        searchQuery,
            (_) => updateSearchSuggestions(),
        time: const Duration(milliseconds: 300)
    );
  }


  Future<void> fetchFoods() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore.collection('Foods').get();
      popularFoods.clear();
      newlyAdded.clear();
      chefSpecials.clear();
      allFoods.clear();
      categories.clear();


      final Map<String, List<Map<String, dynamic>>> tempCategories = {};


      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;


        allFoods.add(data);


        final category = data['category'] as String;
        if (!tempCategories.containsKey(category)) {
          tempCategories[category] = [];
        }
        tempCategories[category]?.add(data);


        if (data['popular_food'] == true) {
          popularFoods.add(data);
        }


        if (data['recent_added'] == true) {
          newlyAdded.add(data);
        }


        if (data['chef_special'] == true) {
          chefSpecials.add(data);
        }
        update();
      }
      categories.value = tempCategories;
      isLoading.value = false;
    } catch (e) {
      print('Error fetching foods: $e');
      isLoading.value = false;


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


  double getPrice(Map<String, dynamic> food) {

    if (food['category'] == 'pizza' && food['price'] is List && (food['price'] as List).isNotEmpty) {
      var firstPrice = food['price'][0];
      if (firstPrice is num) {
        return firstPrice.toDouble();
      } else if (firstPrice is String) {
        return double.tryParse(firstPrice) ?? 9.99;
      }
      return 9.99;
    }

    else if (food['price'] is num) {
      return (food['price'] as num).toDouble();
    }

    else if (food['price'] is String) {
      return double.tryParse(food['price']) ?? 8.99;
    }

    else if (food['price'] is List && (food['price'] as List).isNotEmpty) {
      var firstPrice = food['price'][0];
      if (firstPrice is num) {
        return firstPrice.toDouble();
      } else if (firstPrice is String) {
        return double.tryParse(firstPrice) ?? 8.99;
      }
    }


    if (food['category'] == 'burger') {
      return 7.99;
    } else if (food['category'] == 'salad' || food['category'] == 'healthy') {
      return 6.99;
    }

    return 5.99;
  }


  String getSize(Map<String, dynamic> food) {

    if (food['category'] == 'pizza' && food['size'] is List && (food['size'] as List).isNotEmpty) {
      return '${food['size'][0] ?? 6}" size';
    }
    return '';
  }


  String getDescription(Map<String, dynamic> food) {

    if (food['desc'] != null && food['desc'].toString().isNotEmpty) {
      return food['desc'].toString();
    }

    else if (food['description'] != null && food['description'].toString().isNotEmpty) {
      return food['description'].toString();
    }


    final category = food['category'].toString().toLowerCase();
    if (category == 'burger') {
      return 'Delicious burger with fresh ingredients and special sauce.';
    } else if (category == 'pizza') {
      return 'Authentic Italian pizza with premium toppings and melted cheese.';
    } else if (category == 'salad' || category == 'healthy') {
      return 'Fresh and healthy salad made with seasonal ingredients.';
    }


    return '${food['category']} speciality';
  }


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


  void setSearchQuery(String query) {
    searchQuery.value = query;
  }


  void selectSuggestion(Map<String, dynamic> suggestion) {
    searchQuery.value = suggestion['name'] as String;
    showSuggestions.value = false;
  }


  void clearSearch() {
    searchQuery.value = '';
    searchSuggestions.clear();
    showSuggestions.value = false;
  }
}