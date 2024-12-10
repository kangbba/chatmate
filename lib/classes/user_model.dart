
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class UserModel {
  static const String kUidKey = 'uid';
  static const String kDisplayNameKey = 'displayName';
  static const String kEmailKey = 'email';
  static const String kPhotoURLKey = 'photoURL';

  final String uid;
  final String displayName;
  final String email;
  final String photoURL;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoURL,
  });

  Map<String, dynamic> toMap() {
    return {
      kUidKey: uid,
      kDisplayNameKey: displayName,
      kEmailKey: email,
      kPhotoURLKey: photoURL,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map[kUidKey] ?? '',
      displayName: map[kDisplayNameKey] ?? '',
      email: map[kEmailKey] ?? '',
      photoURL: map[kPhotoURLKey] ?? '',
    );
  }

  factory UserModel.fromFirebaseSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  factory UserModel.fromFirebaseUser(User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      displayName: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      photoURL: firebaseUser.photoURL ?? '',
    );
  }
}


