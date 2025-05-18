import 'package:demo_app/database/database_config.dart';
import 'package:demo_app/pages/splash_screen.dart';
import 'package:demo_app/providers/auth_provider.dart';
import 'package:demo_app/theme/theme.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:demo_app/providers/user_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Only initialize database if not running on web
  // Flutter provides kIsWeb constant to check if running on web
  if (!kIsWeb) {
    initializeDatabaseFactory();
  } else {
    // Web-specific initialization if needed
    print('Running on web platform - skipping native database initialization');
  }

  runApp(
    DevicePreview(
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uni-Schooling',
      theme: AppThemeController.lightMode,
      home: const SplashScreen(),
    );
  }
}
