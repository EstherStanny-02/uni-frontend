// ignore: file_names 
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:demo_app/pages/login_screen.dart';
import 'package:demo_app/utils/images/images.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class Splashscreen extends StatefulWidget{
  const Splashscreen ({super.key});

  @override
  SplashScreenState createState() =>SplashScreenState();

}

// ignore: camel_case_types
class SplashScreenState extends State<Splashscreen>{
  @override
  Widget build(BuildContext context){
    
   return AnimatedSplashScreen(
    splash: Padding(padding: const EdgeInsets.all(30),
    child: ClipOval(
      child: Image.asset(Images.splashImage),
    ),
    ),
    duration: 3000,
    splashIconSize: 200,
    backgroundColor: Colors.white,
    nextScreen:const LoginScreen());
  }
}
