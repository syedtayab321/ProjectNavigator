import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ManageSupervioser/ManageSupervisorsPage.dart';
import 'ManageUser/ManageUserPage.dart';
import 'admin_add_projects.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overview',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 20),
              _buildKeyMetrics(isSmallScreen),
              const SizedBox(height: 30),
              _buildAddProjectCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddProjectCard() {
    return GestureDetector(
      onTap: () {
        Get.to(() => AddProjects());
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.tealAccent.shade700,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 40,
              color: Colors.white,
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Project',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Click to add a new project ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.orangeAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(bool isSmallScreen) {
    return Wrap(
      spacing: 40.0,
      runSpacing: 16.0,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        _buildMetricCard('Manage', "Users", Icons.people, Colors.blue, Colors.lightBlueAccent),
        _buildMetricCard('Manage', "Supervisors", Icons.supervised_user_circle, Colors.green, Colors.tealAccent),
        _buildMetricCard('Manage', 'Projects', Icons.work, Colors.orange, Colors.deepOrangeAccent),
        _buildMetricCard('Manage', 'Feedback', Icons.feedback, Colors.purple, Colors.deepPurpleAccent),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String subtitle, IconData icon, Color startColor, Color endColor) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 200),
      child: GestureDetector(
        onTap: () {
          if (title == 'Manage' && subtitle == "Users") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManageUsersPage()),
            );
          } else if (title == 'Manage' && subtitle == "Supervisors") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManageSupervisorsPage()),
            );
          }
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 8,
          shadowColor: Colors.grey.withOpacity(0.3),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
