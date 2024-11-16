import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:navigatorapp/Portals/SupervioserPortal/supervisor_dashboard.dart';
import '../CustomWidgets/Snakbar.dart';
import '../Modals/AuthModals.dart';
import '../Portals/AdminPortal/AdminMainScreen.dart';
import '../Portals/studentportal/Dashboard/BottomBar/bottom_nav_bar.dart';
import '../SharedPreferences/LoginSharedPreference.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService authService = AuthService();

  Future<void> login() async {
    isLoading.value = true;
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      isLoading.value = false;
      showErrorSnackbar('Please fill all the fields first');
      return;
    }

    try {
      User? user = await authService.signIn(emailController.text, passwordController.text);
      if (user != null) {
        await authService.saveUserToPreferences(user.uid);
        String? uid = await authService.getUserFromPreferences();
        if (uid == null) {
          isLoading.value = false;
          showErrorSnackbar('User ID not found in preferences.');
          return;
        }

        UserModel? userModel = await authService.getUserRole(uid);
        if (userModel != null) {
          isLoading.value = false;

          switch (userModel.role.toLowerCase()) {
            case 'admin':
              showSuccessSnackbar('Login Successfully');
              Get.offAll(() => AdminDashboardPage(), transition: Transition.fadeIn, duration: const Duration(seconds: 2));
              break;

            case 'student':
              if (userModel.status == 'approved') {
                showSuccessSnackbar('Login Successfully');
                Get.offAll(() => StudentBottomBarPage(), transition: Transition.fadeIn, duration: const Duration(seconds: 2));
              } else if (userModel.status == 'pending') {
                showErrorSnackbar('Your request is still in pending. Wait until your request is approved.');
              } else if (userModel.status == 'rejected') {
                showErrorSnackbar('Unfortunately, your request has been rejected. Please reach out to the admin for further assistance.');
              }
              break;

            case 'supervisor':
              showSuccessSnackbar('Login Successfully');
              Get.offAll(() => SupervisorDashboardPage(), transition: Transition.fadeIn, duration: const Duration(seconds: 2));
              break;

            default:
              showErrorSnackbar('User role not found.');
              break;
          }
        } else {
          isLoading.value = false;
          showErrorSnackbar('User role not found.');
        }
      } else {
        isLoading.value = false;
        showErrorSnackbar('Wrong Credentials');
      }
    } catch (e) {
      isLoading.value = false;
      showErrorSnackbar('An error occurred. Please try again later.');
      debugPrint('Login Error: $e');
    }
  }
}

