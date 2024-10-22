import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../CustomWidgets/Snakbar.dart';

class AddProjectController extends GetxController {
  // Text controllers for fields
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController sessionController = TextEditingController();
  final TextEditingController partnerController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  var selectedSupervisor = ''.obs;
  var selectedDomain = ''.obs;
  final RxBool isFilePicked = false.obs;
  String? fileUrl;
  var isLoading = false.obs;
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('Users');
  final List<String> domains = ['Machine Learning', 'Mobile Development', 'Web Development', 'Data Science','Other'];
  User? currentUser = FirebaseAuth.instance.currentUser;
  var supervisors = <String>[].obs;
  DocumentSnapshot<Map<String, dynamic>>? studentData;
  @override
  void onInit() {
    super.onInit();
    fetchSupervisors();
  }
  // File picker method
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(withData: true);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          await uploadFile(file);
        } else {
          showErrorSnackbar('Error: File data is missing');
        }
      } else {
        showErrorSnackbar('No file selected');
      }
    } catch (e) {
      showErrorSnackbar('Error: Failed to pick file');
      print('Error: $e');
    }
  }

  Future<void> uploadFile(PlatformFile file) async {
    isLoading.value = true;
    try {
      final storageRef = FirebaseStorage.instance.ref('project_files/${file.name}');
      final uploadTask = storageRef.putData(file.bytes!);

      final snapshot = await uploadTask.whenComplete(() {});
      fileUrl = await snapshot.ref.getDownloadURL();
      isFilePicked.value = true;

      showSuccessSnackbar('File uploaded successfully');
    } catch (e) {
      showErrorSnackbar('Error: File upload failed');
    }
    finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSupervisors() async {
    try {
      QuerySnapshot querySnapshot = await usersRef.where('role', isEqualTo: 'supervisor').get();
       studentData = await FirebaseFirestore.instance.
      collection('Users').doc(currentUser!.uid).get();

      supervisors.value = querySnapshot.docs.map((doc) => doc['name'].toString()).toList();
    } catch (e) {
      showErrorSnackbar('Failed to fetch supervisors');
    }
  }
  Future<void> submitProject() async {
    if (projectNameController.text.isEmpty ||
        sessionController.text.isEmpty ||
        selectedSupervisor.isEmpty ||
        selectedDomain.isEmpty ||
        descriptionController.text.isEmpty) {
      showErrorSnackbar('Please fill all required fields');
      return;
    }
    isLoading.value = true;
    User? currentUser = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance.collection('projectRequests').add({
        'studentId' : currentUser!.uid,
        'studentName': studentData!['name'],
        'studentSession': studentData!['session'],
        'studentRollNo': studentData!['roll_no'],
        'projectName': projectNameController.text,
        'session': sessionController.text,
        'partner': partnerController.text.isEmpty ? 'None' : partnerController.text,
        'supervisor': selectedSupervisor.value,
        'domain': selectedDomain.value,
        'description': descriptionController.text,
        'status': 'pending',
        'fileUrl': fileUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      dispose();
      showSuccessSnackbar("Project Added Successfully");
    } catch (error) {
      showErrorSnackbar("Failed to add the project");
      print(error);
    }finally{
      isLoading.value = false;
    }
  }

  @override
  void dispose(){
    super.dispose();
    projectNameController.clear();
    sessionController.clear();
    descriptionController.clear();
    partnerController.clear();
  }
}
