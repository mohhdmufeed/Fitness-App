import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? get _usersCollection =>
      _firestore?.collection('users');

  /// Create a new user profile document in Firestore under `users/{uid}`
  /// Server timestamp is used for createdAt and updatedAt. Passwords are NEVER saved.
  Future<void> createUserProfile(UserModel user) async {
    final collection = _usersCollection;
    if (collection == null) return;
    final docRef = collection.doc(user.uid);
    await docRef.set({
      'uid': user.uid,
      'name': user.name,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get user profile by UID (Works offline with Firestore local cache)
  Future<UserModel?> getUserProfile(String uid) async {
    final collection = _usersCollection;
    if (collection == null) return null;
    try {
      final docSnap = await collection.doc(uid).get(
            const GetOptions(source: Source.serverAndCache),
          );

      if (docSnap.exists && docSnap.data() != null) {
        return UserModel.fromFirestore(docSnap);
      }
      return null;
    } catch (_) {
      // Fallback to cache only if network fails
      try {
        final cacheSnap = await collection.doc(uid).get(
              const GetOptions(source: Source.cache),
            );
        if (cacheSnap.exists && cacheSnap.data() != null) {
          return UserModel.fromFirestore(cacheSnap);
        }
      } catch (_) {}
      return null;
    }
  }

  /// Stream real-time updates for the user profile document
  Stream<UserModel?> streamUserProfile(String uid) {
    final collection = _usersCollection;
    if (collection == null) return const Stream.empty();
    return collection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromFirestore(snapshot);
      }
      return null;
    });
  }

  /// Update user profile data with automatic updatedAt server timestamp
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    final collection = _usersCollection;
    if (collection == null) return;
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await collection.doc(uid).update(updates);
  }
}
