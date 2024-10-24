import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navigatorapp/CustomWidgets/TextWidget.dart';
import '../CustomWidgets/ElevatedButton.dart';
import '../CustomWidgets/Snakbar.dart';
import 'LoginPage.dart';

class StudentSignUpPage extends StatefulWidget {
  @override
  State<StudentSignUpPage> createState() => _StudentSignUpPageState();
}

class _StudentSignUpPageState extends State<StudentSignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();
  String? _selectedSession;
  String? _selectedDepartment;

  bool loading = false;
  final List<String> _sessions =
  ['2020-2024', '2021-2025', '2022-2026',
    '2023-2027', '2024-2028', '2025-2029',
    '2026-2030', '2027-2031','2028-2032','2029-2033','2030-2034'];
  final List<String> _departments = ['Computer Science',
    'Electrical Engineering', 'Mechanical Engineering',
    'Civil Engineering', 'Software Engineering'];

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        User? user = userCredential.user;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
          showSuccessSnackbar('Email verification sent. Check your email.');

          _firestore.collection('Users').doc(user.uid).set({
            'name': _nameController.text,
            'email': _emailController.text.trim(),
            'role': 'Student',
            'uid': user.uid,
            'session': _selectedSession,
            'department': _selectedDepartment,
            'roll_no': _rollNoController.text,
          });
          await _auth.signOut();
          Get.off(LoginPage());
        }
      } on FirebaseAuthException catch (e) {
        showErrorSnackbar(e.message.toString());
      }finally {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.tealAccent.shade700.withOpacity(0.2),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.volunteer_activism_rounded,
                          size: 50,
                          color:  Colors.tealAccent.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextWidget(
                      title: 'Student Sign Up Now',
                      size: 24,
                        weight: FontWeight.bold,
                        color:  Colors.tealAccent.shade700,
                    ),
                    const SizedBox(height: 8),
                    const CustomTextWidget(
                      title: 'Please fill the details to create an account',
                      size: 16, color: Colors.grey,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _rollNoController,
                      decoration: InputDecoration(
                        labelText: 'Roll Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your roll number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedSession,
                      hint: const CustomTextWidget(title: 'Select Semester'),
                      items: _sessions.map((semester) {
                        return DropdownMenuItem(
                          value: semester,
                          child: Text(semester),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _selectedSession = value;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a semester';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      hint: const CustomTextWidget(title: 'Select Department'),
                      items: _departments.map((department) {
                        return DropdownMenuItem(
                          value: department,
                          child: Text(department),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _selectedDepartment = value;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a department';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: Elevated_button(
                        path: () => loading ? null : _signUp(),
                        color: Colors.white,
                        backcolor: Colors.tealAccent.shade700,
                        text: loading ? 'Please wait...' : 'Signup',
                        radius: 10,
                        padding: 10,
                      ),
                    ),
                    if (loading)
                      const SizedBox(
                        height: 20,
                      ),
                    if (loading)
                      const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomTextWidget(title: "Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            Get.to(LoginPage());
                          },
                          child: CustomTextWidget(
                            title: 'Log In',
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Or connect with'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.facebook),
                          color: Colors.blue,
                          onPressed: () {
                            // Facebook Sign Up functionality
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.mail_outline),
                          color: Colors.red,
                          onPressed: () {
                            // Google Sign Up functionality
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.mail),
                          color: Colors.blue[700],
                          onPressed: () {
                            // LinkedIn Sign Up functionality
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
