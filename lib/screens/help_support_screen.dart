import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../constants/app_constants.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ayuda y Soporte',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          isTablet ? AppSizes.paddingLarge : AppSizes.paddingMedium,
        ),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 800 : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contacto rápido
                _buildCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(context, 'Contacto Rápido'),
                      _buildContactTile(
                        context,
                        icon: Icons.email,
                        title: 'Correo Electrónico',
                        subtitle: 'soporte@evolv.app',
                        onTap: () =>
                            _showComingSoon(context, 'Envío de correos'),
                      ),

                      _buildDivider(context),
                      _buildContactTile(
                        context,
                        icon: Icons.phone,
                        title: 'Teléfono',
                        subtitle: '+1 (555) 123-4567',
                        onTap: () =>
                            _showComingSoon(context, 'Llamadas telefónicas'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.paddingLarge),

                // Preguntas Frecuentes
                _buildCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(context, 'Preguntas Frecuentes'),

                      _buildFAQItem(
                        context,
                        question: '¿Cómo puedo crear un nuevo hábito?',
                        answer:
                            'Ve a la pantalla principal y toca el botón "+" en la esquina inferior derecha. Completa la información del hábito, incluyendo nombre, categoría y frecuencia deseada.',
                      ),

                      _buildFAQItem(
                        context,
                        question: '¿Puedo editar un hábito después de crearlo?',
                        answer:
                            'Sí, puedes editar cualquier hábito tocando en él desde la pantalla principal y seleccionando "Editar". Puedes cambiar el nombre, categoría, meta y otros detalles.',
                      ),

                      _buildFAQItem(
                        context,
                        question: '¿Cómo funcionan las notificaciones?',
                        answer:
                            'Las notificaciones se envían según la frecuencia que configures en Ajustes. Puedes personalizarlas en la sección "Notificaciones" del menú de configuración.',
                      ),

                      _buildFAQItem(
                        context,
                        question: '¿Se sincronizan mis datos en la nube?',
                        answer:
                            'Sí, todos tus datos se respaldan automáticamente en Firebase cuando tienes una cuenta activa. Esto permite acceder a tus hábitos desde múltiples dispositivos.',
                      ),

                      _buildFAQItem(
                        context,
                        question: '¿Puedo exportar mis datos?',
                        answer:
                            'La función de exportación de datos estará disponible próximamente. Te permitirá descargar un archivo con todo tu progreso y estadísticas.',
                      ),

                      _buildFAQItem(
                        context,
                        question: '¿Cómo elimino mi cuenta?',
                        answer:
                            'Puedes eliminar tu cuenta desde Ajustes > Datos y privacidad > Eliminar todos los datos. Esta acción es irreversible y eliminará permanentemente toda tu información.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.paddingLarge),

                // Información de la App
                _buildCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        context,
                        'Información de la Aplicación',
                      ),
                      _buildInfoRow(context, 'Versión', '1.0.0'),
                      _buildInfoRow(
                        context,
                        'Última actualización',
                        '25/11/2025',
                      ),
                      _buildInfoRow(context, 'Tamaño', '45.2 MB'),
                      _buildInfoRow(context, 'Desarrollador', 'Evolv Team'),
                      const SizedBox(height: AppSizes.paddingMedium),

                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Si tienes alguna pregunta que no esté aquí,',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.obscureText.withValues(
                                        alpha: 0.7,
                                      ),
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingSmall),
                            Text(
                              'no dudes en contactarnos.',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.obscureText.withValues(
                                        alpha: 0.7,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.paddingXLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
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
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: child,
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Icon(
            icon,
            color: themeProvider.primaryColor,
            size: AppSizes.iconSizeSmall,
          );
        },
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: isDark
              ? Colors.white70
              : AppColors.obscureText.withValues(alpha: 0.6),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark
            ? Colors.white60
            : AppColors.obscureText.withValues(alpha: 0.4),
      ),
      onTap: onTap,
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : AppColors.textPrimary,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.paddingMedium,
            right: AppSizes.paddingMedium,
            bottom: AppSizes.paddingMedium,
          ),
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.87)
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.white70
                  : AppColors.obscureText.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? Colors.grey.shade800 : AppColors.borderColor,
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Próximamente'),
          content: Text(
            'La función "$feature" estará disponible en futuras actualizaciones.',
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
