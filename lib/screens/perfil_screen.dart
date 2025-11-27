import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../services/user_profile_service.dart';
import '../services/habit_service.dart';
import '../providers/theme_provider.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfileService _profileService = UserProfileService();

  String firstName = "Usuario";
  String lastName = "";
  String userEmail = "";
  int age = 0;
  String bio = "";
  String goals = "";
  String? photoURL;
  bool _isLoading = true;

  // Estadísticas de hábitos
  int totalHabits = 0;
  int currentStreak = 0;
  double overallProgress = 0.0;

  String get fullName {
    final name = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
    return name.isNotEmpty ? name : 'Usuario';
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _profileService.getCurrentUserProfile();
      final user = FirebaseAuth.instance.currentUser;

      if (mounted && profile != null) {
        setState(() {
          firstName = profile.firstName;
          lastName = profile.lastName;
          userEmail = profile.email;
          age = profile.age;
          bio = profile.bio;
          goals = profile.goals;
          photoURL = profile.photoUrl;
        });
      } else if (mounted && user != null) {
        setState(() {
          firstName = user.displayName ?? 'Usuario';
          userEmail = user.email ?? '';
          photoURL = user.photoURL;
        });
      }

      // Cargar estadísticas de hábitos
      await _loadHabitStats();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadHabitStats() async {
    try {
      final habitService = Provider.of<HabitService>(context, listen: false);

      // Asegurar que los hábitos estén cargados
      if (habitService.habits.isEmpty) {
        await habitService.initializeHabits();
      }

      // Calcular total de hábitos
      totalHabits = habitService.habits.length;

      // Calcular progreso general
      overallProgress = habitService.overallProgress;

      // Calcular racha actual desde el historial
      currentStreak = await habitService.getCurrentStreak();
    } catch (e) {
      // En caso de error, usar valores por defecto
      totalHabits = 0;
      overallProgress = 0.0;
      currentStreak = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Text(
              'Perfil',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : themeProvider.primaryColor,
              ),
            );
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Theme.of(context).primaryColor,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar y información básica
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: themeProvider.primaryColor,
                        backgroundImage: photoURL != null
                            ? NetworkImage(photoURL!)
                            : null,
                        child: photoURL == null
                            ? Text(
                                fullName.isNotEmpty
                                    ? fullName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fullName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  if (age > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$age años',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white60
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                          // Recargar datos al volver
                          _loadUserData();
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar perfil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeProvider.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Biografía
            if (bio.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return Icon(
                              Icons.info_outline,
                              color: themeProvider.primaryColor,
                              size: 20,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Biografía',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      bio,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

            if (bio.isNotEmpty) const SizedBox(height: 16),

            // Objetivos y metas
            if (goals.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return Icon(
                              Icons.flag_outlined,
                              color: themeProvider.primaryColor,
                              size: 20,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Objetivos y metas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      goals,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

            if (goals.isNotEmpty) const SizedBox(height: 16),

            // Estadísticas
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estadísticas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Hábitos',
                        totalHabits.toString(),
                        Icons.task_alt,
                      ),
                      _buildStatCard(
                        'Racha',
                        currentStreak > 0
                            ? '$currentStreak día${currentStreak > 1 ? 's' : ''}'
                            : '0 días',
                        Icons.local_fire_department,
                      ),
                      _buildStatCard(
                        'Progreso',
                        '${(overallProgress * 100).toStringAsFixed(0)}%',
                        Icons.trending_up,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Icon(icon, size: 24, color: themeProvider.primaryColor);
            },
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
