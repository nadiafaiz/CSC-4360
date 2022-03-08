import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String? uid;
  String? email;
  String? firstName;
  String? lastName;
  String? role;
  Timestamp? timestamp;

  AppUser(
      {this.uid,
      this.email,
      this.firstName,
      this.lastName,
      this.role,
      this.timestamp});

  factory AppUser.fromMap(map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      role: map['role'],
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'timestamp': timestamp,
    };
  }
}

enum Role { user, admin }
