import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
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
  bool _imageLoadError = false; // Para rastrear errores de carga de imagen
  bool _isLoading = true;

  // Estadísticas de hábitos
  int totalHabits = 0;
  int currentStreak = 0;
  double overallProgress = 0.0;
  int completedHabitsToday = 0;

  String get fullName {
    final name = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
    return name.isNotEmpty ? name : 'Usuario';
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar estadísticas cuando se regrese a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadHabitStats();
      }
    });
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
          _imageLoadError = false; // Resetear error al cargar nueva foto
        });
      } else if (mounted && user != null) {
        setState(() {
          firstName = user.displayName ?? 'Usuario';
          userEmail = user.email ?? '';
          photoURL = user.photoURL;
          _imageLoadError = false; // Resetear error al cargar nueva foto
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
      await habitService.initializeHabits();

      // Calcular total de templates de hábitos activos
      totalHabits = await habitService.getTotalActiveTemplates();

      // Calcular progreso general actual
      overallProgress = await habitService.getCurrentOverallProgress();

      // Calcular racha actual usando la nueva estructura
      currentStreak = await habitService.getStreakFromDailyProgress();

      // Calcular hábitos completados hoy
      completedHabitsToday = await _getCompletedHabitsToday(habitService);
    } catch (e) {
      debugPrint('Error loading habit stats: $e');
      // En caso de error, usar valores por defecto
      totalHabits = 0;
      overallProgress = 0.0;
      currentStreak = 0;
      completedHabitsToday = 0;
    }
  }

  Future<int> _getCompletedHabitsToday(HabitService habitService) async {
    try {
      // Obtener hábitos del día actual desde el servicio
      final dailyHabits = habitService.dailyHabits;

      if (dailyHabits.isEmpty) {
        return 0;
      }

      // Contar hábitos completados (progreso >= 1.0)
      return dailyHabits.where((habit) => habit.value >= 1.0).length;
    } catch (e) {
      debugPrint('Error getting completed habits today: $e');
      return 0;
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
                      // Procesar URL de Google para evitar problemas de CORS
                      String? processedImageUrl;
                      if (photoURL != null && photoURL!.isNotEmpty) {
                        if (photoURL!.contains('googleusercontent.com')) {
                          // Modificar la URL de Google para mejorar compatibilidad
                          processedImageUrl = photoURL!.replaceAll('=s96-c', '=s200-c');
                        } else {
                          processedImageUrl = photoURL;
                        }
                      }
                      
                      // Si hay error de carga o URL vacía, mostrar iniciales
                      final shouldShowImage = processedImageUrl != null && 
                                            processedImageUrl.isNotEmpty && 
                                            !_imageLoadError;
                      
                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: themeProvider.primaryColor,
                        child: shouldShowImage
                            ? ClipOval(
                                child: processedImageUrl.startsWith('data:image')
                                    ? Image.memory(
                                        base64Decode(processedImageUrl.split(',')[1]),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                            setState(() {
                                              _imageLoadError = true;
                                            });
                                          });
                                          return Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                fullName.isNotEmpty
                                                    ? fullName[0].toUpperCase()
                                                    : 'U',
                                                style: const TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      )
                                    : Image.network(
                                        processedImageUrl,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        headers: {
                                          'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
                                          'Referer': 'https://accounts.google.com/',
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                fullName.isNotEmpty
                                                    ? fullName[0].toUpperCase()
                                                    : 'U',
                                                style: const TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              if (photoURL?.contains('googleusercontent.com') == true)
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.info_outline,
                                                      color: Colors.white70,
                                                      size: 12,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Google',
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    fullName.isNotEmpty
                                        ? fullName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
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

            // Mostrar estadísticas arriba si hay biografía o metas
            if (bio.isNotEmpty || goals.isNotEmpty)
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
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Hábitos',
                            totalHabits.toString(),
                            Icons.task_alt,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Completados',
                            '$completedHabitsToday/$totalHabits',
                            Icons.check_circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Racha',
                            currentStreak > 0
                                ? '$currentStreak día${currentStreak > 1 ? 's' : ''}'
                                : '0 días',
                            Icons.local_fire_department,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Progreso',
                            '${(overallProgress * 100).toStringAsFixed(0)}%',
                            Icons.trending_up,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            if (bio.isNotEmpty) const SizedBox(height: 24),

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
            if (!(bio.isNotEmpty || goals.isNotEmpty))
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
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Hábitos',
                            totalHabits.toString(),
                            Icons.task_alt,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Completados',
                            '$completedHabitsToday/$totalHabits',
                            Icons.check_circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Racha',
                            currentStreak > 0
                                ? '$currentStreak día${currentStreak > 1 ? 's' : ''}'
                                : '0 días',
                            Icons.local_fire_department,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Progreso',
                            '${(overallProgress * 100).toStringAsFixed(0)}%',
                            Icons.trending_up,
                          ),
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
