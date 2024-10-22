import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../AdminPortal/adminProfile.dart';
import '../../Notifications/student_notification.dart';
import '../../Requests/project_req.dart';
import '../student_dashboard.dart';

class StudentBottomBarController extends GetxController {
  var selectedIndex = 0.obs;

  void onItemTapped(int index) {
    selectedIndex.value = index;
  }

  final List<Widget> pages = [
    StudentDashboardPage(),
    ProjectRequest(),
    NotificationScreen(),
    AdminProfilePage(),
  ];
}