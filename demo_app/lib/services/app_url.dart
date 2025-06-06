class AppUrl {
  static const String baseUrl = 'http://192.168.1.175:8000/api';

  // Authentication endpoints
  static const String login = '$baseUrl/auth/login/';
  static const String register = '$baseUrl/auth/register/';

  // Department endpoints
  static const String departments = '$baseUrl/academics/departments/';

  // Course endpoints
  static const String courses = '$baseUrl/academics/courses/';

  static const String changePassword = '$baseUrl/auth/change-password/';
}
