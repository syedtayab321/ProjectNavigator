import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../CustomWidgets/ConfirmDialogBox.dart';
import '../../CustomWidgets/ElevatedButton.dart';
import '../../CustomWidgets/TextWidget.dart';
import '../../SharedPreferences/LoginSharedPreference.dart';

class AdminProfilePage extends StatelessWidget {
  final AuthService _authService = AuthService();

  void logout(BuildContext context) async {
    await Get.dialog(
      ConfirmDialog(
        title: 'Logout',
        content: 'Are you sure you want to logout?',
        confirmText: 'Confirm',
        cancelText: 'Cancel',
        onConfirm: () {
          _authService.signOut();
        },
        onCancel: () {
          Get.back();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextWidget(
              title: 'FYP Navigator',
              size: 28,
              weight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
            const SizedBox(height: 10),
            CustomTextWidget(
              title: 'http://www.upr.edu.pk',
              size: 18,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 30),
            const Divider(height: 20, thickness: 2),
            CustomTextWidget(
              title: 'App Information',
              size: 22,
              weight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.store, color:Colors.teal.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextWidget(
                      title: 'FYP Navigator is a platform that helps students and faculty manage and navigate Final Year Projects with essential resources and collaboration tools. ',
                      size: 16, color: Colors.grey[800]),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.teal.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextWidget(
                      title: "Whether it's for project resources, mentorship, or collaboration, FYP Navigator offers a seamless way for students and faculty to connect and succeed in their Final Year Projects",
                      size: 16, color: Colors.grey[800]
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 20, thickness: 2),
            const Spacer(),
            Elevated_button(
              text: 'Logout',
              color: Colors.white,
              path: () {
                logout(context);
              },
              padding: 12,
              radius: 10,
              width: Get.width,
              height: 50,
              backcolor: Colors.red,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
