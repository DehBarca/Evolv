import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../constants/app_constants.dart';
import '../services/user_profile_service.dart';
import '../services/habit_service.dart';
import '../utils/auth_utils.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';
import 'help_support_screen.dart';
import 'theme_selection_screen.dart';
import 'edit_profile.dart';
import 'change_password_screen.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  int _notificationFrequencyHours =
      4; // Frecuencia en horas (por defecto 4 horas)
  final List<int> _frequencyOptions = [
    1,
    2,
    3,
    4,
    6,
    8,
    12,
    24,
  ]; // Opciones de frecuencia
  final UserProfileService _profileService = UserProfileService();
  final HabitService _habitService = HabitService();
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await _profileService.getCurrentUserProfile();
      if (mounted) setState(() => _profile = p);
    } catch (e) {
      // ignore
    }
  }

  // Helper para convertir objetos Firestore a formato JSON-compatible
  Map<String, dynamic> _convertToJsonSafe(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    for (final entry in data.entries) {
      if (entry.value is Timestamp) {
        result[entry.key] = (entry.value as Timestamp)
            .toDate()
            .toIso8601String();
      } else if (entry.value is DateTime) {
        result[entry.key] = (entry.value as DateTime).toIso8601String();
      } else if (entry.value is FieldValue) {
        // FieldValue no se puede serializar, usar timestamp actual
        result[entry.key] = DateTime.now().toIso8601String();
      } else if (entry.value is Map<String, dynamic>) {
        result[entry.key] = _convertToJsonSafe(
          entry.value as Map<String, dynamic>,
        );
      } else if (entry.value is List) {
        result[entry.key] = (entry.value as List).map((item) {
          if (item is Map<String, dynamic>) {
            return _convertToJsonSafe(item);
          }
          return item;
        }).toList();
      } else if (entry.value == null) {
        result[entry.key] = null;
      } else {
        // Para cualquier otro tipo de objeto, intentar convertir a string
        try {
          result[entry.key] = entry.value;
        } catch (e) {
          // Si falla la serialización, usar una representación como string
          result[entry.key] = entry.value.toString();
        }
      }
    }
    return result;
  }

  Future<Map<String, dynamic>> _saveBackupToFile(
    String jsonData,
    String? userEmail,
  ) async {
    try {
      // Crear nombre de archivo con fecha y hora
      final now = DateTime.now();
      final timestamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final userPrefix = userEmail?.split('@').first ?? 'usuario';
      final fileName = 'evolv_backup_${userPrefix}_$timestamp.json';

      if (kIsWeb) {
        // Para web: usar descarga HTML
        final bytes = utf8.encode(jsonData);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = fileName;
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        return {'success': true, 'path': 'Descargas/$fileName'};
      } else {
        // Para móviles: usar sistema de archivos
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(jsonData);

        return {'success': true, 'path': file.path};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> _createBackup() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showAlert('Error', 'No hay usuario autenticado');
        return;
      }

      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Creando copia de seguridad...'),
            ],
          ),
        ),
      );

      // Obtener datos del usuario
      final profile = await _profileService.getCurrentUserProfile();
      await _habitService.initializeHabits();
      final habits = _habitService.habits;

      // Crear estructura de backup con conversión segura a JSON
      final profileData = profile?.toMap();
      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'user': {
          'uid': user.uid,
          'email': user.email,
          'profile': profileData != null
              ? _convertToJsonSafe(profileData)
              : null,
        },
        'habits': habits.map((h) => _convertToJsonSafe(h)).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      // Guardar automáticamente en archivo
      final result = await _saveBackupToFile(jsonString, user.email);

      if (mounted) {
        Navigator.pop(context); // Cerrar dialogo de carga

        if (result['success']) {
          _showAlert(
            'Copia de seguridad creada',
            'Los datos se han guardado exitosamente.\n\nUbicación: ${result['path']}\nTamaño: ${jsonString.length} caracteres',
          );
        } else {
          // Fallback al clipboard si falla el archivo
          await Clipboard.setData(ClipboardData(text: jsonString));
          _showAlert(
            'Copia de seguridad creada',
            'No se pudo guardar el archivo (${result['error']}), pero los datos se copiaron al portapapeles.\n\nTamaño: ${jsonString.length} caracteres',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar dialogo de carga
        _showAlert('Error', 'No se pudo crear la copia de seguridad: $e');
      }
    }
  }

  Future<String?> _selectFileForRestore() async {
    if (kIsWeb) {
      // Para web: usar file input HTML
      final input = html.FileUploadInputElement()
        ..accept = '.json'
        ..click();

      await input.onChange.first;

      if (input.files!.isEmpty) return null;

      final file = input.files!.first;
      final reader = html.FileReader();
      reader.readAsText(file);
      await reader.onLoad.first;

      return reader.result as String?;
    } else {
      // Para móviles: usar file_picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      if (file.path == null) return null;

      try {
        final fileContent = await File(file.path!).readAsString();
        return fileContent;
      } catch (e) {
        if (mounted) {
          _showAlert('Error', 'No se pudo leer el archivo: $e');
        }
        return null;
      }
    }
  }

  Future<void> _restoreData() async {
    // Mostrar opciones de restauración
    final option = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar datos'),
        content: const Text('¿Cómo quieres restaurar tus datos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'file'),
            child: const Text('Subir archivo'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'text'),
            child: const Text('Pegar texto'),
          ),
        ],
      ),
    );

    if (option == null) return;

    String? result;

    if (option == 'file') {
      result = await _selectFileForRestore();
      if (result == null) {
        // Si falla la selección de archivo, volver al menú principal
        return;
      }
    } else {
      // Opción de pegar texto
      final textController = TextEditingController();
      if (!mounted) return;
      result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pegar datos de respaldo'),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: textController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'Pega aquí los datos de tu copia de seguridad...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, textController.text),
              child: const Text('Restaurar'),
            ),
          ],
        ),
      );
    }

    if (result == null || result.isEmpty) return;

    try {
      // Mostrar indicador de carga
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Restaurando datos...'),
            ],
          ),
        ),
      );

      final backupData = jsonDecode(result);

      // Validar estructura básica
      if (backupData['user'] == null || backupData['habits'] == null) {
        throw Exception('Formato de respaldo inválido');
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      // Restaurar perfil si existe
      if (backupData['user']['profile'] != null) {
        // Aquí podrías restaurar el perfil si es necesario
        debugPrint('Profile data found in backup');
      }

      // Restaurar hábitos
      final habitsData = backupData['habits'] as List;
      debugPrint('Found ${habitsData.length} habits to restore');

      // Restaurar hábitos usando HabitService
      if (!mounted) return;
      final habitService = Provider.of<HabitService>(context, listen: false);
      final restoredCount = await habitService.restoreHabitsFromBackup(
        habitsData,
      );

      if (mounted) {
        Navigator.pop(context); // Cerrar dialogo de carga
        if (restoredCount > 0) {
          _showAlert(
            'Datos restaurados',
            'Se han restaurado $restoredCount hábitos exitosamente. Los cambios se verán reflejados inmediatamente.',
          );
        } else {
          _showAlert(
            'Restauración completada',
            'No se encontraron nuevos hábitos para restaurar o ya existían.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar dialogo de carga
        _showAlert('Error', 'No se pudieron restaurar los datos: $e');
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar tu cuenta?\n\nEsta acción eliminará:\n• Tu perfil y datos personales\n• Todos tus hábitos y progreso\n• Toda la información asociada\n\nEsta acción NO se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar cuenta'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Segunda confirmación
    if (!mounted) return;
    final doubleConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación final'),
        content: const Text(
          'Esta es tu última oportunidad para cancelar.\n\n¿Realmente quieres eliminar tu cuenta de forma permanente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );

    if (doubleConfirmed != true) return;

    try {
      // Mostrar indicador de carga
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Eliminando cuenta...'),
            ],
          ),
        ),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      // Eliminar datos de Firestore
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      // Eliminar subcolecciones (hábitos)
      final habitsCollection = userDoc.collection('habits');
      final habitsSnapshot = await habitsCollection.get();
      for (final doc in habitsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Eliminar documento de usuario
      await userDoc.delete();

      // Eliminar cuenta de Authentication
      await user.delete();

      if (mounted) {
        Navigator.pop(context); // Cerrar dialogo de carga

        // Navegar a pantalla de login o salir de la app
        _showAlert(
          'Cuenta eliminada',
          'Tu cuenta ha sido eliminada permanentemente.',
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar dialogo de carga
        _showAlert('Error', 'No se pudo eliminar la cuenta: $e');
      }
    }
  }

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

  void _showComingSoon(String feature) {
    _showAlert(
      'Próximamente',
      'La función "$feature" estará disponible en futuras actualizaciones.',
    );
  }

  Future<void> _showLogoutDialog() async {
    return AuthUtils.showLogoutDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: themeProvider.primaryColor,
            title: Text(
              'Ajustes',
              style: AppTextStyles.heading2.copyWith(color: Colors.white),
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección: Perfil
                _buildSectionTitle('Perfil'),
                _buildCard(
                  child: Column(
                    children: [
                      _buildListTile(
                        icon: Icons.person,
                        title: 'Editar perfil',
                        subtitle: 'Actualiza tu información personal',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        ),
                      ),
                      _buildDivider(),
                      _buildListTile(
                        icon: Icons.lock,
                        title: 'Cambiar contraseña',
                        subtitle: 'Actualiza tu contraseña de acceso',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        ),
                      ),
                      if (_profile?.dateOfBirth != null) _buildDivider(),
                      if (_profile?.dateOfBirth != null)
                        _buildListTile(
                          icon: Icons.cake,
                          title: 'Fecha de nacimiento',
                          subtitle:
                              '${_profile!.dateOfBirth!.day.toString().padLeft(2, '0')}/${_profile!.dateOfBirth!.month.toString().padLeft(2, '0')}/${_profile!.dateOfBirth!.year}',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          ).then((_) => _loadProfile()),
                          showArrow: false,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.paddingLarge),

                // Sección: Personalización
                _buildSectionTitle('Personalización'),
                _buildCard(
                  child: Column(
                    children: [
                      _buildListTile(
                        icon: Icons.category,
                        title: 'Gestionar categorías',
                        subtitle: 'Crea y edita tus categorías personalizadas',
                        onTap: () {
                          Navigator.of(context).pushNamed('/manage-categories');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.paddingLarge),

                // Sección: Notificaciones
                _buildSectionTitle('Notificaciones'),
                _buildCard(
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.notifications,
                        title: 'Notificaciones de hábitos',
                        subtitle: 'Recibe recordatorios de tareas pendientes',
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                          _showComingSoon('Notificaciones de hábitos');
                        },
                      ),
                      if (_notificationsEnabled) ...[
                        _buildDivider(),
                        _buildFrequencySelector(),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.paddingLarge),

                // Sección: Apariencia
                _buildSectionTitle('Apariencia'),
                _buildCard(
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.dark_mode,
                        title: 'Modo oscuro',
                        subtitle: 'Cambia el tema de la aplicación',
                        value: AdaptiveTheme.of(context).mode.isDark,
                        onChanged: (value) {
                          if (value) {
                            AdaptiveTheme.of(context).setDark();
                          } else {
                            AdaptiveTheme.of(context).setLight();
                          }
                        },
                      ),
                      _buildDivider(),
                      _buildListTile(
                        icon: Icons.palette,
                        title: 'Tema de color',
                        subtitle: 'Personaliza los colores',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ThemeSelectionScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.paddingLarge),

                // Sección: Datos
                _buildSectionTitle('Datos y privacidad'),
                _buildCard(
                  child: Column(
                    children: [
                      _buildListTile(
                        icon: Icons.backup,
                        title: 'Copia de seguridad',
                        subtitle: 'Respalda tu progreso en la nube',
                        onTap: _createBackup,
                      ),
                      _buildDivider(),
                      _buildListTile(
                        icon: Icons.restore,
                        title: 'Restaurar datos',
                        subtitle: 'Recupera tu información guardada',
                        onTap: _restoreData,
                      ),
                      _buildDivider(),
                      _buildListTile(
                        icon: Icons.delete_forever,
                        title: 'Eliminar cuenta',
                        subtitle: 'Borra la cuenta local y remotamente',
                        textColor: AppColors.error,
                        onTap: _deleteAccount,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.paddingLarge),

                // Sección: Acerca de
                _buildSectionTitle('Acerca de'),
                _buildCard(
                  child: Column(
                    children: [
                      _buildListTile(
                        icon: Icons.info,
                        title: 'Versión',
                        subtitle: '1.0.0',
                        onTap: () {},
                        showArrow: false,
                      ),
                      _buildDivider(),
                      _buildListTile(
                        icon: Icons.privacy_tip,
                        title: 'Política de privacidad',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildListTile(
                        icon: Icons.description,
                        title: 'Términos y condiciones',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TermsConditionsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildListTile(
                        icon: Icons.help,
                        title: 'Ayuda y soporte',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const HelpSupportScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.paddingLarge),

                // Botón de cerrar sesión
                _buildCard(
                  child: _buildListTile(
                    icon: Icons.logout,
                    title: 'Cerrar sesión',
                    textColor: AppColors.error,
                    onTap: _showLogoutDialog,
                  ),
                ),

                const SizedBox(height: AppSizes.paddingXLarge),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrequencySelector() {
    return ListTile(
      leading: Icon(
        Icons.schedule,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white70
            : AppColors.textSecondary,
      ),
      title: Text(
        'Frecuencia de recordatorios',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        'Cada $_notificationFrequencyHours hora${_notificationFrequencyHours == 1 ? '' : 's'}',
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white70
              : AppColors.textSecondary,
        ),
      ),
      trailing: DropdownButton<int>(
        value: _notificationFrequencyHours,
        underline: const SizedBox.shrink(),
        items: _frequencyOptions.map((int hours) {
          return DropdownMenuItem<int>(
            value: hours,
            child: Text(
              '$hours h',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.textPrimary,
              ),
            ),
          );
        }).toList(),
        onChanged: (int? newValue) {
          if (newValue != null) {
            setState(() {
              _notificationFrequencyHours = newValue;
            });
            _showNotificationFrequencyDialog(newValue);
          }
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.paddingSmall,
        bottom: AppSizes.paddingSmall,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white70
              : AppColors.obscureText.withValues(alpha: 0.7),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border.all(
          color: isDark ? AppColors.darkSurface : AppColors.borderColor,
          width: AppSizes.borderWidth,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: isDark ? [] : AppShadows.cardShadow,
      ),
      child: child,
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          leading: Icon(
            icon,
            color: textColor ?? themeProvider.primaryColor,
            size: AppSizes.iconSizeSmall,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color:
                  textColor ?? (isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white70
                        : AppColors.obscureText.withValues(alpha: 0.6),
                  ),
                )
              : null,
          trailing: showArrow
              ? Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark
                      ? Colors.white60
                      : AppColors.obscureText.withValues(alpha: 0.4),
                )
              : null,
          onTap: onTap,
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          leading: Icon(
            icon,
            color: themeProvider.primaryColor,
            size: AppSizes.iconSizeSmall,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white70
                        : AppColors.obscureText.withValues(alpha: 0.6),
                  ),
                )
              : null,
          trailing: Switch(value: value, onChanged: onChanged),
        );
      },
    );
  }

  Widget _buildDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? Colors.grey.shade800 : AppColors.borderColor,
      indent: AppSizes.paddingMedium,
      endIndent: AppSizes.paddingMedium,
    );
  }

  void _showNotificationFrequencyDialog(int hours) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recordatorios Configurados'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recibirás notificaciones cada $hours hora${hours == 1 ? '' : 's'} con un resumen de:',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.task_alt, color: AppColors.success, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text('Hábitos completados hoy')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.pending_actions,
                    color: AppColors.progressLow,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(child: Text('Tareas pendientes por completar')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.trending_up, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text('Tu progreso general del día')),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Las notificaciones se activarán automáticamente en la próxima actualización.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
}
