import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfile {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime? dateOfBirth;
  final String bio;
  final String goals;
  final String? photoUrl;
  final DateTime? lastUpdated;

  UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.dateOfBirth,
    this.bio = '',
    this.goals = '',
    this.photoUrl,
    this.lastUpdated,
  });

  String get fullName => '$firstName $lastName'.trim();

  /// Edad calculada a partir de la fecha de nacimiento. Devuelve 0 si no hay fecha.
  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int years = now.year - dateOfBirth!.year;
    final birthdayThisYear = DateTime(
      now.year,
      dateOfBirth!.month,
      dateOfBirth!.day,
    );
    if (now.isBefore(birthdayThisYear)) years -= 1;
    return years;
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    DateTime? dob;
    try {
      final dobValue = map['dateOfBirth'];
      if (dobValue is Timestamp) {
        dob = dobValue.toDate();
      } else if (dobValue is String) {
        dob = DateTime.tryParse(dobValue);
      } else if (dobValue is Map && dobValue['_seconds'] != null) {
        // Fallback for firebaselike map
        dob = DateTime.fromMillisecondsSinceEpoch(
          (dobValue['_seconds'] as int) * 1000,
        );
      }
    } catch (e) {
      dob = null;
    }

    return UserProfile(
      uid: uid,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      dateOfBirth: dob,
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
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
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
      // Actualizar en Firestore con merge para no sobrescribir otros campos
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(profile.toMap(), SetOptions(merge: true));

      // Actualizar displayName en Firebase Auth si cambió
      final newDisplayName = profile.fullName;
      if (newDisplayName.isNotEmpty && newDisplayName != user.displayName) {
        await user.updateDisplayName(newDisplayName);
      }

      // Actualizar photoURL en Firebase Auth si cambió
      if (profile.photoUrl != null &&
          profile.photoUrl!.isNotEmpty &&
          profile.photoUrl != user.photoURL) {
        await user.updatePhotoURL(profile.photoUrl);
      } else if (profile.photoUrl == null && user.photoURL != null) {
        // Si se eliminó la foto en el perfil, también eliminarla de Auth
        await user.updatePhotoURL(null);
      }

      // Recargar el usuario para obtener los cambios
      await user.reload();
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
