import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navigatorapp/CustomWidgets/Snakbar.dart';
import 'package:navigatorapp/CustomWidgets/TextWidget.dart';
import 'package:navigatorapp/Portals/SupervioserPortal/SuperVisorMessageScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ProjectDetailsPage extends StatelessWidget {
  final Map<String, dynamic> project;

  ProjectDetailsPage({required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.tealAccent,
        foregroundColor: Colors.black,
        title: const Text('Project Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 50,
                  child: Text(
                    project['studentName']?[0].toUpperCase() ?? 'S',
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  project['projectName'] ?? 'No Title',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
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
              _buildProjectDetailRow(
                title: "Description:",
                value: project['description'] ?? 'No Description',
                icon: Icons.description,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _downloadAndOpenFile(context, project['fileUrl']),
                  icon: const Icon(Icons.download,color: Colors.white),
                  label: const CustomTextWidget(title: "View File",color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(
                        SupervisorMessageScreen(
                      receiverId: project['studentId'],
                      receiverName: project['studentName'],
                    ));
                  },
                  icon: const Icon(Icons.message,color: Colors.white,),
                  label: const CustomTextWidget(title: "Message",color: Colors.white,),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build project detail rows
  Widget _buildProjectDetailRow({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$title ",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
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

  Future<void> _downloadAndOpenFile(BuildContext context, String fileUrl) async {
    if (fileUrl.isEmpty) {
      showSuccessSnackbar('No file URL available');
      return;
    }

    try {
      final Dio dio = Dio();
      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/project_file.pdf";
      showSuccessSnackbar("Downloading file...");
      await dio.download(fileUrl, filePath);

      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        showErrorSnackbar("Failed to open the file: ${result.message}");
      }
    } catch (e) {
      showErrorSnackbar('Error downloading file: $e');
    }
  }
}


