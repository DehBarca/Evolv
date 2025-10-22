import 'package:flutter/material.dart';
import '../constants/app_constants.dart'; 

class MainDrawer extends StatelessWidget {
  final void Function(int) changeIndex;
  const MainDrawer({super.key, required this.changeIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Center(
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: AppColors.primary),
            title: Text(
              'Home',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              changeIndex(0);
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: AppColors.primary),
            title: Text(
              'Profile',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              changeIndex(1);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: AppColors.primary),
            title: Text(
              'Settings',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              changeIndex(2);
            },
          ),
        ],
      ),
    );
  }
}
