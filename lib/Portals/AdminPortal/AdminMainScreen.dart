import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/AdminBottomBarController.dart';
import '../../CustomWidgets/TextWidget.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
class AdminDashboardPage extends StatelessWidget {
  final AdminBottomBarController _controller = Get.put(AdminBottomBarController());
  AdminDashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const CustomTextWidget(title: 'Admin Portal',color: Colors.white,),
        backgroundColor: Colors.tealAccent.shade700,
      ),
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
            FloatingNavbarItem(icon: Icons.request_page, title: 'NewRequests'),
            FloatingNavbarItem(icon: Icons.remove_from_queue, title: 'AllRequests'),
            FloatingNavbarItem(icon: Icons.settings, title: 'Settings'),
          ],
        );
      }),
    );
  }
}