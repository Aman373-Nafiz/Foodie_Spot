import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/AuthController.dart';
import '../controller/foodController.dart';
import '../utils/constant.dart';
import '../widget/BuildSectionHeader.dart';
import '../widget/CategoryItem.dart';
import '../widget/Drawer.dart';
import '../widget/FoodItem.dart';
import 'CategoryDetailScreen.dart';
import 'FoodDetailScreen.dart';

class RestaurantHomePage extends StatelessWidget {
  RestaurantHomePage({Key? key}) : super(key: key);


  final FoodController _foodController = Get.put(FoodController());
  final AuthController authController = Get.put(AuthController());
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    _initializeOnce();

    return SafeArea(
      child: Scaffold(
        drawer: buildDrawer(context),
        appBar: AppBar(

          backgroundColor: const Color(0xFFFF9B43),
          centerTitle: true,
          title: Text(
            AppConstants.appName,
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        backgroundColor: Colors.white,
        body: Obx(() {

          if (_foodController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          return Stack(
            children: [
              _buildContent(),

              // Suggestions Overlay
              if (_foodController.showSuggestions.value)
                Positioned(
                  top: 64,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: _foodController.searchSuggestions.isEmpty
                          ? ListTile(
                              leading:
                                  const Icon(Icons.search, color: Colors.grey),
                              title: const Text('Item not found'),
                              subtitle: Text(
                                  'No results for "${_foodController.searchQuery.value}"'),
                              onTap: () {
                                _searchFocusNode.unfocus();
                                _foodController.showSuggestions.value = false;
                                Get.snackbar(
                                  'Not Found',
                                  'No items match your search',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red.shade400,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 2),
                                );
                              },
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount:
                                  _foodController.searchSuggestions.length,
                              itemBuilder: (context, index) {
                                final suggestion =
                                    _foodController.searchSuggestions[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(suggestion['name'] as String),
                                  subtitle:
                                      Text(suggestion['category'] as String),
                                  leading: const Icon(Icons.search, size: 18),
                                  onTap: () {
                                    _foodController
                                        .selectSuggestion(suggestion);
                                    _searchController.text =
                                        suggestion['name'] as String;
                                    _searchFocusNode.unfocus();
                                    _foodController.showSuggestions.value =
                                        false;

                                    // Navigate to food detail screen
                                    Get.to(() =>
                                        FoodDetailScreen(food: suggestion));
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }


  void _initializeOnce() {

    if (_foodController.allFoods.isEmpty && !_foodController.isLoading.value) {

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _foodController.fetchFoods();
      });
    }
  }


  void _setupSearchFocusListener() {
    _searchFocusNode.removeListener(() {});
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus &&
          _foodController.searchQuery.value.isNotEmpty) {
        _foodController.showSuggestions.value = true;
      }
    });
  }



  Widget _buildContent() {
    if (_foodController.allFoods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No food items available',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Only allow refresh if not already loading
                if (!_foodController.isLoading.value) {
                  _foodController.fetchFoods();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9B43),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }


    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          _buildSearchBox(),

          const SizedBox(height: 24),


          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),

          const SizedBox(height: 16),

          _buildCategorySection(),

          const SizedBox(height: 24),

          buildSectionHeader('Popular Food'),

          const SizedBox(height: 16),

          _buildPopularFoodSection(),

          const SizedBox(height: 24),

          buildSectionHeader('Newly Added'),

          const SizedBox(height: 16),

          _buildNewlyAddedSection(),

          const SizedBox(height: 24),

          _buildChefSpecialsSection(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }


  Widget _buildSearchBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(27),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(
                hintText: 'Search foods, restaurants...',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) => _foodController.setSearchQuery(value),
              onSubmitted: (value) {
                _searchFocusNode.unfocus();
                _foodController.showSuggestions.value = false;


                final matchingFoods = _foodController.allFoods.where((food) {
                  final name = food['name'].toString().toLowerCase();
                  final category = food['category'].toString().toLowerCase();
                  return name.contains(value.toLowerCase()) ||
                      category.contains(value.toLowerCase());
                }).toList();


                if (matchingFoods.isNotEmpty) {
                  Get.to(() => FoodDetailScreen(food: matchingFoods[0]));
                } else {

                  Get.snackbar(
                    'Not Found',
                    'No items match your search',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade400,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                }
              },
            ),
          ),
          Obx(() => _foodController.searchQuery.value.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _foodController.clearSearch();
                    _searchController.clear();
                  },
                  child: const Icon(Icons.close, color: Colors.grey, size: 20),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }


  Widget _buildCategorySection() {
    return _foodController.categories.isEmpty
        ? const Center(
            child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No categories available'),
          ))
        : SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _buildCategoryItems(),
            ),
          );
  }




  Widget _buildPopularFoodSection() {
    final popularFoods = _foodController.popularFoods;
    return SizedBox(
      height: 160,
      child: popularFoods.isEmpty
          ? const Center(child: Text('No popular foods available'))
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: popularFoods.length,
              itemBuilder: (context, index) {
                final food = popularFoods[index];
                return FoodItem(
                  name: food['name'] as String,
                  image: food['image'] as String,
                  price: _foodController.getPrice(food),
                  size: _foodController.getSize(food),
                  foodData: food,
                );
              },
            ),
    );
  }


  Widget _buildNewlyAddedSection() {
    final newlyAdded = _foodController.newlyAdded;
    return SizedBox(
      height: 160,
      child: newlyAdded.isEmpty
          ? const Center(child: Text('No new foods available'))
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: newlyAdded.length,
              itemBuilder: (context, index) {
                final food = newlyAdded[index];
                return FoodItem(
                  name: food['name'] as String,
                  image: food['image'] as String,
                  price: _foodController.getPrice(food),
                  size: _foodController.getSize(food),
                  foodData: food,
                );
              },
            ),
    );
  }


  Widget _buildChefSpecialsSection() {
    final chefSpecials = _foodController.chefSpecials;
    if (chefSpecials.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Restaurant Specials',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: chefSpecials.length,
          itemBuilder: (context, index) {
            final special = chefSpecials[index];
            return _buildSpecialItem(special);
          },
        ),
      ],
    );
  }


  List<Widget> _buildCategoryItems() {
    final categories = _foodController.categories.keys.toList();
    return categories.map((category) {
      IconData iconData;
      switch (category.toLowerCase()) {
        case 'pizza':
          iconData = Icons.local_pizza_outlined;
          break;
        case 'burger':
          iconData = Icons.lunch_dining;
          break;
        case 'pasta':
          iconData = Icons.dinner_dining;
          break;
        case 'salad':
          iconData = Icons.rice_bowl;
          break;
        case 'coffee':
          iconData = Icons.coffee;
          break;
        case 'chicken':
          iconData = Icons.fastfood;
          break;
        default:
          iconData = Icons.restaurant;
      }

      return CategoryItem(
        icon: iconData,
        label: category.capitalize ?? category,
        color: Colors.deepOrange,
        onTap: () {

          Get.to(() => CategoryDetailScreen(category: category));
        },
      );
    }).toList();
  }


  Widget _buildSpecialItem(Map<String, dynamic> special) {
    return InkWell(
      onTap: () {

        Get.to(() => FoodDetailScreen(food: special));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9F2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  special['image'] as String,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 60,
                      width: 60,
                      color: Colors.grey.shade300,
                      child:
                          const Icon(Icons.broken_image, color: Colors.white),
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
                      special['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Chef\'s Special',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$${_foodController.getPrice(special).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (special['category'] == 'pizza' &&
                            special['size'] is List)
                          Text(
                            _foodController.getSize(special),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
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
