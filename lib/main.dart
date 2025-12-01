import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'widgets/auth_wrapper.dart';
import 'screens/manage_categories.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'services/habit_service.dart';
import 'services/user_profile_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Asegurar persistencia de autenticación
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HabitService()),
        Provider(create: (_) => UserProfileService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return AdaptiveTheme(
            light: _buildLightTheme(themeProvider),
            dark: _buildDarkTheme(themeProvider),
            initial: savedThemeMode ?? AdaptiveThemeMode.light,
            builder: (theme, darkTheme) => MaterialApp(
              title: 'Evolv App',
              theme: theme,
              darkTheme: darkTheme,
              home: const AuthWrapper(),
              debugShowCheckedModeBanner: false,
              routes: {
                '/manage-categories': (context) =>
                    const ManageCategoriesScreen(),
              },
            ),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme(ThemeProvider themeProvider) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: themeProvider.primaryColor,
      scaffoldBackgroundColor: themeProvider.backgroundColor,
      colorScheme: ColorScheme.light(
        primary: themeProvider.primaryColor,
        secondary: themeProvider.secondaryColor,
        surface: Colors.white,
        error: AppColors.error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: themeProvider.primaryColor,
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
            return themeProvider.primaryColor;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return themeProvider.primaryColor.withValues(alpha: 0.5);
          }
          return Colors.grey.withValues(alpha: 0.3);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: themeProvider.primaryColor,
        thumbColor: themeProvider.primaryColor,
        inactiveTrackColor: themeProvider.primaryColor.withValues(alpha: 0.3),
      ),
      // Tema para NavigationBar (bottom navigation)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: themeProvider.primaryColor.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: themeProvider.primaryColor);
          }
          return const IconThemeData(color: Colors.grey);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: themeProvider.primaryColor, fontSize: 12);
          }
          return const TextStyle(color: Colors.grey, fontSize: 12);
        }),
      ),
      // Tema para BottomNavigationBar (alternativo)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: themeProvider.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedIconTheme: IconThemeData(color: themeProvider.primaryColor),
        unselectedIconTheme: const IconThemeData(color: Colors.grey),
      ),
      // Tema para FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: Colors.white,
      ),
      // Tema para botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      // Tema para tabs
      tabBarTheme: TabBarThemeData(
        labelColor: themeProvider.primaryColor,
        unselectedLabelColor: Colors.grey,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: themeProvider.primaryColor, width: 2),
        ),
      ),
      // Tema para iconos por defecto
      iconTheme: IconThemeData(color: themeProvider.primaryColor),
      // Tema para checkboxes
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return themeProvider.primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      // Tema para radio buttons
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return themeProvider.primaryColor;
          }
          return Colors.grey;
        }),
      ),
      // Tema para cursor y selección de texto
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: themeProvider.primaryColor,
        selectionColor: themeProvider.primaryColor.withValues(alpha: 0.3),
        selectionHandleColor: themeProvider.primaryColor,
      ),
    );
  }

  ThemeData _buildDarkTheme(ThemeProvider themeProvider) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: themeProvider.primaryColor,
      scaffoldBackgroundColor: AppColors.darkBackground2,
      colorScheme: ColorScheme.dark(
        primary: themeProvider.primaryColor,
        secondary: themeProvider.secondaryColor,
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
            return themeProvider.primaryColor;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return themeProvider.primaryColor.withValues(alpha: 0.5);
          }
          return Colors.grey.withValues(alpha: 0.3);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: themeProvider.primaryColor,
        thumbColor: themeProvider.primaryColor,
        inactiveTrackColor: themeProvider.primaryColor.withValues(alpha: 0.3),
      ),
      // Tema para NavigationBar (bottom navigation)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: themeProvider.primaryColor.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: themeProvider.primaryColor);
          }
          return const IconThemeData(color: Colors.grey);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: themeProvider.primaryColor, fontSize: 12);
          }
          return const TextStyle(color: Colors.grey, fontSize: 12);
        }),
      ),
      // Tema para BottomNavigationBar (alternativo)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: themeProvider.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedIconTheme: IconThemeData(color: themeProvider.primaryColor),
        unselectedIconTheme: const IconThemeData(color: Colors.grey),
      ),
      // Tema para FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: Colors.white,
      ),
      // Tema para botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      // Tema para tabs
      tabBarTheme: TabBarThemeData(
        labelColor: themeProvider.primaryColor,
        unselectedLabelColor: Colors.grey,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: themeProvider.primaryColor, width: 2),
        ),
      ),
      // Tema para iconos por defecto
      iconTheme: IconThemeData(color: themeProvider.primaryColor),
      // Tema para checkboxes
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return themeProvider.primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      // Tema para radio buttons
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return themeProvider.primaryColor;
          }
          return Colors.grey;
        }),
      ),
      // Tema para cursor y selección de texto
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: themeProvider.primaryColor,
        selectionColor: themeProvider.primaryColor.withValues(alpha: 0.3),
        selectionHandleColor: themeProvider.primaryColor,
      ),
    );
  }
}
