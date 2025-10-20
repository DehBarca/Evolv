import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evolv - Ajustes',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: const SettingsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _soundEnabled = true;
  double _reminderFrequency = 2.0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('Ajustes', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
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
                    onTap: () => _showComingSoon('Editar perfil'),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.email,
                    title: 'Cambiar correo',
                    subtitle: 'usuario@ejemplo.com',
                    onTap: () => _showComingSoon('Cambiar correo'),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.lock,
                    title: 'Cambiar contraseña',
                    subtitle: 'Actualiza tu contraseña de acceso',
                    onTap: () => _showComingSoon('Cambiar contraseña'),
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
                    title: 'Notificaciones push',
                    subtitle: 'Recibe recordatorios de tus hábitos',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _showComingSoon('Notificaciones push');
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.volume_up,
                    title: 'Sonido',
                    subtitle: 'Reproduce sonidos en notificaciones',
                    value: _soundEnabled,
                    onChanged: (value) {
                      setState(() {
                        _soundEnabled = value;
                      });
                      _showComingSoon('Sonido de notificaciones');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.paddingLarge),

            // Sección: Recordatorios
            _buildSectionTitle('Recordatorios'),
            _buildCard(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.alarm,
                              color: AppColors.primary,
                              size: AppSizes.iconSizeSmall,
                            ),
                            const SizedBox(width: AppSizes.paddingMedium),
                            const Text(
                              'Frecuencia de recordatorios',
                              style: AppTextStyles.bodyText,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Text(
                          '${_reminderFrequency.toInt()} veces al día',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.obscureText.withValues(alpha: 0.6),
                          ),
                        ),
                        Slider(
                          value: _reminderFrequency,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          activeColor: AppColors.primary,
                          label: '${_reminderFrequency.toInt()}',
                          onChanged: (value) {
                            setState(() {
                              _reminderFrequency = value;
                            });
                          },
                          onChangeEnd: (value) {
                            _showComingSoon('Frecuencia de recordatorios');
                          },
                        ),
                      ],
                    ),
                  ),
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
                    value: _darkModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        _darkModeEnabled = value;
                      });
                      _showComingSoon('Modo oscuro');
                    },
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.palette,
                    title: 'Tema de color',
                    subtitle: 'Personaliza los colores',
                    onTap: () => _showComingSoon('Tema de color'),
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
                    onTap: () => _showComingSoon('Copia de seguridad'),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.restore,
                    title: 'Restaurar datos',
                    subtitle: 'Recupera tu información guardada',
                    onTap: () => _showComingSoon('Restaurar datos'),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.delete_forever,
                    title: 'Eliminar todos los datos',
                    subtitle: 'Esta acción no se puede deshacer',
                    textColor: AppColors.error,
                    onTap: () => _showAlert(
                      'Eliminar datos',
                      'Esta función eliminará permanentemente todos tus datos. Estará disponible próximamente con confirmación adicional.',
                    ),
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
                    onTap: () => _showComingSoon('Política de privacidad'),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.description,
                    title: 'Términos y condiciones',
                    onTap: () => _showComingSoon('Términos y condiciones'),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.help,
                    title: 'Ayuda y soporte',
                    onTap: () => _showComingSoon('Ayuda y soporte'),
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
                onTap: () => _showAlert(
                  'Cerrar sesión',
                  'La función de cerrar sesión estará disponible cuando se implemente el sistema de autenticación.',
                ),
              ),
            ),

            const SizedBox(height: AppSizes.paddingXLarge),
          ],
        ),
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
          color: AppColors.obscureText.withValues(alpha: 0.7),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.borderColor,
          width: AppSizes.borderWidth,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: AppShadows.cardShadow,
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
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? AppColors.primary,
        size: AppSizes.iconSizeSmall,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.obscureText.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: showArrow
          ? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.obscureText.withValues(alpha: 0.4),
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
        size: AppSizes.iconSizeSmall,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.obscureText.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.borderColor,
      indent: AppSizes.paddingMedium,
      endIndent: AppSizes.paddingMedium,
    );
  }
}
