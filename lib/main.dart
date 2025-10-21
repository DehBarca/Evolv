// main.dart
import 'package:flutter/material.dart';
import 'screens/perfil_screen.dart';
import 'constants/app_constants.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.primaryBackground,
        useMaterial3: true,
      ),
      home: const PerfilScreen(),
    );

    return MaterialApp(home: PerfilScreen(perfil: perfil));
  }
}
