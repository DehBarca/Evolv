import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../constants/app_constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Política de Privacidad',
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
                _buildCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(context, 'Información General'),
                      _buildText(
                        context,
                        'Esta Política de Privacidad describe cómo Evolv recopila, utiliza y protege la información personal que nos proporciona cuando utiliza nuestra aplicación de seguimiento de hábitos.',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(
                        context,
                        'Información que Recopilamos',
                      ),
                      _buildBulletPoint(
                        context,
                        'Información de cuenta: nombre, email y contraseña encriptada',
                      ),
                      _buildBulletPoint(
                        context,
                        'Datos de hábitos: sus hábitos personalizados y progreso',
                      ),
                      _buildBulletPoint(
                        context,
                        'Información de uso: estadísticas de la aplicación para mejorar el servicio',
                      ),
                      _buildBulletPoint(
                        context,
                        'Datos de dispositivo: tipo de dispositivo y versión del sistema operativo',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(
                        context,
                        'Cómo Utilizamos su Información',
                      ),
                      _buildBulletPoint(
                        context,
                        'Proporcionar y mejorar nuestros servicios',
                      ),
                      _buildBulletPoint(
                        context,
                        'Personalizar su experiencia de usuario',
                      ),
                      _buildBulletPoint(
                        context,
                        'Enviar notificaciones importantes sobre el servicio',
                      ),
                      _buildBulletPoint(
                        context,
                        'Análisis y estadísticas para mejorar la aplicación',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(context, 'Protección de Datos'),
                      _buildText(
                        context,
                        'Implementamos medidas de seguridad técnicas y organizativas apropiadas para proteger su información personal contra acceso no autorizado, alteración, divulgación o destrucción.',
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      _buildBulletPoint(
                        context,
                        'Encriptación de datos en tránsito y en reposo',
                      ),
                      _buildBulletPoint(
                        context,
                        'Acceso restringido a información personal',
                      ),
                      _buildBulletPoint(
                        context,
                        'Auditorías regulares de seguridad',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(context, 'Compartir Información'),
                      _buildText(
                        context,
                        'No vendemos, intercambiamos o transferimos su información personal a terceros sin su consentimiento, excepto en los casos descritos en esta política o cuando sea requerido por ley.',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(context, 'Sus Derechos'),
                      _buildBulletPoint(
                        context,
                        'Acceder a su información personal',
                      ),
                      _buildBulletPoint(
                        context,
                        'Rectificar información inexacta',
                      ),
                      _buildBulletPoint(
                        context,
                        'Solicitar eliminación de su cuenta y datos',
                      ),
                      _buildBulletPoint(
                        context,
                        'Retirar consentimiento en cualquier momento',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(
                        context,
                        'Cookies y Tecnologías Similares',
                      ),
                      _buildText(
                        context,
                        'Utilizamos tecnologías locales de almacenamiento para mejorar la funcionalidad de la aplicación y recordar sus preferencias.',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(context, 'Cambios a Esta Política'),
                      _buildText(
                        context,
                        'Nos reservamos el derecho de actualizar esta Política de Privacidad. Le notificaremos sobre cambios significativos a través de la aplicación.',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(context, 'Contacto'),
                      _buildText(
                        context,
                        'Si tiene preguntas sobre esta Política de Privacidad, puede contactarnos a través de la sección "Ayuda y Soporte" en la aplicación.',
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      _buildText(
                        context,
                        'Última actualización: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        isLastUpdate: true,
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

  Widget _buildText(
    BuildContext context,
    String text, {
    bool isLastUpdate = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: isLastUpdate
              ? (isDark
                    ? Colors.white60
                    : AppColors.obscureText.withValues(alpha: 0.7))
              : (isDark
                    ? Colors.white.withValues(alpha: 0.87)
                    : AppColors.textPrimary),
          fontStyle: isLastUpdate ? FontStyle.italic : null,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: AppSizes.paddingSmall),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Provider.of<ThemeProvider>(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.87)
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
