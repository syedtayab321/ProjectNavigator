import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navigatorapp/CustomWidgets/TextWidget.dart';

import '../Controllers/PasswordController.dart';
import '../CustomWidgets/ElevatedButton.dart';

class ForgotPasswordPage extends StatelessWidget {
  final ForgotPasswordController _controller = Get.put(ForgotPasswordController());
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const CustomTextWidget(title: "Forgot Password",color: Colors.white,),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.teal.shade700.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lock_outline,
                      size: 50,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your email to receive a password reset link',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: Elevated_button(
                    path: _controller.isLoading.value
                        ? () {} // Provide an empty function when disabled
                        : () {
                      _controller.resetPassword(_emailController.text);
                    },
                    color: Colors.white,
                    backcolor: Colors.teal.shade700,
                    text: _controller.isLoading.value ? 'Sending...' : 'Send Reset Link',
                    radius: 10,
                    padding: 10,
                  ),
                )),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CustomTextWidget(title: "Remember your password? "),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: CustomTextWidget(
                        title: 'Log In',
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
