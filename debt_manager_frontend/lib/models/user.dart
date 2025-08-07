class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String? phoneNumber;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
    };
  }
}
