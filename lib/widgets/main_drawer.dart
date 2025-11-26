import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../utils/auth_utils.dart';
import '../providers/theme_provider.dart';

class MainDrawer extends StatelessWidget {
  final void Function(int) changeIndex;
  const MainDrawer({super.key, required this.changeIndex});

  Future<void> _showLogoutDialog(BuildContext context) async {
    // Mostrar el diálogo, que cerrará el drawer internamente después de confirmar
    return AuthUtils.showLogoutDialog(context, closeDrawer: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: themeProvider.primaryColor),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: themeProvider.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.displayName ?? 'Usuario',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: themeProvider.primaryColor),
                title: Text(
                  'Home',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  changeIndex(0);
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: themeProvider.primaryColor),
                title: Text(
                  'Profile',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  changeIndex(1);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.settings,
                  color: themeProvider.primaryColor,
                ),
                title: Text(
                  'Settings',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  changeIndex(2);
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: AppColors.error),
                title: Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _showLogoutDialog(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
