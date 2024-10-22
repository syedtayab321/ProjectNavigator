import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../CustomWidgets/Snakbar.dart';

class ViewPasswordController extends GetxController{

  RxBool show=true.obs;

  void showPassword(){
    show.value=!show.value;
  }
}

class ForgotPasswordController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var isLoading = false.obs;

  Future<void> resetPassword(String email) async {
    isLoading.value = true;
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      showSuccessSnackbar('Password Reset Successfully');
    } catch (e) {
      showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}