import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/foodController.dart';
import '../widget/CategoryFilterChip.dart';
import '../widget/EmptyState.dart';
import '../widget/FoodItemCard.dart';
import 'FoodDetailScreen.dart';


class CategoryDetailScreen extends StatefulWidget {
  final String category;

  const CategoryDetailScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final FoodController _foodController = Get.find<FoodController>();
  String _selectedFilter = '';

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.category.capitalize ?? widget.category,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

      ),
      body: Column(
        children: [
          _buildCategoryFilterChips(),

          Expanded(
            child: Obx(() {
              final categoryFoods = _foodController.categories[_selectedFilter] ?? [];
              return categoryFoods.isEmpty
                  ? EmptyStateWidget(
                categoryName: _selectedFilter,
                onRefresh: () => _foodController.fetchFoods(),
              )
                  : _buildFoodList(categoryFoods);
            }),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildCategoryFilterChips() {
    return Obx(() {
      // Get all available categories
      final categories = _foodController.categories.keys.toList();

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: categories.map((category) {
              bool isSelected = _selectedFilter == category;
              return CategoryFilterChip(
                label: category,
                isSelected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = category;
                  });
                },
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildFoodList(List<Map<String, dynamic>> foods) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final food = foods[index];
        return FoodItemCard(
          food: food,
          selectedCategory: _selectedFilter,
          onTap: () => Get.to(() => FoodDetailScreen(food: food)),
          foodController: _foodController,
        );
      },
    );
  }
}