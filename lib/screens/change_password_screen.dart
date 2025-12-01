import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/theme_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorDialog(
        'Las contraseñas no coinciden',
        'La nueva contraseña y la confirmación deben ser iguales.',
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showErrorDialog(
        'Contraseña muy corta',
        'La nueva contraseña debe tener al menos 6 caracteres.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user?.email == null) {
        throw Exception('Usuario no válido');
      }

      // Reautenticar usuario
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: _currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);

      // Cambiar contraseña
      await user.updatePassword(_newPasswordController.text);

      _showSuccessDialog(
        'Contraseña actualizada',
        'Tu contraseña ha sido cambiada exitosamente.',
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'La contraseña actual es incorrecta.';
          break;
        case 'weak-password':
          errorMessage = 'La nueva contraseña es muy débil.';
          break;
        case 'too-many-requests':
          errorMessage = 'Demasiados intentos. Intenta más tarde.';
          break;
        case 'requires-recent-login':
          errorMessage =
              'Necesitas iniciar sesión nuevamente para cambiar tu contraseña.';
          break;
        default:
          errorMessage = 'Error al cambiar la contraseña: ${e.message}';
      }
      _showErrorDialog('Error', errorMessage);
    } catch (e) {
      _showErrorDialog(
        'Error',
        'No se pudo cambiar la contraseña: ${e.toString()}',
      );
    }

    setState(() => _isLoading = false);
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Volver a settings
            },
            child: const Text('Perfecto'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información de seguridad
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: themeProvider.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Seguridad',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Para cambiar tu contraseña, necesitas ingresar tu contraseña actual por seguridad.',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Formulario de cambio de contraseña
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Campo contraseña actual
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña actual',
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: themeProvider.primaryColor,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: isDark
                                ? Colors.white70
                                : Colors.grey.shade600,
                          ),
                          floatingLabelStyle: TextStyle(
                            color: themeProvider.primaryColor,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: themeProvider.primaryColor,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: themeProvider.primaryColor,
                            ),
                            onPressed: () => setState(
                              () => _obscureCurrentPassword =
                                  !_obscureCurrentPassword,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La contraseña actual es requerida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo nueva contraseña
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        decoration: InputDecoration(
                          labelText: 'Nueva contraseña',
                          helperText: 'Mínimo 6 caracteres',
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: themeProvider.primaryColor,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: isDark
                                ? Colors.white70
                                : Colors.grey.shade600,
                          ),
                          floatingLabelStyle: TextStyle(
                            color: themeProvider.primaryColor,
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: themeProvider.primaryColor,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: themeProvider.primaryColor,
                            ),
                            onPressed: () => setState(
                              () => _obscureNewPassword = !_obscureNewPassword,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La nueva contraseña es requerida';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo confirmar nueva contraseña
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmar nueva contraseña',
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: themeProvider.primaryColor,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: isDark
                                ? Colors.white70
                                : Colors.grey.shade600,
                          ),
                          floatingLabelStyle: TextStyle(
                            color: themeProvider.primaryColor,
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: themeProvider.primaryColor,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: themeProvider.primaryColor,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirma tu nueva contraseña';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botón cambiar contraseña
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.security),
                  label: Text(
                    _isLoading
                        ? 'Cambiando contraseña...'
                        : 'Cambiar contraseña',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Consejos de seguridad
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.tips_and_updates,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Consejos de seguridad',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildSecurityTip('• Usa al menos 8 caracteres'),
                      _buildSecurityTip('• Combina letras, números y símbolos'),
                      _buildSecurityTip('• No uses información personal'),
                      _buildSecurityTip(
                        '• No reutilices contraseñas de otras cuentas',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityTip(String tip) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        tip,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
    );
  }
}
