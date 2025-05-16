// ignore: file_names
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:demo_app/pages/login_screen.dart';
import 'package:demo_app/utils/images/images.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        splash: Padding(
          padding: const EdgeInsets.all(30),
          child: ClipOval(
            child: Image.asset(Images.splashImage),
          ),
        ),
        duration: 3000,
        splashIconSize: 200,
        backgroundColor: Colors.white,
        nextScreen: const LoginScreen());
  }
}


