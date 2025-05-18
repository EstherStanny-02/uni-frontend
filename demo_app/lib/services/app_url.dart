class AppUrl {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Authentication endpoints
  static const String login = '$baseUrl/auth/login/';
  static const String register = '$baseUrl/auth/register/';

  // Department endpoints
  static const String departments = '$baseUrl/academics/departments/';

  // Course endpoints
  static const String courses = '$baseUrl/academics/courses/';

  static const String changePassword = '$baseUrl/auth/change-password/';
}
