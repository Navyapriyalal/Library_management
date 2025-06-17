class User {
  final int? id;
  final String name;
  final String email;
  final String mobile;
  final String address;
  final String password;
  final String role;
  final String profile; // image path
  final String aadhar;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
    required this.password,
    required this.role,
    required this.profile,
    required this.aadhar,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'address': address,
      'password': password,
      'role': role,
      'profile': profile,
      'aadhar': aadhar,
    };
  }

  static User fromMap(Map<String, Object?> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      mobile: map['mobile'] as String,
      address: map['address'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      profile: map['profile'] as String,
      aadhar: map['aadhar'] as String,
    );
  }
}
