import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navigatorapp/CustomWidgets/TextWidget.dart';
import '../CustomWidgets/Snakbar.dart';
import '../Modals/AuthModals.dart';
import '../Portals/AdminPortal/AdminMainScreen.dart';
import '../SharedPreferences/LoginSharedPreference.dart';
import 'LoginPage.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Get.off(() => LoginPage(),
          transition: Transition.fadeIn, duration: const Duration(seconds: 2));
    });
    // _checkLoginStatus();
  }
  Future<void> _checkLoginStatus() async {
    String? uid = await _authService.getUserFromPreferences();
    if (uid != null) {
      UserModel? userModel = await _authService.getUserRole(uid);
      if (userModel != null) {
        if (userModel.role == 'Admin') {
          Timer(const Duration(seconds: 5), () {
            Get.off(() => AdminDashboardPage(),
                transition: Transition.fadeIn, duration: const Duration(seconds: 2));
          });
        } else if(userModel.role == 'Student') {
          Timer(const Duration(seconds: 5), () {
            Get.off(() => AdminDashboardPage(),
                transition: Transition.fadeIn, duration: const Duration(seconds: 2));
          });
        }else if(userModel.role == 'supervisor') {
          Timer(const Duration(seconds: 5), () {
            Get.off(() => AdminDashboardPage(),
                transition: Transition.fadeIn, duration: const Duration(seconds: 2));
          });
        }
      }
      else
      {
        showErrorSnackbar(uid);
      }
    } else {
      Timer(const Duration(seconds: 5), () {
        Get.off(() => LoginPage(),
            transition: Transition.fadeIn, duration: const Duration(seconds: 2));
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.tealAccent.shade700, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(seconds: 2),
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.explore_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "FYP Navigator",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Navigate Your Final Year Projects",
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}