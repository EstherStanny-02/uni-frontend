class AppUrl {
  static const String liveBaseURL = "https://remote-ur/api/v1";
  static const String localBaseURL = "http://127.0.0.1:8000/api/auth";

  // Use the local base URL for development
  static const String baseURL = localBaseURL;

  // Update the endpoints with trailing slashes as required by the backend
  static const String login = "$baseURL/login/";
  static const String register = "$baseURL/register/";
  static const String forgotPassword = "$baseURL/forgot-password/";
}
