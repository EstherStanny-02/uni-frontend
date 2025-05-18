// This is a stub file to allow conditional imports for web platforms
// platform_web.dart

// Create a stub Platform class that mimics the functionality needed
class Platform {
  static bool get isWindows => false;
  static bool get isLinux => false;
  static bool get isMacOS => false;
  static bool get isIOS => false;
  static bool get isAndroid => false;
  static bool get isWeb => true;

  static String get operatingSystem => 'web';
}
