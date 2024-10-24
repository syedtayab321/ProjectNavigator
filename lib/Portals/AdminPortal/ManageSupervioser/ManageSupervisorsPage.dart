import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../CustomWidgets/Snakbar.dart';
import '../DatabaseSavingData/SupervisorSavinData.dart';

class ManageSupervisorsPage extends StatefulWidget {
  @override
  _ManageSupervisorsPageState createState() => _ManageSupervisorsPageState();
}

class _ManageSupervisorsPageState extends State<ManageSupervisorsPage> {
  User? user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;
  String? selectedDepartment;

  final List<String> departments = [
    'Computer Science',
    'Electrical Engineering', 'Mechanical Engineering',
    'Civil Engineering', 'Software Engineering'
  ];

  void _showAddEditSupervisorDialog(
      {String? name, String? email, String? password, String? department, int? index, String? uid}) {
    TextEditingController supervisorNameController = TextEditingController(text: name ?? '');
    TextEditingController supervisorEmailController = TextEditingController(text: email ?? '');
    TextEditingController supervisorPasswordController = TextEditingController(text: password ?? '');

    selectedDepartment = department;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Use StatefulBuilder to update the dropdown selection
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                index == null ? 'Add New Supervisor' : 'Edit Supervisor',
                style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField('Supervisor Name', supervisorNameController),
                    const SizedBox(height: 10),
                    if (index == null) ...[
                      _buildTextField('Supervisor Email', supervisorEmailController),
                      const SizedBox(height: 10),
                      _buildTextField('Supervisor Password', supervisorPasswordController),
                      const SizedBox(height: 10),
                    ],
                    DropdownButtonFormField<String>(
                      value: selectedDepartment,
                      hint: const Text('Select Department'),
                      items: departments.map((String department) {
                        return DropdownMenuItem<String>(
                          value: department,
                          child: Text(department),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDepartment = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
                isLoading
                    ? const CircularProgressIndicator() // Show loading indicator while data is being added
                    : ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });

                    if (index == null) {
                      try {
                        await createSuperVisorAndAddData(
                            supervisorNameController.text,
                            supervisorEmailController.text,
                            supervisorPasswordController.text,
                            selectedDepartment ?? '');
                        showSuccessSnackbar('Supervisor added successfully!');
                      } catch (e) {
                        showErrorSnackbar(e.toString());
                      }
                    } else {
                      try {
                        await updateSupervisor(
                          uid ?? '',
                          supervisorNameController.text,
                          selectedDepartment ?? '',
                        );
                        showSuccessSnackbar('Supervisor updated successfully!');
                      } catch (e) {
                        showErrorSnackbar(e.toString());
                      }
                    }

                    setState(() {
                      isLoading = false;
                    });

                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(index == null ? 'Add' : 'Update',
                      style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.teal, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Supervisors',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.tealAccent.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'List of Supervisors',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .where('role', isEqualTo: 'supervisor')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No Supervisors found'));
                  }
                  final supervisors = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: supervisors.length,
                    itemBuilder: (context, index) {
                      final supervisor = supervisors[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade700,
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            supervisor['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          trailing: const Icon(Icons.arrow_drop_down, color: Colors.teal),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('Email:', supervisor['email']),
                                  _buildDetailRow('Password:', supervisor['password']),
                                  _buildDetailRow('Department:', supervisor['department']),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Edit Button
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          _showAddEditSupervisorDialog(
                                            name: supervisor['name'],
                                            email: supervisor['email'],
                                            password: supervisor['password'],
                                            department: supervisor['department'],
                                            index: index,
                                            uid: supervisor['uid'],
                                          );
                                        },
                                        icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                                        label: const Text('Edit', style: TextStyle(fontSize: 16, color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal.shade700,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Delete Button
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          deleteSupervisor(supervisor['uid'], supervisor['email'], supervisor['password']);
                                        },
                                        icon: const Icon(Icons.delete, size: 16, color: Colors.white),
                                        label: const Text('Delete', style: TextStyle(fontSize: 16, color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditSupervisorDialog();
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$title ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
