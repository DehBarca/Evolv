import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class AddHabitScreen extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? habitData;

  const AddHabitScreen({super.key, this.isEditing = false, this.habitData});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _targetController = TextEditingController(
    text: '1',
  );
  final TextEditingController _incrementController = TextEditingController(
    text: '1',
  );

  String _selectedType = 'count';
  Category? _selectedCategory;

  // Días de la semana seleccionados (1=Lunes, 7=Domingo)
  Set<int> _selectedDays = {1, 2, 3, 4, 5, 6, 7}; // Por defecto todos los días

  List<Category> _userCategories = [
    Category(
      id: 'dummy_salud',
      name: 'Salud',
      icon: Icons.favorite,
      color: Colors.red,
      userId: 'dummy',
    ),
    Category(
      id: 'dummy_productividad',
      name: 'Productividad',
      icon: Icons.work,
      color: Colors.blue,
      userId: 'dummy',
    ),
    Category(
      id: 'dummy_bienestar',
      name: 'Bienestar',
      icon: Icons.spa,
      color: Colors.green,
      userId: 'dummy',
    ),
    Category(
      id: 'dummy_aprendizaje',
      name: 'Aprendizaje',
      icon: Icons.school,
      color: Colors.orange,
      userId: 'dummy',
    ),
    Category(
      id: 'dummy_ejercicio',
      name: 'Ejercicio',
      icon: Icons.fitness_center,
      color: Colors.orange,
      userId: 'dummy',
    ),
  ];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadUserCategories();
    if (widget.isEditing && widget.habitData != null) {
      _nameController.text = widget.habitData!['name'] ?? '';
      _descriptionController.text = widget.habitData!['description'] ?? '';
      _selectedType = widget.habitData!['type'] ?? 'count';
      _targetController.text = (widget.habitData!['target'] ?? 1).toString();
      _incrementController.text = (widget.habitData!['increment'] ?? 1)
          .toString();

      // Cargar días activos si están disponibles
      final activeDays = widget.habitData!['activeDays'] as List<dynamic>?;
      if (activeDays != null) {
        _selectedDays = activeDays.map((e) => e as int).toSet();
      }
    }
  }

  Future<void> _loadUserCategories() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final categories = await _categoryService.getUserCategories(userId);

      // Si no tiene categorías, crear las predeterminadas
      if (categories.isEmpty) {
        await _categoryService.createDefaultCategories(userId);
        final newCategories = await _categoryService.getUserCategories(userId);
        setState(() {
          _userCategories = newCategories;

          // Si está editando, buscar la categoría correcta
          if (widget.isEditing && widget.habitData != null) {
            final categoryId = widget.habitData!['categoryId'];
            _selectedCategory = newCategories.firstWhere(
              (cat) => cat.id == categoryId,
              orElse: () => newCategories[0],
            );
          } else {
            _selectedCategory = newCategories.isNotEmpty
                ? newCategories[0]
                : null;
          }

          _isLoadingCategories = false;
        });
      } else {
        setState(() {
          _userCategories = categories;

          // Si está editando, buscar la categoría correcta
          if (widget.isEditing && widget.habitData != null) {
            final categoryId = widget.habitData!['categoryId'];
            _selectedCategory = categories.firstWhere(
              (cat) => cat.id == categoryId,
              orElse: () => categories[0],
            );
          } else {
            _selectedCategory = categories[0];
          }

          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar categorías: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? theme.scaffoldBackgroundColor
          : Provider.of<ThemeProvider>(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Editar Hábito' : 'Nuevo Hábito',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: isDark
              ? Colors.white
              : Provider.of<ThemeProvider>(context).primaryColor,
        ),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveHabit,
            child: Text(
              widget.isEditing ? 'Actualizar' : 'Guardar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Provider.of<ThemeProvider>(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameSection(),
            const SizedBox(height: 24),
            _buildDescriptionSection(),
            const SizedBox(height: 24),
            _buildTypeSection(),
            const SizedBox(height: 24),
            _buildTargetSection(),
            const SizedBox(height: 24),
            _buildIncrementSection(),
            const SizedBox(height: 24),
            _buildCategorySection(),
            const SizedBox(height: 24),
            _buildFrequencySection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre del hábito',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Ej: Leer 30 minutos',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Provider.of<ThemeProvider>(context).primaryColor,
                  ),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descripción',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Describe tu hábito...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Provider.of<ThemeProvider>(context).primaryColor,
                  ),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de hábito',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text('Conteo'),
                    selected: _selectedType == 'count',
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = 'count';
                      });
                    },
                    selectedColor: Provider.of<ThemeProvider>(
                      context,
                    ).primaryColor.withValues(alpha: 0.3),
                    backgroundColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: _selectedType == 'count'
                          ? Colors.white
                          : (isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade700),
                      fontWeight: _selectedType == 'count'
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: Text('Tiempo'),
                    selected: _selectedType == 'time',
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = 'time';
                      });
                    },
                    selectedColor: Provider.of<ThemeProvider>(
                      context,
                    ).primaryColor.withValues(alpha: 0.3),
                    backgroundColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: _selectedType == 'time'
                          ? Colors.white
                          : (isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade700),
                      fontWeight: _selectedType == 'time'
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedType == 'time'
                  ? 'Objetivo (minutos)'
                  : 'Objetivo (cantidad)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: _selectedType == 'time' ? 'Ej: 30' : 'Ej: 8',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Provider.of<ThemeProvider>(context).primaryColor,
                  ),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncrementSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedType == 'time'
                  ? 'Incremento (minutos)'
                  : 'Incremento por paso',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _incrementController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: _selectedType == 'time' ? 'Ej: 5' : 'Ej: 1',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Provider.of<ThemeProvider>(context).primaryColor,
                  ),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_isLoadingCategories) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_userCategories.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No tienes categorías. Créalas desde Ajustes.',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categoría',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _userCategories.map((category) {
                final catColor =
                    (category.color == Colors.orange ||
                        category.color == AppColors.primary)
                    ? themeProvider.primaryColor
                    : category.color;

                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        size: 16,
                        color: _selectedCategory?.id == category.id
                            ? Colors.white
                            : catColor,
                      ),
                      const SizedBox(width: 4),
                      Text(category.name),
                    ],
                  ),
                  selected: _selectedCategory?.id == category.id,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  selectedColor: catColor.withValues(alpha: 0.7),
                  backgroundColor: isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: _selectedCategory?.id == category.id
                        ? Colors.white
                        : (isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700),
                    fontWeight: _selectedCategory?.id == category.id
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dayNames = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Días de la semana',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final dayNumber = index + 1;
                final isSelected = _selectedDays.contains(dayNumber);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDays.remove(dayNumber);
                      } else {
                        _selectedDays.add(dayNumber);
                      }
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Provider.of<ThemeProvider>(context).primaryColor
                          : (isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200),
                      border: Border.all(
                        color: isSelected
                            ? Provider.of<ThemeProvider>(context).primaryColor
                            : (isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade300),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        dayNames[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (_selectedDays.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Selecciona al menos un día',
                  style: TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveHabit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Provider.of<ThemeProvider>(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
        ),
        child: Text(
          widget.isEditing ? 'Actualizar Hábito' : 'Crear Hábito',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _saveHabit() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, ingresa un nombre para el hábito'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecciona al menos un día de la semana'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecciona una categoría'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Crear el nuevo hábito template
    final newHabit = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'categoryId': _selectedCategory!.id,
      'categoryName': _selectedCategory!.name,
      'categoryIcon': _selectedCategory!.icon.codePoint,
      'categoryColor': _selectedCategory!.color.value,
      'type': _selectedType,
      'target': int.tryParse(_targetController.text) ?? 1,
      'increment': int.tryParse(_incrementController.text) ?? 1,
      'activeDays': _selectedDays.toList()..sort(), // Lista ordenada de días
      'progress': widget.isEditing
          ? (widget.habitData!['progress'] ?? 0.0)
          : 0.0,
    };

    Navigator.of(context).pop(newHabit);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _incrementController.dispose();
    super.dispose();
  }
}
