import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../CustomWidgets/ElevatedButton.dart';
import '../../../CustomWidgets/Snakbar.dart';
import '../../../CustomWidgets/TextWidget.dart';

class UpdateStudentPage extends StatefulWidget {
  late String name;
  late String session;
  late String department;

  UpdateStudentPage({required this.name, required this.session, required this.department});

  @override
  _UpdateStudentPageState createState() => _UpdateStudentPageState();
}

class _UpdateStudentPageState extends State<UpdateStudentPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _semester;
  late String _department;

  final List<String> _sessionList = [
    '2020-2024', '2021-2025', '2022-2026',
    '2023-2027', '2024-2028', '2025-2029',
    '2026-2030', '2027-2031','2028-2032','2029-2033','2030-2034'
  ];

  final List<String> _departmentsList = [
    'Computer Science', 'Electrical Engineering',
    'Mechanical Engineering', 'Civil Engineering',
    'Chemical Engineering', 'Software Engineering'
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _semester = widget.session;
    _department = widget.department;
  }

  void _updateUser() async{
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        widget.name = _name;
        widget.session = _semester;
        widget.department = _department;
      });
      User? user = FirebaseAuth.instance.currentUser;
      try{
        await FirebaseFirestore.instance.collection('Users').doc(user!.uid).update(
            {
              'name':widget.name,
              'department':widget.department,
              'semester':widget.session,
            });
        showSuccessSnackbar('Student Data Updated Sucessfully');
      } catch(e){
        showErrorSnackbar(e.toString());
      }finally{
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomTextWidget(title: 'Update Student Data',color:Colors.white ,),
        backgroundColor: Colors.teal.shade800,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomTextWidget(
                        title: 'Update Information',
                        size: 24,
                        weight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: _name,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        onSaved: (value) => _name = value!,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _semester,
                        decoration: const InputDecoration(
                          labelText: 'Semester',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.school),
                        ),
                        items: _sessionList.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _semester = newValue!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a semester';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _department,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.engineering),
                        ),
                        items: _departmentsList.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _department = newValue!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a department';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      Center(
                          child: Elevated_button(
                            text: 'Update',
                            backcolor: Colors.blueAccent,
                            padding: 10,
                            radius: 6,
                            width: 200,
                            height: 15,
                            color: Colors.white,
                            path: _updateUser,
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
