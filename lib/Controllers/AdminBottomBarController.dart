import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navigatorapp/Portals/AdminPortal/ProjectRequests.dart';
import '../Portals/AdminPortal/AdminHomePage.dart';
import '../Portals/AdminPortal/adminProfile.dart';

class AdminBottomBarController extends GetxController {
  var selectedIndex = 0.obs;

  void onItemTapped(int index) {
    selectedIndex.value = index;
  }

  final List<Widget> pages = [
    AdminHomePage(),
    ProjectRequestsPage(),
    AdminHomePage(),
    AdminProfilePage(),
  ];
}