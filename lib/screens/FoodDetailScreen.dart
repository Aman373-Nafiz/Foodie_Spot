import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/foodController.dart';
import '../widget/FoodImage.dart';
import '../widget/NamePrice.dart';
import '../widget/SizeSelector.dart';



class FoodDetailScreen extends StatefulWidget {
  final Map<String, dynamic> food;

  const FoodDetailScreen({Key? key, required this.food}) : super(key: key);

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final FoodController _foodController = Get.find<FoodController>();
  String _selectedSize = 'Small';

  @override
  void initState() {
    super.initState();
    // Initialize selected size
    if (isPizza && widget.food['size'] != null && widget.food['size'] is List) {
      _selectedSize = 'Small';
    }
  }

  // Check if the item is pizza
  bool get isPizza => widget.food['category'].toString().toLowerCase() == 'pizza';

  // Get price display based on selected size for pizza
  String _getPriceDisplay() {
    // For pizza with different sizes
    if (isPizza && widget.food['price'] is List && (widget.food['price'] as List).isNotEmpty) {
      final List<dynamic> prices = widget.food['price'] as List;

      // Return price based on selected size
      if (_selectedSize == 'Small' && prices.length > 0) {
        return prices[0].toString();
      } else if (_selectedSize == 'Medium' && prices.length > 1) {
        return prices[1].toString();
      } else if (_selectedSize == 'Large' && prices.length > 2) {
        return prices[2].toString();
      }

      // Default to first price if size doesn't match
      return prices[0].toString();
    }
    // For non-pizza items
    else if (widget.food['price'] is num) {
      return (widget.food['price'] as num).toStringAsFixed(2);
    }
    // For string price
    else if (widget.food['price'] is String) {
      return widget.food['price'].toString();
    }

    // Default prices for categories without price data
    if (widget.food['category'] == 'burger') {
      return '7.99';
    } else if (widget.food['category'] == 'salad' || widget.food['category'] == 'healthy') {
      return '6.99';
    }

    return '5.99'; // General default price
  }

  void _onSizeSelected(String size) {
    setState(() {
      _selectedSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get food details
    final String name = widget.food['name'] as String;
    final String category = widget.food['category'] as String;
    final String description = _foodController.getDescription(widget.food);
    final String imageUrl = widget.food['image'] as String? ?? '';

    // Get rating if available, default to 4.8
    final double rating = widget.food['rating'] != null ?
    (widget.food['rating'] is int ?
    (widget.food['rating'] as int).toDouble() :
    widget.food['rating'] as double) :
    4.8;

    final int ratingCount = widget.food['rating_count'] ?? 250;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Food Details',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image with Rating
            FoodImageWidget(imageUrl: imageUrl, rating: rating, ratingCount: ratingCount),

            // Food Name and Price
            NamePriceWidget(
                name: name,
                category: category,
                price: _getPriceDisplay()
            ),

            // Description Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
              SizeSelectorWidget(
                sizes: widget.food['size'] as List<dynamic>? ?? [],
                selectedSize: _selectedSize,
                onSizeSelected: _onSizeSelected,
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}