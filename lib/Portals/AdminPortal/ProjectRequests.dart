import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:navigatorapp/CustomWidgets/Snakbar.dart';
import 'package:navigatorapp/CustomWidgets/TextWidget.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class ProjectRequestsPage extends StatefulWidget {
  @override
  _ProjectRequestsPageState createState() => _ProjectRequestsPageState();
}

class _ProjectRequestsPageState extends State<ProjectRequestsPage> {
  String? _selectedSupervisor;

  void _approveProject(String projectId, String supervisor) async {
    await FirebaseFirestore.instance.collection('projectRequests').doc(projectId).update({
        'status': 'approved',
        'supervisor': supervisor,
        'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('Notifications').add({
      'Message': 'Your Project Approved By Admin and Supervisor Assigned to you is $supervisor',
      'From':'Admin',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _rejectProject(String projectId) async {
    await FirebaseFirestore.instance.collection('projectRequests').doc(projectId).update({
      'status': 'Rejected',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('Notifications').add({
      'details': 'Your Project Rejected By Admin Contact Admin for Details',
      'from':'Admin',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('projectRequests').where('status',isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No project requests found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var project = snapshot.data!.docs[index];
              var projectId = project.id;

              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProjectDetail('Project Title:', project['projectName'], Icons.book),
                      const SizedBox(height: 10),
                      _buildProjectDetail('Student 1:', project['studentName'], Icons.person),
                      const SizedBox(height: 16),
                      _buildProjectDetail('Student 2:', project['partner'], Icons.person),
                      const SizedBox(height: 16),
                      _buildProjectDetail('Supervisor:', project['supervisor'], Icons.person_outline),
                      const SizedBox(height: 16),
                      _buildProjectDetail('Description:', project['description'], Icons.description),
                      const SizedBox(height: 16),
                      _buildFileButton(project['fileUrl']),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildActionButton(
                            label: 'Approve',
                            color: Colors.green.shade600,
                            onPressed: () {
                              _showSupervisorSelector(context, projectId);
                            },
                            icon: Icons.check,
                          ),
                          _buildActionButton(
                            label: 'Reject',
                            color: Colors.red.shade600,
                            onPressed: () {
                              _rejectProject(projectId);
                            },
                            icon: Icons.close,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  Widget _buildProjectDetail(String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue[300]),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$title ',
              style:  TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[300],
                  fontSize: 15
              ),
              children: <TextSpan>[
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ],
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

  Widget _buildActionButton({required String label, required Color color, required void Function() onPressed, required IconData icon}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20,color: Colors.white,),
      label: CustomTextWidget(
        title: label,
        size: 16, weight: FontWeight.bold,color: Colors.white),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Method to show the supervisor selection dialog
  void _showSupervisorSelector(BuildContext context, String projectId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Supervisor'),
          content: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Users').where('role',isEqualTo:'supervisor').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No supervisors available');
              }
              return DropdownButtonFormField<String>(
                value: _selectedSupervisor,
                items: snapshot.data!.docs.map((supervisor) {
                  return DropdownMenuItem<String>(
                    value: supervisor['name'],
                    child: Text(supervisor['name']),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedSupervisor = newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select Supervisor',
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_selectedSupervisor != null) {
                  _approveProject(projectId, _selectedSupervisor!);
                  Navigator.pop(context);
                } else {
                  Get.snackbar('Error', 'Please select a supervisor');
                }
              },
              child: const Text('Approve'),
            ),
          ],
        );
      },
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
}
