import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../constants/app_constants.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Términos y Condiciones',
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
                      _buildSectionHeader(
                        context,
                        'Aceptación de los Términos',
                      ),
                      _buildText(
                        context,
                        'Al descargar, instalar o utilizar Evolv, usted acepta cumplir con estos Términos y Condiciones. Si no está de acuerdo con algún aspecto de estos términos, no utilice nuestra aplicación.',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(context, 'Descripción del Servicio'),
                      _buildText(
                        context,
                        'Evolv es una aplicación móvil diseñada para ayudar a los usuarios a crear, seguir y mantener hábitos personales. La aplicación proporciona herramientas para el seguimiento de progreso, recordatorios y análisis estadístico.',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(context, 'Cuenta de Usuario'),
                      _buildBulletPoint(
                        context,
                        'Debe proporcionar información precisa y actualizada al crear su cuenta',
                      ),
                      _buildBulletPoint(
                        context,
                        'Es responsable de mantener la confidencialidad de su contraseña',
                      ),
                      _buildBulletPoint(
                        context,
                        'Debe notificarnos inmediatamente sobre cualquier uso no autorizado',
                      ),
                      _buildBulletPoint(
                        context,
                        'Solo puede tener una cuenta activa por persona',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(context, 'Uso Aceptable'),
                      _buildText(
                        context,
                        'Al utilizar Evolv, usted se compromete a:',
                      ),
                      _buildBulletPoint(
                        context,
                        'Utilizar la aplicación solo para fines legales',
                      ),
                      _buildBulletPoint(
                        context,
                        'No intentar hackear, dañar o comprometer la seguridad',
                      ),
                      _buildBulletPoint(
                        context,
                        'No compartir contenido inapropiado o ilegal',
                      ),
                      _buildBulletPoint(
                        context,
                        'Respetar los derechos de otros usuarios',
                      ),
                      _buildBulletPoint(
                        context,
                        'No crear múltiples cuentas sin autorización',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(context, 'Propiedad Intelectual'),
                      _buildText(
                        context,
                        'Todos los derechos, títulos e intereses en Evolv, incluyendo pero no limitado a software, diseños, texto, gráficos e interfaces, son propiedad exclusiva de Evolv o sus licenciantes.',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(context, 'Contenido del Usuario'),
                      _buildBulletPoint(
                        context,
                        'Usted conserva la propiedad de los datos que ingresa en la aplicación',
                      ),
                      _buildBulletPoint(
                        context,
                        'Nos otorga una licencia para procesar sus datos según nuestra Política de Privacidad',
                      ),
                      _buildBulletPoint(
                        context,
                        'Es responsable de la exactitud de la información que proporciona',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(context, 'Limitaciones del Servicio'),
                      _buildText(
                        context,
                        'El servicio se proporciona "tal como está". No garantizamos:',
                      ),
                      _buildBulletPoint(
                        context,
                        'Disponibilidad ininterrumpida del servicio',
                      ),
                      _buildBulletPoint(
                        context,
                        'Que el servicio esté libre de errores',
                      ),
                      _buildBulletPoint(
                        context,
                        'Compatibilidad con todos los dispositivos',
                      ),
                      _buildBulletPoint(
                        context,
                        'Resultados específicos en la formación de hábitos',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(
                        context,
                        'Limitación de Responsabilidad',
                      ),
                      _buildText(
                        context,
                        'En ningún caso seremos responsables por daños indirectos, incidentales, especiales o consecuenciales que resulten del uso o la incapacidad de usar la aplicación.',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(context, 'Terminación'),
                      _buildBulletPoint(
                        context,
                        'Puede terminar su cuenta en cualquier momento desde la configuración',
                      ),
                      _buildBulletPoint(
                        context,
                        'Podemos suspender o terminar su acceso por violación de estos términos',
                      ),
                      _buildBulletPoint(
                        context,
                        'Tras la terminación, algunos datos pueden conservarse según las leyes aplicables',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(context, 'Modificaciones'),
                      _buildText(
                        context,
                        'Nos reservamos el derecho de modificar estos términos en cualquier momento. Las modificaciones entrarán en vigencia cuando se publiquen en la aplicación. El uso continuado constituye aceptación de los nuevos términos.',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(context, 'Ley Aplicable'),
                      _buildText(
                        context,
                        'Estos términos se regirán por las leyes aplicables en su jurisdicción. Cualquier disputa será resuelta en los tribunales competentes.',
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      _buildSectionHeader(context, 'Contacto'),
                      _buildText(
                        context,
                        'Para preguntas sobre estos términos, contactenos a través de la sección "Ayuda y Soporte" en la aplicación.',
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
