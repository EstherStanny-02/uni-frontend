import 'dart:io' if (dart.library.html) 'package:demo_app/database/platform_web.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Initialize the appropriate database factory based on the platform
void initializeDatabaseFactory() {
  try {
    // Check if running on desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
    }
    // For mobile platforms (iOS, Android), the default factory is used
  } catch (e) {
    print('Running on web platform - using appropriate database config');
  
  }
}