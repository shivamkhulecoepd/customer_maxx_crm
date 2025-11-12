class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? password;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['fullname'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      password: json['password'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': name,
      'email': email,
      'role': role,
      'password': password,
    };
  }
}

class UserRole {
  final String id;
  final String name;

  UserRole({
    required this.id,
    required this.name,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'].toString(),
      // name: json['fullname'] as String,
      name: json['name'] as String? ?? json['fullname'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

