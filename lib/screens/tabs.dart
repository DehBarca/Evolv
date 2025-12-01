import 'home.dart';
import 'perfil_screen.dart';
import 'settings.dart';
import '../widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

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

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: themeProvider.primaryColor,
            title: Text('Evolv', style: TextStyle(color: Colors.white)),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          drawer: MainDrawer(
            changeIndex: (index) {
              setState(() {
                currentPageIndex = index;
              });
            },
          ),
          body: [
            HomePage(),
            ProfileScreen(),
            SettingsScreen(),
          ][currentPageIndex],
          bottomNavigationBar: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return NavigationBar(
                selectedIndex: currentPageIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    currentPageIndex = index;
                  });
                },
                backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                indicatorColor: themeProvider.primaryColor.withValues(
                  alpha: 0.2,
                ),
                destinations: [
                  NavigationDestination(
                    selectedIcon: Icon(
                      Icons.home,
                      color: themeProvider.primaryColor,
                    ),
                    icon: Icon(Icons.home_outlined),
                    label: "Home",
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(
                      Icons.person,
                      color: themeProvider.primaryColor,
                    ),
                    icon: Icon(Icons.person_outline),
                    label: "Profile",
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(
                      Icons.settings,
                      color: themeProvider.primaryColor,
                    ),
                    icon: Icon(Icons.settings_outlined),
                    label: "Settings",
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
