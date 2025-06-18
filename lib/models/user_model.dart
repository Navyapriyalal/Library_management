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
  final String gender;

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
    required this.gender,
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
      'gender': gender,
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
      gender: map['gender'] as String,
    );
  }

  User copyWith({
    String? name,
    String? email,
    String? mobile,
    String? address,
    String? role,
    String? aadhar,
    String? password,
    String? profile,
    String? gender,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      role: role ?? this.role,
      password: password ?? this.password,
      aadhar: aadhar ?? this.aadhar,
      profile: profile ?? this.profile,
      gender: gender ?? this.gender,
    );
  }

}
