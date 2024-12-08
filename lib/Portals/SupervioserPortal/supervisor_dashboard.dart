import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../CustomWidgets/ConfirmDialogBox.dart';
import '../../CustomWidgets/TextWidget.dart';
import '../../SharedPreferences/LoginSharedPreference.dart';
import 'SupervisorProjectDetailsPage.dart';

class SupervisorDashboardPage extends StatefulWidget {
  @override
  State<SupervisorDashboardPage> createState() => _SupervisorDashboardPageState();
}

class _SupervisorDashboardPageState extends State<SupervisorDashboardPage> {
  final AuthService _auth = AuthService();
  Map<String, dynamic>? userData;

  // Method to log out the user
  void logout(BuildContext context) async {
    await Get.dialog(
      ConfirmDialog(
        title: 'Logout',
        content: 'Are you sure you want to logout?',
        confirmText: 'Confirm',
        cancelText: 'Cancel',
        onConfirm: () {
          _auth.signOut();
          Get.back();  // Close the dialog
        },
        onCancel: () {
          Get.back();
        },
      ),
    );
  }

  // Method to fetch user data
  Future<void> GetUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data() as Map<String, dynamic>;
        });
      } else {
        print('No such document');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    GetUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        title: const Text(
          'Supervisor Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade700,
      ),
      drawer: _buildDrawer(context),  // Drawer added here
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Projects Assigned To You',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.tealAccent.shade700,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('projectRequests')
                  .where('supervisor', isEqualTo: userData?['name'])
                  .where('status', isEqualTo: userData?['approved'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
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
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      shadowColor: Colors.tealAccent,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.blue.withOpacity(0.1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.assignment,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    project['projectName'] ?? 'No Title',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildProjectDetailRow(
                              title: "Student Name:",
                              value: project['studentName'] ?? 'Unknown',
                              icon: Icons.person,
                            ),
                            _buildProjectDetailRow(
                              title: "Session:",
                              value: project['session'] ?? 'Not Provided',
                              icon: Icons.calendar_today,
                            ),
                            _buildProjectDetailRow(
                              title: "Partner:",
                              value: project['partner'] ?? 'No Partner',
                              icon: Icons.group,
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                 Get.to(ProjectDetailsPage(project: project));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                label: const Text(
                                  'View Details',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Drawer widget that displays supervisor's details and a logout option
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(userData?['name'] ?? 'Supervisor'),
            accountEmail: Text(userData?['email'] ?? 'No email available'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userData?['name']?.substring(0, 1) ?? 'S',
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Supervisor Details'),
            subtitle: Text('Name: ${userData?['name'] ?? 'N/A'}\nEmail: ${userData?['email'] ?? 'N/A'}'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              logout(context);
            },
          ),
        ],
      ),
    );
  }

  // Helper method to build project detail rows with icons
  Widget _buildProjectDetailRow({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$title ",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
