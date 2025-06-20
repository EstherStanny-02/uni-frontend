class AppUrl {
  static const String localhost = 'http://127.0.0.1:8000/api';

  // Authentication endpoints
  static const baseUrl = localhost;
  static const String login = '$baseUrl/auth/login/';
  static const String register = '$baseUrl/auth/register/';

  // Department endpoints
  static const String departments = '$baseUrl/academics/departments/';

  // Course endpoints
  static const String courses = '$baseUrl/academics/courses/';

  static const String changePassword = '$baseUrl/auth/change-password/';

  // Message endpoints
  static const String messages = '$baseUrl/auth/messages/';
}
