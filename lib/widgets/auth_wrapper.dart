import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/login.dart';
import '../screens/tabs.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Si está cargando, mostrar un indicador de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si hay un usuario autenticado, ir a TabsScreen (Home)
        if (snapshot.hasData && snapshot.data != null) {
          return const TabsScreen();
        }

        // Si no hay usuario autenticado, mostrar Login
        return const LoginScreen();
      },
    );
  }
}
