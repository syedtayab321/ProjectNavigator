import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navigatorapp/CustomWidgets/TextWidget.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:navigatorapp/CustomWidgets/Snakbar.dart';

class AdminProjectDetailsScreen extends StatelessWidget {
  final String projectId;

  AdminProjectDetailsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Project Details'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade600, Colors.teal.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('PastProjects')
              .doc(projectId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading project details.'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Project not found.'));
            }

            var projectData = snapshot.data!.data() as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(Icons.assignment, 'Project Name', projectData['projectName']),
                      const Divider(thickness: 1, color: Colors.grey),
                      _buildDetailRow(Icons.description, 'Description', projectData['description']),
                      const Divider(thickness: 1, color: Colors.grey),
                      _buildDetailRow(Icons.person, 'Supervisor', projectData['supervisor']),
                      const Divider(thickness: 1, color: Colors.grey),
                      _buildDetailRow(Icons.person_outline, 'Student 1', projectData['Student1'] ?? 'None'),
                      const Divider(thickness: 1, color: Colors.grey),
                      _buildDetailRow(Icons.person_outline, 'Student 2', projectData['Student2'] ?? 'None'),
                      const SizedBox(height: 20),
                      projectData.containsKey('fileUrl') && projectData['fileUrl'] != null
                          ? Center(
                        child: _buildFileButton(projectData['fileUrl']),
                      )
                          : const Center(
                        child: Text(
                          'No SRS document available',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _deleteProject(context, projectData['fileUrl']),
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text('Delete Project', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFileButton(String fileUrl) {
    return TextButton.icon(
      onPressed: () => _downloadAndOpenFile(fileUrl, 'project_file.docx'),
      icon: Icon(Icons.attach_file, color: Colors.blue.shade400),
      label: const CustomTextWidget(
        title: 'View File',
        size: 16,
        color: Colors.blue,
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.blue.shade50,
      ),
    );
  }

  Future<void> _downloadAndOpenFile(String fileUrl, String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';

      Dio dio = Dio();
      await dio.download(fileUrl, filePath);

      OpenFile.open(filePath);
    } catch (e) {
      showErrorSnackbar('Error Could not download and open file: $e');
    }
  }

  Future<void> _deleteProject(BuildContext context, String? fileUrl) async {
    try {
      if (fileUrl != null) {
        await FirebaseStorage.instance.refFromURL(fileUrl).delete();
      }
      await FirebaseFirestore.instance.collection('PastProjects').doc(projectId).delete();
      showSuccessSnackbar('Project deleted successfully.');
      Get.back();
      Get.back();
    } catch (e) {
      showErrorSnackbar('Error deleting project: $e');
    }
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
