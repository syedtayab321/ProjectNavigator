import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../CustomWidgets/Snakbar.dart';

Future<void> createSuperVisorAndAddData(
    String name, String email, String password, String department) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    String uid = userCredential.user!.uid;
    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    await users.doc(uid).set({
      'name': name,
      'uid': uid,
      'email': email,
      'password': password,
      'role': 'supervisor',
      'department': department,
      'createdAt': FieldValue.serverTimestamp(), // Optional: add timestamp
    });
    Get.back();
    showSuccessSnackbar(
        'User account created and data added successfully with UID: $uid');
  } catch (e) {
    showErrorSnackbar('Error creating user or adding data: $e');
  }
}

Future<void> deleteSupervisor(
    String supervisorId, String email, String password) async {
  try {
    // Step 1: Get the user's credentials using email and password.
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Step 2: Delete the user from Firebase Authentication.
    await userCredential.user!.delete();

    // Step 3: Delete the supervisor from Firestore.
    CollectionReference supervisorsCollection =
        FirebaseFirestore.instance.collection('Users');
    await supervisorsCollection.doc(supervisorId).delete();

    // Show success message
    showSuccessSnackbar('Supervisor deleted successfully.');
  } catch (e) {
    showErrorSnackbar('Error deleting supervisor: $e');
  }
}

Future<void> updateSupervisor(
    String uid, String name, String department) async {
  try {
    await FirebaseFirestore.instance.collection('Users').doc(uid).update({
      'name': name,
      'department': department,
    });

    showSuccessSnackbar('Supervisor updated successfully');
  } catch (e) {
    showErrorSnackbar('Failed to update supervisor: $e');
    print(e.toString());
  }
}
