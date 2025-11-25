import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream del usuario actual
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Registro con email y contraseña
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;

      if (user != null) {
        // Actualizar el displayName del usuario
        await user.updateDisplayName(name);
        await user.reload();

        // Crear documento del usuario en Firestore
        await _createUserDocument(user, name);

        return user;
      }
      return null;
    } catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
  }

  // Login con email y contraseña
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
  }

  // Login con Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      final User? user = result.user;

      if (user != null) {
        // Verificar si es un usuario nuevo y crear documento
        if (result.additionalUserInfo?.isNewUser ?? false) {
          await _createUserDocument(user, user.displayName ?? 'Usuario');
        }
      }

      return user;
    } catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
  }

  // Crear documento del usuario en Firestore
  Future<void> _createUserDocument(User user, String name) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': user.email,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  // Obtener datos del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Actualizar datos del usuario
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Error al cerrar sesión: ${e.toString()}');
    }
  }

  // Recuperar contraseña - MÉTODO AGREGADO
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
  }

  // Enviar email de verificación
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Obtener nombre del usuario (primero de Firestore, luego de Auth)
  Future<String> getUserName() async {
    final user = currentUser;
    if (user == null) return 'Usuario';

    // Primero intentar obtener desde Firestore
    final userData = await getUserData(user.uid);
    if (userData != null && userData['name'] != null) {
      return userData['name'];
    }

    // Si no está en Firestore, usar displayName
    return user.displayName ?? 'Usuario';
  }

  // Convertir errores de Firebase a mensajes legibles
  String _getAuthErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No se encontró un usuario con ese correo electrónico.';
        case 'wrong-password':
          return 'Contraseña incorrecta.';
        case 'email-already-in-use':
          return 'Ya existe una cuenta con ese correo electrónico.';
        case 'weak-password':
          return 'La contraseña es muy débil.';
        case 'invalid-email':
          return 'El correo electrónico no es válido.';
        case 'too-many-requests':
          return 'Demasiados intentos. Intenta más tarde.';
        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada.';
        default:
          return 'Error de autenticación: ${error.message}';
      }
    }
    return error.toString();
  }
}