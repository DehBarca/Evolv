import 'package:evolv/screens/home.dart';
import 'package:evolv/screens/perfil_screen.dart';
import 'package:evolv/screens/settings.dart';
import 'package:evolv/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabsScreen> {
  var currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Evolv',
          style: TextStyle(color: isDark ? Colors.white : AppColors.primary),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: MainDrawer(
        changeIndex: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
      ),
      body: [HomePage(), PerfilScreen(), SettingsScreen()][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
