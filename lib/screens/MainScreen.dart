import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/orderController.dart';
import 'Home.dart';
import 'order/OrderList.dart';
import 'ProfileScreen.dart';

class MainScreen extends StatelessWidget {
  MainScreen({Key? key}) : super(key: key);

  final RxInt _currentIndex = 0.obs;
  final OrderController _orderController = Get.put(OrderController(), permanent: true);

  final List<Widget> _screens = [
    RestaurantHomePage(),
    OrderListScreen(),
  ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: _screens[_currentIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex.value,
          onTap: (index) => _currentIndex.value = index,
          selectedItemColor: const Color(0xFFFF9B43),
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Obx(() {
                return Badge(
                  isLabelVisible: _orderController.hasActiveOrders.value,
                  label: Text(
                    '${_orderController.activeOrdersCount.value}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  child: const Icon(Icons.receipt),
                );
              }),
              label: 'Orders',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      );
    });
  }
}