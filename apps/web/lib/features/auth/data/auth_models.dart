class AppUser {
  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneCountryCode,
    required this.phoneNumber,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneCountryCode;
  final String phoneNumber;

  String get fullName => '$firstName $lastName'.trim();

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneCountryCode: json['phoneCountryCode']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneCountryCode': phoneCountryCode,
        'phoneNumber': phoneNumber,
      };
}

class AuthSession {
  const AuthSession({required this.user, required this.accessToken});

  final AppUser user;
  final String accessToken;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken']?.toString() ?? '',
    );
  }
}
