class User {
  String? firstName;
  String? lastName;
  String? userName;
  String? email;
  String? accessToken;
  String? refreshToken;

  var phone;

  User({
    this.firstName,
    this.lastName,
    this.email,
    this.accessToken,
    this.refreshToken,
    String? phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email']?.toString(),
      accessToken: json['access_token']?.toString(),
      refreshToken: json['refresh']?.toString(), // Key changed to 'refresh'
    );
  }
}
