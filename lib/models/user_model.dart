import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String name;
  final DateTime createdAt;

  User({
    required this.uid,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  // Convert User to Map for Firestore
  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email, 'name': name, 'createdAt': createdAt};
  }

  // Create User from firestore data

  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      uid: documentId,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
