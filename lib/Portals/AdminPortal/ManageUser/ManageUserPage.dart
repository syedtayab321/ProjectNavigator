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
          'Manage Users/Student',
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
      body: SingleChildScrollView(
        child: Padding(
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
                    return SizedBox(
                      height: screenHeight * 0.6,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: screenWidth / (screenHeight * 0.6),
                        ),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index].data() as Map<String, dynamic>;
                          return UserCard(
                            name: student['name'] ?? 'N/A',
                            rollno: student['roll_no'] ?? 'N/A',
                            email: student['email'] ?? 'N/A',
                            department: student['department'] ?? 'N/A',
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
      ),
    );
  }
}


class UserCard extends StatelessWidget {
  final String name;
  final String rollno;
  final String email;
  final String department;
  final String semester;

  UserCard({
    required this.name,
    required this.rollno,
    required this.email,
    required this.department,
    required this.semester,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.teal.shade700),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/user_image.png'), // Replace with your image
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            TextButton(
              onPressed: () {
                Get.to(() => StudentDetailsPage(
                  name: name,
                  registrationNo: rollno,
                  email: email,
                  phone:department,
                  status: semester,
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
    );
  }
}

class StudentDetailsPage extends StatelessWidget {
  final String name;
  final String registrationNo;
  final String email;
  final String phone;
  final String status;

  StudentDetailsPage({
    required this.name,
    required this.registrationNo,
    required this.email,
    required this.phone,
    required this.status,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/user_image.png'), // Replace with actual image
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            buildDetailCard('Roll No:', registrationNo),
            buildDetailCard('Email:', email),
            buildDetailCard('Department:', phone),
            buildDetailCard('Semester:', status),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Elevated_button(
                  text: 'Delete Student',
                  color: Colors.white,
                  backcolor: Colors.teal.shade700,
                  path: () {
                    // Handle Delete Student action
                  },
                  radius: 10.0,
                  padding: 16.0,
                  fontsize: 16.0,
                  width: 310.0,
                ),
              ],
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
