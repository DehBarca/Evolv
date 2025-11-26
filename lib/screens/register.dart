import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

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

  Future<void> _register() async {
    // Validaciones
    if (_nameController.text.trim().isEmpty) {
      _showAlert('Nombre requerido', 'Por favor, ingresa tu nombre completo.');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showAlert(
        'Correo requerido',
        'Por favor, ingresa tu correo electrónico.',
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showAlert('Contraseña requerida', 'Por favor, ingresa una contraseña.');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showAlert(
        'Contraseña muy corta',
        'La contraseña debe tener al menos 6 caracteres.',
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showAlert(
        'Contraseñas no coinciden',
        'Las contraseñas ingresadas no coinciden. Por favor, verifica.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      if (mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Cuenta creada exitosamente! Bienvenido ${_nameController.text.trim()}',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navegar al login después de un breve delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showAlert('Error de registro', e.toString());
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithGoogle();
      // Login exitoso - El AuthWrapper se encargará de navegar automáticamente
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showAlert('Error de inicio de sesión con Google', e.toString());
      }
    }
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
                Icon(
                  Icons.person_add,
                  size: 80,
                  color: Provider.of<ThemeProvider>(context).primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  'Crear cuenta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),

                // Campo de nombre
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Provider.of<ThemeProvider>(context).primaryColor,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Provider.of<ThemeProvider>(context).primaryColor,
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Provider.of<ThemeProvider>(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Provider.of<ThemeProvider>(context).primaryColor,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Provider.of<ThemeProvider>(context).primaryColor,
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Provider.of<ThemeProvider>(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Provider.of<ThemeProvider>(context).primaryColor,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Provider.of<ThemeProvider>(context).primaryColor,
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Provider.of<ThemeProvider>(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de confirmar contraseña
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Provider.of<ThemeProvider>(context).primaryColor,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Provider.of<ThemeProvider>(context).primaryColor,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Provider.of<ThemeProvider>(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Botón de registro
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Provider.of<ThemeProvider>(
                        context,
                      ).primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Provider.of<ThemeProvider>(
                        context,
                      ).primaryColor.withValues(alpha: 0.5),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Registrarse',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Divisor con texto "O"
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isDark ? Colors.white30 : Colors.grey.shade300,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'O',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDark ? Colors.white30 : Colors.grey.shade300,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Botón de Google Sign In
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? Colors.white30 : AppColors.borderColor,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Image.network(
                      'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                      height: 24,
                      width: 24,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.g_mobiledata,
                        size: 24,
                        color: Provider.of<ThemeProvider>(context).primaryColor,
                      ),
                    ),
                    label: Text(
                      'Continuar con Google',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón para volver al login
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '¿Ya tienes cuenta? Inicia sesión',
                    style: TextStyle(
                      color: isDark
                          ? Provider.of<ThemeProvider>(
                              context,
                            ).primaryColor.withValues(alpha: 0.8)
                          : Provider.of<ThemeProvider>(context).primaryColor,
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
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
