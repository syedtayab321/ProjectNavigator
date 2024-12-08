import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../CustomWidgets/ElevatedButton.dart'; // Ensure the path is correct

class ManageUsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Students',
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
          children: [
            // Search Bar
            Container(
              width: screenWidth * 0.9,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: 'Enter Student Roll No.',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .where('role', isEqualTo: 'Student')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching data'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No students found'));
                } else {
                  final students = snapshot.data!.docs;
                  return Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 10,
                        childAspectRatio: 5 / 4,
                      ),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index].data() as Map<String, dynamic>;
                        return UserCard(
                          name: student['name'] ?? 'N/A',
                          uid: student['uid'] ?? 'N/A',
                          rollno: student['roll_no'] ?? 'N/A',
                          email: student['email'] ?? 'N/A',
                          department: student['department'] ?? 'N/A',
                          session: student['session'] ?? 'N/A',
                          status: student['status'] ?? 'N/A',
                          semester: student['semester'] ?? 'N/A',
                        );
                      },
                    ),
                  );
                }
              },
            ),

          ],
        ),
      ),
    );
    ///
  }
}


class UserCard extends StatelessWidget {
  final String name;
  final String uid;
  final String rollno;
  final String email;
  final String department;
  final String session;
  final String status;

  UserCard({
    required this.name,
    required this.uid,
    required this.rollno,
    required this.email,
    required this.department,
    required this.session,
    required this.status, required semester,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.teal.shade700),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                session,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.to(() => StudentDetailsPage(
                    name: name,
                    uid: uid,
                    rollno: rollno,
                    email: email,
                    department:department,
                    session: session,
                    status: status,
                  ));
                },
                child: Text(
                  'View Details',
                  style: TextStyle(color: Colors.teal.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentDetailsPage extends StatelessWidget {
  final String name;
  final String uid;
  final String rollno;
  final String email;
  final String department;
  final String session;
  final String status;

  StudentDetailsPage({
    required this.name,
    required this.uid,
    required this.email,
    required this.department,
    required this.status,
    required this.rollno,
    required this.session,
  });

  void updateStatus(String id, String status, String email) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(id).update({
        'status': status,
      });

      Get.snackbar(
        'Success',
        'Student status updated to $status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            buildDetailCard('Roll No:', rollno),
            buildDetailCard('Email:', email),
            buildDetailCard('Department:', department),
            buildDetailCard('Session:', session),
            buildDetailCard('Status:', status),
            const SizedBox(height: 20),
            Elevated_button(
              text: 'Delete Student',
              color: Colors.white,
              backcolor: Colors.teal.shade700,
              path: () {
                _showDeleteConfirmationDialog(context, uid);
              },
              radius: 10.0,
              padding: 16.0,
              fontsize: 16.0,
              width: 310.0,
            ),
            const SizedBox(height: 10,),
            Elevated_button(
              text: 'Request Status',
              color: Colors.white,
              backcolor: Colors.teal.shade700,
              path: () {
                _showRequestDialog(
                  context,
                  uid,
                  email,
                  updateStatus,
                );
              },
              radius: 10.0,
              padding: 16.0,
              fontsize: 16.0,
              width: 310.0,
            ),

          ],
        ),
      ),
    );
  }

  Widget buildDetailCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(value),
          ],
        ),
      ),
    );
  }
}
void _showDeleteConfirmationDialog(BuildContext context, String id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.delete, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text(
              'Delete Confirmation',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to delete this student? This action cannot be undone.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  deleteStudent(id);
                  Navigator.pop(context); // Close dialog after deleting
                },
                child: const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      );
    },
  );
}
void deleteStudent(String id) async {
  try {
    await FirebaseFirestore.instance.collection('Users').doc(id).delete();
    Get.snackbar(
      'Success',
      'Student record deleted successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.teal.shade700,
      colorText: Colors.white,
    );

    Get.back();
  } catch (e) {
    Get.snackbar(
      'Error',
      'Failed to delete student: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
void _showRequestDialog(BuildContext context, String id, String email, Function(String, String, String) updateStatus) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue, size: 28),
            SizedBox(width: 10),
            Text(
              'Request Confirmation',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: const Text(
          "Do you want to approve or reject the request?",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  updateStatus(id, 'approved', email);
                  Navigator.pop(context);
                },
                child: const Text('Approve', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  updateStatus(id, 'rejected', email);
                  Navigator.pop(context);  // Reject and close
                },
                child: const Text('Reject', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      );
    },
  );
}
