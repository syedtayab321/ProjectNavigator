import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:navigatorapp/CustomWidgets/ConfirmDialogBox.dart';
import 'package:navigatorapp/CustomWidgets/TextWidget.dart';
import 'package:navigatorapp/Portals/studentportal/Profile/GiveFeedback.dart';
import 'package:navigatorapp/Portals/studentportal/Profile/UpdateDataPage.dart';

import '../../../CustomWidgets/ElevatedButton.dart';
import '../../../SharedPreferences/LoginSharedPreference.dart';
class StudentProfile extends StatelessWidget {

  User? user = FirebaseAuth.instance.currentUser;
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
        title: const CustomTextWidget(title: 'Profile', color: Colors.white),
        backgroundColor: Colors.tealAccent.shade700,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found'));
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.transparent,
                    backgroundImage: userData['profileImage'] != null
                        ? NetworkImage(userData['profileImage'])
                        : const AssetImage('assets/images/app-icon-person.png') as ImageProvider,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userData['name'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ProfileDetailRow(
                          icon: Icons.person,
                          label: 'User Id:',
                          value: userData['uid'] ?? 'N/A',
                        ),
                        ProfileDetailRow(
                          icon: Icons.email,
                          label: 'Email:',
                          value: userData['email'] ?? 'N/A',
                        ),
                        ProfileDetailRow(
                          icon: Icons.person,
                          label: 'Role:',
                          value: userData['role'] ?? 'N/A',
                        ),
                        ProfileDetailRow(
                          icon: Icons.person,
                          label: 'Sessions:',
                          value: userData['session'] ?? 'N/A',
                        ),
                        ProfileDetailRow(
                          icon: Icons.account_balance_outlined,
                          label: 'Department:',
                          value: userData['department'] ?? 'N/A',
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Elevated_button(
                                  text:'Edit',
                                  color: Colors.white,
                                  backcolor: Colors.teal,
                                  padding: 10,
                                  radius: 10,
                                  height: 10,
                                  width: 170,
                                  path: (){
                                    Get.to(
                                      UpdateStudentPage(
                                        name: userData['name'],
                                        department: userData['department'],
                                        session: userData['session'],
                                      ),
                                    );
                                  }
                              ),
                              const SizedBox(height: 20),
                              Elevated_button(
                                text: 'Logout',
                                color: Colors.white,
                                path: () {
                                  logout(context);
                                },
                                padding: 12,
                                radius: 10,
                                width: 150,
                                height: 10,
                                backcolor: Colors.red,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildActionListTiles(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionListTiles(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.feedback, color: Colors.teal),
          title: const Text('Give Feedback'),
          onTap: () {
            Get.to(StudentFeedbackPage());
          },
        ),
        const Divider(),
      ],
    );
  }
}

// Custom Widget for Profile Details Row
class ProfileDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileDetailRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal.shade700),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
}
