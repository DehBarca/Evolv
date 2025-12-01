import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/app_theme.dart';
import '../providers/theme_provider.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Tema de Color',
              style: AppTextStyles.heading2.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.white,
              ),
            ),
            backgroundColor: themeProvider.primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
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
                            'Elige tu tema favorito',
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          Text(
                            'Personaliza la apariencia de Evolv con los colores que más te inspiren.',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : AppColors.obscureText.withValues(
                                      alpha: 0.7,
                                    ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingLarge),

                          // Grid de temas
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isTablet ? 3 : 2,
                                  crossAxisSpacing: AppSizes.paddingMedium,
                                  mainAxisSpacing: AppSizes.paddingMedium,
                                  childAspectRatio: 1.2,
                                ),
                            itemCount: AppThemeData.allThemes.length,
                            itemBuilder: (context, index) {
                              final theme = AppThemeData.allThemes[index];
                              final isSelected =
                                  themeProvider.currentThemeType == theme.type;

                              return _buildThemeCard(
                                context,
                                theme: theme,
                                isSelected: isSelected,
                                onTap: () {
                                  themeProvider.setTheme(theme.type);
                                  _showThemeApplied(context, theme.name);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.paddingLarge),

                    // Información adicional
                    _buildCard(
                      context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(context, 'Información'),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildInfoTile(
                            context,
                            icon: Icons.palette,
                            title: 'Tema personalizado',
                            subtitle: 'Tu selección se guarda automáticamente',
                            themeProvider: themeProvider,
                          ),
                          _buildDivider(context),
                          _buildInfoTile(
                            context,
                            icon: Icons.sync,
                            title: 'Sincronización',
                            subtitle: 'Los cambios se aplican inmediatamente',
                            themeProvider: themeProvider,
                          ),
                          _buildDivider(context),
                          _buildInfoTile(
                            context,
                            icon: Icons.devices,
                            title: 'Compatible',
                            subtitle: 'Funciona en modo claro y oscuro',
                            themeProvider: themeProvider,
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
      },
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
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context, {
    required AppThemeData theme,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
          border: Border.all(
            color: isSelected
                ? theme.primary
                : (isDark ? Colors.grey.shade700 : AppColors.borderColor),
            width: isSelected ? 3.0 : 1.5,
          ),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          boxShadow: isDark ? [] : AppShadows.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Preview de colores
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildColorCircle(theme.primary, 24),
                const SizedBox(width: 8),
                _buildColorCircle(theme.secondary, 20),
                const SizedBox(width: 8),
                _buildColorCircle(theme.primaryVariant, 16),
              ],
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Nombre del tema
            Text(
              theme.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSizes.paddingSmall),

            // Descripción
            Text(
              theme.description,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? Colors.white70
                    : AppColors.obscureText.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (isSelected) ...[
              const SizedBox(height: AppSizes.paddingSmall),
              Icon(Icons.check_circle, color: theme.primary, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeProvider themeProvider,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: EdgeInsets.zero,
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
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: isDark
              ? Colors.white70
              : AppColors.obscureText.withValues(alpha: 0.6),
        ),
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

  void _showThemeApplied(BuildContext context, String themeName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tema "$themeName" aplicado correctamente'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
      ),
    );
  }
}
