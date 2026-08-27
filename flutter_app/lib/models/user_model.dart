import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory to create a UserModel from a Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Missing data for UserModel: ${doc.id}');
    }

    return UserModel(
      uid: doc.id,
      name: data['name'] as String? ?? 'User',
      email: data['email'] as String? ?? '',
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: (data['updatedAt'] is Timestamp)
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Factory to create a UserModel from a standard Map
  factory UserModel.fromMap(Map<String, dynamic> data, {String? uid}) {
    return UserModel(
      uid: uid ?? data['uid'] as String? ?? '',
      name: data['name'] as String? ?? 'User',
      email: data['email'] as String? ?? '',
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : (data['createdAt'] != null
              ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
      updatedAt: (data['updatedAt'] is Timestamp)
          ? (data['updatedAt'] as Timestamp).toDate()
          : (data['updatedAt'] != null
              ? DateTime.tryParse(data['updatedAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  /// Convert UserModel to Map for Firestore persistence (Never stores passwords)
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert to a regular Map for local persistence
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
