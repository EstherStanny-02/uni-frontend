// ignore: file_names
import 'package:demo_app/pages/login_screen.dart';
import 'package:demo_app/pages/home_screen.dart';
import 'package:demo_app/session/user_preferences.dart';
import 'package:demo_app/utils/images/images.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final UserPreferences _userPreferences = UserPreferences();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start animation
    _animationController.forward();

    // Check user and navigate after 3 seconds
    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    // Wait for 3 seconds (splash duration)
    await Future.delayed(const Duration(seconds: 3));

    try {
      // Check if user exists in preferences
      final user = await _userPreferences.getUser();

      if (mounted) {
        if (user.accessToken != null && user.accessToken!.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      // If there's an error (user not found), go to LoginScreen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: Opacity(
                opacity: _animation.value,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: ClipOval(
                    child: Image.asset(
                      Images.splashImage,
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
