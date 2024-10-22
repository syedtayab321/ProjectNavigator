import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:navigatorapp/CustomWidgets/TextWidget.dart';
import '../../CustomWidgets/ConfirmDialogBox.dart';
import '../../SharedPreferences/LoginSharedPreference.dart';

class SupervisorDashboardPage extends StatelessWidget {
  final AuthService _auth = AuthService();
  void logout(BuildContext context) async {
    await Get.dialog(
      ConfirmDialog(
        title: 'Logout',
        content: 'Are you sure you want to logout?',
        confirmText: 'Confirm',
        cancelText: 'Cancel',
        onConfirm: () {
          _auth.signOut();
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
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const CustomTextWidget(title: 'Supervisor Dashboard',color: Colors.white,),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed:()=>logout(context),
          ),
        ],
      ),
      body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Projects Requested by Users',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('projects').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No projects found.',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  final projectDocs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: projectDocs.length,
                    itemBuilder: (context, index) {
                      var project = projectDocs[index].data() as Map<String, dynamic>;
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const Icon(
                            Icons.assignment,
                            color: Colors.teal,
                            size: 40,
                          ),
                          title: Text(
                            project['projectName'] ?? 'No Title',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[700],
                            ),
                          ),
                          subtitle: Text(
                            project['description'] ?? 'No Description',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.teal,
                          ),
                          onTap: () {
                            // Add navigation to project details screen
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
      )
    );
  }
}
