import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../CustomWidgets/Snakbar.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final String projectId;

  ProjectDetailsScreen({required this.projectId});

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
                      // Display download button if SRS document URL is available
                      projectData.containsKey('fileUrl') && projectData['fileUrl'] != null
                          ? Center(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            String srsFileUrl = projectData['fileUrl'];
                            if (await canLaunchUrl(Uri.parse(srsFileUrl))) {
                              await launchUrl(Uri.parse(srsFileUrl), mode: LaunchMode.externalApplication);
                            } else {
                              showErrorSnackbar('Failed to open the document.');
                            }
                          },
                          icon: const Icon(Icons.download, color: Colors.white),
                          label: const Text('Download SRS Document'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          ),
                        ),
                      )
                          : const Center(
                        child: Text(
                          'No SRS document available',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
