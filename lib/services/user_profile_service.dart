import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfile {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final int age;
  final String bio;
  final String goals;
  final String? photoUrl;
  final DateTime? lastUpdated;

  UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.age = 0,
    this.bio = '',
    this.goals = '',
    this.photoUrl,
    this.lastUpdated,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      bio: map['bio'] ?? '',
      goals: map['goals'] ?? '',
      photoUrl: map['photoUrl'],
      lastUpdated: map['lastUpdated']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'age': age,
      'bio': bio,
      'goals': goals,
      'photoUrl': photoUrl,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obtiene el perfil del usuario actual
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!, user.uid);
      } else {
        // Si no existe el documento, crear uno básico con la información de Firebase Auth
        final basicProfile = UserProfile(
          uid: user.uid,
          firstName: user.displayName ?? '',
          lastName: '',
          email: user.email ?? '',
          photoUrl: user.photoURL,
        );

        await updateUserProfile(basicProfile);
        return basicProfile;
      }
    } catch (e) {
      throw Exception('Error al obtener el perfil del usuario: $e');
    }
  }

  /// Actualiza el perfil del usuario
  Future<void> updateUserProfile(UserProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    try {
      // Actualizar en Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(profile.toMap(), SetOptions(merge: true));

      // Actualizar displayName en Firebase Auth si cambió
      if (profile.fullName.isNotEmpty && profile.fullName != user.displayName) {
        await user.updateDisplayName(profile.fullName);
      }

      // Actualizar photoURL en Firebase Auth si cambió
      if (profile.photoUrl != null &&
          profile.photoUrl!.isNotEmpty &&
          profile.photoUrl != user.photoURL) {
        await user.updatePhotoURL(profile.photoUrl);
      }
    } catch (e) {
      throw Exception('Error al actualizar el perfil: $e');
    }
  }

  /// Obtiene los datos básicos del usuario actual desde Firebase Auth
  UserProfile? getBasicUserInfo() {
    final user = _auth.currentUser;
    if (user == null) return null;

    final displayNameParts = user.displayName?.split(' ') ?? [];
    return UserProfile(
      uid: user.uid,
      firstName: displayNameParts.isNotEmpty ? displayNameParts[0] : '',
      lastName: displayNameParts.length > 1
          ? displayNameParts.sublist(1).join(' ')
          : '',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }

  /// Stream para escuchar cambios en el perfil del usuario
  Stream<UserProfile?> get userProfileStream {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!, user.uid);
      }
      return null;
    });
  }

  /// Elimina la foto de perfil
  Future<void> removeProfilePhoto() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    try {
      // Actualizar en Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': FieldValue.delete(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Actualizar en Firebase Auth
      await user.updatePhotoURL(null);
    } catch (e) {
      throw Exception('Error al eliminar la foto de perfil: $e');
    }
  }
}
