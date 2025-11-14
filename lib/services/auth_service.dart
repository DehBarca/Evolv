import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Configurar Google Sign-In con clientId para web
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '572329223623-6e1fmgtec3kv5spphesp85mgrsvi7lsd.apps.googleusercontent.com'
        : null,
  );

  // Stream para escuchar cambios en el estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obtener el usuario actual
  User? get currentUser => _auth.currentUser;

  // Registro con email y contraseña
  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Actualizar el nombre del usuario
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Inicio de sesión con email y contraseña
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
      // Intentar cerrar sesión solo de Firebase si Google falla
      await _auth.signOut();
    }
  }

  // Inicio de sesión con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Iniciar el flujo de autenticación de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        throw 'Inicio de sesión cancelado';
      }

      // Obtener los detalles de autenticación
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Crear una credencial de Firebase con el token de Google
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión en Firebase con la credencial de Google
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error al iniciar sesión con Google: ${e.toString()}';
    }
  }

  // Recuperar contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Manejo de errores de Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
      case 'email-already-in-use':
        return 'Este correo electrónico ya está registrado.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-credential':
        return 'Las credenciales no son válidas. Verifica tu correo y contraseña.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta de nuevo más tarde.';
      case 'operation-not-allowed':
        return 'Operación no permitida. Contacta al administrador.';
      default:
        return 'Error de autenticación: ${e.message ?? "Error desconocido"}';
    }
  }
}
