import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
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
  bool _soundEnabled = true;

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
}
