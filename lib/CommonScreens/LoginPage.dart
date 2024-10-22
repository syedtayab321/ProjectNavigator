import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navigatorapp/Controllers/PasswordController.dart';
import '../../Controllers/LoginController.dart';
import '../../CustomWidgets/ElevatedButton.dart';
import '../../CustomWidgets/IconButton.dart';
import '../../CustomWidgets/TextWidget.dart';
import 'ForgotPasswordPage.dart';
import 'SignUpScreen.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController loginController = Get.put(LoginController());
  final ViewPasswordController _visibilityController = Get.put(ViewPasswordController());
  void SignUpPageSelector() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Choose Signup Type',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.tealAccent.shade700,
          ),
        ),
        content: const Text(
          'Please select the type of account you want to create:',
          style: TextStyle(fontSize: 16),
        ),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent.shade700, // Button color
              foregroundColor: Colors.white, // Text color
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Get.to(() => StudentSignUpPage());
            },
            child: Text('Student Signup'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Add the WavyHeader at the top of the screen
            WavyHeader(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Log In Header Text
                  Text(
                    'Log In Now',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const CustomTextWidget(
                    title: 'Please login to continue using our app',
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 30),

                  // Email Input Field
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: loginController.emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    return TextFormField(
                      keyboardType: TextInputType.text,
                      controller: loginController.passwordController,
                      obscureText: _visibilityController.show.value,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: Icon_Button(
                          onPressed: () {
                            _visibilityController.showPassword();
                          },
                          icon: _visibilityController.show.value
                              ? const Icon(Icons.remove_red_eye_outlined)
                              : const Icon(Icons.remove_red_eye),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Get.to(ForgotPasswordPage());
                      },
                      child: CustomTextWidget(
                        title: 'Forgot Password?',
                        color: Colors.tealAccent.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() {
                      return loginController.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : Elevated_button(
                        path: loginController.login,
                        color: Colors.white,
                        backcolor: Colors.tealAccent.shade700,
                        text: 'Login',
                        radius: 10,
                        padding: 10,
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomTextWidget(title: "Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          SignUpPageSelector();
                        },
                        child: CustomTextWidget(
                          title: 'Sign Up',
                          color: Colors.tealAccent.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const CustomTextWidget(title: 'Or connect with'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.facebook),
                        color: Colors.blue,
                        onPressed: () {
                          // Facebook Login functionality
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.mail_outline),
                        color: Colors.red,
                        onPressed: () {
                          // Google Login functionality
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.g_mobiledata),
                        color: Colors.blue[700],
                        onPressed: () {
                          // LinkedIn Login functionality
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class WavyHeader extends StatelessWidget {
  const WavyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WavyClipper(),
      child: Container(
        height: 250, // Increased the height here
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Text(
            'Welcome Back',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class WavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
    Offset(size.width - (size.width / 4), size.height - 100);
    var secondEndPoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
