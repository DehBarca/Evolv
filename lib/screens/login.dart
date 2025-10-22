import 'package:a/screens/tabs.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'register.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const LoginScreen());
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  void _login() {
    _showAlert(
      'Función en desarrollo',
      'El inicio de sesión está en proceso de implementación. Esta función permitirá autenticarte con tu correo electrónico y contraseña. POR AHORA LO MANDA A HOME',
    );
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => TabsScreen()));
  }

  void _forgotPassword() {
    _showAlert(
      'Recuperación de contraseña',
      'La función de recuperación de contraseña está en desarrollo. Permitirá restablecer tu contraseña mediante un correo de verificación.',
    );
  }

  void _navigateToRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border.all(
                color: isDark ? AppColors.darkSurface : AppColors.borderColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo o título
                Icon(Icons.account_circle, size: 80, color: AppColors.primary),
                const SizedBox(height: 20),
                Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 30),

                // Campo de email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 20),

                // Botón de inicio de sesión
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.action,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón para ir a registro
                TextButton(
                  onPressed: _navigateToRegister,
                  child: Text(
                    '¿No tienes cuenta? Regístrate',
                    style: TextStyle(
                      color: isDark ? AppColors.acentoSuave : AppColors.primary,
                    ),
                  ),
                ),

                // Botón de "Olvidé mi contraseña"
                TextButton(
                  onPressed: _forgotPassword,
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : AppColors.textPrimary.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
