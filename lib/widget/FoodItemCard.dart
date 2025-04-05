import 'package:flutter/material.dart';
import '../controller/foodController.dart';


class FoodItemCard extends StatelessWidget {
  final Map<String, dynamic> food;
  final String selectedCategory;
  final VoidCallback onTap;
  final FoodController foodController;

  const FoodItemCard({
    Key? key,
    required this.food,
    required this.selectedCategory,
    required this.onTap,
    required this.foodController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = food['name'] as String;
    final description = foodController.getDescription(food);
    final image = food['image'] as String? ?? '';
    final price = foodController.getPrice(food);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: image.isNotEmpty
                  ? Image.network(
                image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              )
                  : _buildPlaceholderImage(),
            ),
            const SizedBox(width: 16),

            // Food details
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
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Price and size information
                  if (selectedCategory.toLowerCase() == 'pizza' && food['price'] is List)
                    _buildPizzaPricing(food)
                  else
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepOrange,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey.shade300,
      child: const Icon(Icons.restaurant, color: Colors.white, size: 40),
    );
  }

  Widget _buildPizzaPricing(Map<String, dynamic> food) {
    final prices = food['price'] as List;
    final sizes = food['size'] as List;

    // Make sure we have prices and sizes
    if (prices.isEmpty || sizes.isEmpty) {
      return Text(
        '\$${foodController.getPrice(food).toStringAsFixed(2)}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.deepOrange,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < prices.length && i < sizes.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${sizes[i]}" - ',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: '\$${prices[i].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}