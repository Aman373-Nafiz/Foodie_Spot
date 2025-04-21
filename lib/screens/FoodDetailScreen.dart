import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/foodController.dart';
import '../utils/constant.dart';
import '../widget/FoodImage.dart';
import '../widget/NamePrice.dart';
import '../widget/SizeSelector.dart';
import 'OrderScreen.dart';

class FoodDetailScreen extends StatelessWidget {
  final Map<String, dynamic> food;
  FoodDetailScreen({Key? key, required this.food}) : super(key: key);

  final FoodController _foodController = Get.find<FoodController>();

  bool getIsPizza(String category) =>
      category.toLowerCase() == 'pizza';

  String getPrice(Map<String, dynamic> food, String selectedSize) {
    final isPizza = getIsPizza(food['category']);
    final price = food['price'];

    if (isPizza && price is List && price.isNotEmpty) {
      switch (selectedSize) {
        case 'Small':
          return  price[0].toString();
        case 'Medium':
          return price[1].toString() ;
        case 'Large':
          return price[2].toString();
        default:
          return price[0].toString();
      }
    }

    if (price is num) return price.toStringAsFixed(2);
    if (price is String) return price;

    if (food['category'] == 'burger') return '7.99';
    if (food['category'] == 'salad' || food['category'] == 'healthy') return '6.99';

    return '5.99';
  }

  @override
  Widget build(BuildContext context) {
    final isPizza = getIsPizza(food['category']);
    final sizes = food['size'] as List<dynamic>?;

    // Delay setting selected size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPizza) {
        _foodController.setInitialSizeIfNeeded(sizes);
      }
    });

    final String name = food['name'] as String;
    final String category = food['category'] as String;
    final String description = _foodController.getDescription(food);
    final String imageUrl = food['image'] as String? ?? '';
    final double rating = food['rating'] != null
        ? (food['rating'] is int
        ? (food['rating'] as int).toDouble()
        : food['rating'] as double)
        : 4.8;
    final int ratingCount = food['rating_count'] ?? 250;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Food Details', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FoodImageWidget(
                  imageUrl: imageUrl,
                  rating: rating,
                  ratingCount: ratingCount,
                ),
                Obx(() => NamePriceWidget(
                  name: name,
                  category: category,
                  price: getPrice(food, _foodController.selectedSize.value),
                )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Description',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
                if (isPizza)
                  Obx(() => SizeSelectorWidget(
                    sizes: sizes ?? [],
                    selectedSize: _foodController.selectedSize.value,
                    onSizeSelected: (size) => _foodController.selectedSize.value = size,
                  )),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Obx(() {
             final selectedSize = _foodController.selectedSize.value;
                final displayPrice = getPrice(food, selectedSize);
             final foodItem = {
               ...Map<String, dynamic>.from(food), // Create a deep copy of the food map
               'selected_size': isPizza ? selectedSize : null,
               'display_price': displayPrice,
             };
             print (selectedSize);
             print(displayPrice);
             print("---------------------------------------------------------");
                return ElevatedButton(
                  onPressed: () => Get.off(() => OrderScreen(foodItem: foodItem)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Order Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
