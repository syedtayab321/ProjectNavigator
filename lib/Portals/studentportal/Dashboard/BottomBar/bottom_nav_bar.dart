import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Student_navbar_controller.dart';
class StudentBottomBarPage extends StatelessWidget {
  final StudentBottomBarController _controller = Get.put(StudentBottomBarController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return _controller.pages[_controller.selectedIndex.value];
      }),
        bottomNavigationBar: Obx(() {
          return FloatingNavbar(
            onTap: (int val) {
              _controller.onItemTapped(val);
            },
            currentIndex: _controller.selectedIndex.value,
            iconSize: 20,
            fontSize: 10.1,
            margin: const EdgeInsets.symmetric(horizontal: 0),
            padding: const EdgeInsets.only(bottom: 8,top: 6),
            backgroundColor: Colors.tealAccent.shade700,
            selectedItemColor: Colors.black,
            selectedBackgroundColor: Colors.white,
            unselectedItemColor: Colors.black87,
            items: [
              FloatingNavbarItem(icon: Icons.home, title: 'Home'),
              FloatingNavbarItem(icon: Icons.request_page, title: 'Requests'),
              FloatingNavbarItem(icon: Icons.notifications, title: 'Notifications'),
              FloatingNavbarItem(icon: Icons.settings, title: 'Settings'),
            ],
          );
        }),
    );
  }
}