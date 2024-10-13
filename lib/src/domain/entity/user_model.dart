class UserModel {
  final String email;
  final String name;
  final DateTime createdAt;
  final String uid;
  UserModel({
    required this.email,
    required this.name,
    required this.uid,
    required this.createdAt
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'uid': uid,
      'createdAt': createdAt
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      createdAt: map['createdAt'] ?? ''
    );
  }
}