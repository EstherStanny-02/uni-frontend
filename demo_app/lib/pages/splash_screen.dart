


// ignore: file_names 
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:demo_app/pages/login_screen.dart';
import 'package:demo_app/utils/images/images.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class SplashScreen extends StatefulWidget{
  const SplashScreen ({super.key});

  @override
  SplashScreenState createState() =>SplashScreenState();

}

class SplashScreenState extends State<SplashScreen>{
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



// import 'package:demo_app/theme/theme.dart';
// import 'package:device_preview/device_preview.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:demo_app/providers/auth_provider.dart';
// import 'package:demo_app/providers/user_provider.dart';

// void main(){
//   runApp(DevicePreview(builder:(context) =>const MyApp()));


// void main() {
//   runApp(
//     DevicePreview(
//       builder: (context) => MultiProvider(
//         providers: [
//           ChangeNotifierProvider(create: (_) => AuthProvider()),
//           ChangeNotifierProvider(create: (_) => UserProvider()),
//         ],
//         child: const MyApp(),
//       ),
//     ),
//   );
// }

// class MyApp extends StatefulWidget{
//   const MyApp ({super.key});
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   MyAppState createState() => MyAppState();

// }

// class MyAppState extends State<MyApp>{
// class MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context){
//     return   MaterialApp(
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Uni-Schooling',
//       theme: AppThemeController.lightMode,
//       home:const SplashScreen(),

//       home: const SplashScreen(),
//     );
//   }
// }
