import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';

class AuthUtils {
  static Future<void> showLogoutDialog(
    BuildContext context, {
    bool closeDrawer = false,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Cerrar diálogo

                // Cerrar el drawer si se especificó
                if (closeDrawer && context.mounted) {
                  Navigator.of(context).pop();
                }

                try {
                  await AuthService().signOut();
                  // El AuthWrapper manejará la navegación automáticamente
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al cerrar sesión: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Cerrar sesión',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
