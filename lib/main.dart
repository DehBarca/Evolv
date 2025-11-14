// main.dart
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/app_constants.dart';
import 'widgets/auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.primaryBackground,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.acentoSuave,
          surface: Colors.white,
          error: AppColors.error,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return Colors.grey;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary.withValues(alpha: 0.5);
            }
            return Colors.grey.withValues(alpha: 0.3);
          }),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.primary,
          thumbColor: AppColors.primary,
          inactiveTrackColor: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.darkBackground2,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.acentoSuave,
          surface: AppColors.darkSurface,
          error: AppColors.error,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return Colors.grey;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary.withValues(alpha: 0.5);
            }
            return Colors.grey.withValues(alpha: 0.3);
          }),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.primary,
          thumbColor: AppColors.primary,
          inactiveTrackColor: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Evolv App',
        theme: theme,
        darkTheme: darkTheme,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
