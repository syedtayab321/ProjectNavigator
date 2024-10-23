import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navigatorapp/Portals/studentportal/Requests/project_req_controller.dart';
import '../../../CustomWidgets/Snakbar.dart';

class ProjectRequest extends StatefulWidget {
  @override
  State<ProjectRequest> createState() => _ProjectRequestState();
}

class _ProjectRequestState extends State<ProjectRequest> {
  final ProjectRequestController controller = Get.put(ProjectRequestController());
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    controller.fetchProjectDetails(currentUser!.uid);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Your Project",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.tealAccent,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.projectList.isNotEmpty) {
            return ListView.builder(
              itemCount: controller.projectList.length,
              itemBuilder: (context, index) {
                var projectData = controller.projectList[index];
                return _buildProjectCard(projectData);
              },
            );
          } else {
            return _buildEmptyState();
          }
        }),
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> projectData) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProjectInfo(
              title: "Name",
              content: projectData['projectName'] ?? 'N/A',
              icon: Icons.book,
            ),
            _buildProjectInfo(
              title: "Partner",
              content: projectData['partner'] ?? 'None',
              icon: Icons.people,
            ),
            _buildProjectInfo(
              title: "Supervisor",
              content: projectData['supervisor'] ?? 'N/A',
              icon: Icons.person,
            ),
            _buildProjectInfo(
              title: "Status",
              content: "${projectData['status'] ?? 'Pending'}".toUpperCase(),
              icon: Icons.info_outline,
              statusColor: _getStatusColor(projectData['status']),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Message Supervisor',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (projectData['projectId'] != null) {
                        await controller.deleteProject(projectData['projectId']);
                      } else {
                        showErrorSnackbar('No project found to delete');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No project requests found.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInfo({
    required String title,
    required String content,
    required IconData icon,
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.teal.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$title: $content",
              style: TextStyle(
                fontSize: 15,
                fontWeight: statusColor != null ? FontWeight.bold : FontWeight.normal,
                color: statusColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
