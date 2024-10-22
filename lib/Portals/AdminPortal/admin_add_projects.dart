import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../../CustomWidgets/Snakbar.dart';
import '../../CustomWidgets/ElevatedButton.dart';

class AddProjects extends StatefulWidget {
  @override
  _AddProjectsState createState() => _AddProjectsState();
}

class _AddProjectsState extends State<AddProjects> {
  final List<String> sessions = [
    '2024-2028', '2023-2027', '2022-2026', '2021-2025', '2020-2024',
    '2019-2023', '2018-2022', '2017-2021', '2016-2020', '2015-2019',
    '2014-2018', '2013-2017', '2012-2016', '2011-2015', '2010-2014',
  ];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _projectTitleController = TextEditingController();
  final TextEditingController _supervisorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _student1Controller = TextEditingController();
  final TextEditingController _student2Controller = TextEditingController();
  String? _uploadedFileUrl;
  bool _isUploading = false;
  String? _selectedSession;

  Future<void> _pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _isUploading = true;
        });

        PlatformFile file = result.files.first;
        if (file.path != null) {
          File localFile = File(file.path!);
          final fileBytes = await localFile.readAsBytes();

          String fileName = file.name;
          Reference storageReference = FirebaseStorage.instance
              .ref()
              .child('project_files/$fileName');
          UploadTask uploadTask = storageReference.putData(fileBytes);

          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();

          setState(() {
            _uploadedFileUrl = downloadUrl;
            _isUploading = false;
          });
          showSuccessSnackbar('File uploaded successfully');
        } else {
          _showErrorSnackBar('Failed to read file data.');
        }
      } else {
        _showErrorSnackBar('File upload canceled.');
      }
    } catch (e) {
      _showErrorSnackBar('Error during file upload: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    setState(() {
      _isUploading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addProjectToFirebase() async {
    if (_formKey.currentState!.validate() && _uploadedFileUrl != null) {
      await FirebaseFirestore.instance.collection('PastProjects').add({
        'projectName': _projectTitleController.text,
        'Student1': _student1Controller.text,
        'Student2': _student2Controller.text,
        'supervisor': _supervisorController.text,
        'description': _descriptionController.text,
        'session': _selectedSession,
        'fileUrl': _uploadedFileUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project added successfully!')),
      );

      _formKey.currentState!.reset();
      setState(() {
        _uploadedFileUrl = null;
      });
    } else {
      _showErrorSnackBar('Please fill all fields and upload a file.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Add Project'),
        backgroundColor: Colors.tealAccent.shade400,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField('Project Title', _projectTitleController),
                    _buildTextField('Supervisor Name', _supervisorController),
                    _buildTextField('First Student', _student1Controller),
                    _buildTextField('Second Student (Optional)', _student2Controller),
                    _buildTextField(
                      'Project Description',
                      _descriptionController,
                      maxLines: 3,
                    ),
                    _buildSessionDropdown(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildUploadSection(),
              const SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.tealAccent.shade400, width: 2),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSessionDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedSession,
        items: sessions.map((String session) {
          return DropdownMenuItem<String>(
            value: session,
            child: Text(session),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedSession = newValue;
          });
        },
        decoration: InputDecoration(
          labelText: 'Select Session',
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.tealAccent.shade400, width: 2),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a session';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildUploadSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _pickAndUploadFile,
            icon: const Icon(Icons.upload_file),
            label: Text(_isUploading ? 'Uploading...' : 'Upload Document'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              backgroundColor: Colors.tealAccent.shade400,
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
          if (_uploadedFileUrl != null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'File uploaded successfully',
                style: TextStyle(color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: Elevated_button(
        path: _addProjectToFirebase,
        padding: 10,
        text: 'Add Project',
        radius: 10,
        width: Get.width,
        height: 50,
        color: Colors.white,
        backcolor: Colors.tealAccent.shade400,
      ),
    );
  }
}
