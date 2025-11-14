import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class AddHabitScreen extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? habitData;
  
  const AddHabitScreen({
    super.key,
    this.isEditing = false,
    this.habitData,
  });

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final CategoryService _categoryService = CategoryService();

  String _selectedFrequency = 'Diario';
  Category? _selectedCategory;
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<Category> _userCategories = [];
  bool _isLoadingCategories = true;

  final List<String> _frequencies = ['Diario', 'Semanal', 'Mensual'];

  @override
  void initState() {
    super.initState();
    _loadUserCategories();
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
          _selectedCategory = newCategories.isNotEmpty
              ? newCategories[0]
              : null;
          _isLoadingCategories = false;
        });
      } else {
        setState(() {
          _userCategories = categories;
          _selectedCategory = categories[0];
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
          : AppColors.primaryBackground,
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
          color: isDark ? Colors.white : AppColors.primary,
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
                color: AppColors.action,
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
            const SizedBox(height: 24),
            _buildTimeSection(),
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
                  borderSide: BorderSide(color: AppColors.primary),
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
                  borderSide: BorderSide(color: AppColors.primary),
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
                    selectedColor: AppColors.action.withOpacity(0.3),
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
                    selectedColor: AppColors.action.withOpacity(0.3),
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
              _selectedType == 'time' ? 'Objetivo (minutos)' : 'Objetivo (cantidad)',
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
                  borderSide: BorderSide(color: AppColors.primary),
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
              _selectedType == 'time' ? 'Incremento (minutos)' : 'Incremento por paso',
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
                  borderSide: BorderSide(color: AppColors.primary),
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
              children: _userCategories
                  .map(
                    (category) => ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.icon,
                            size: 16,
                            color: _selectedCategory?.id == category.id
                                ? Colors.white
                                : category.color,
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
                      selectedColor: category.color.withOpacity(0.7),
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
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySection() {
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
              'Frecuencia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: _frequencies
                  .map(
                    (frequency) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(frequency),
                          selected: _selectedFrequency == frequency,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFrequency = frequency;
                            });
                          },
                          selectedColor: AppColors.action.withOpacity(0.3),
                          backgroundColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: _selectedFrequency == frequency
                                ? Colors.white
                                : (isDark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade700),
                            fontWeight: _selectedFrequency == frequency
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection() {
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
              'Recordatorio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Icon(Icons.access_time, color: AppColors.primary),
                  ],
                ),
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
          backgroundColor: AppColors.action,
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

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
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

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecciona una categoría'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Crear el nuevo hábito
    final newHabit = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'categoryId': _selectedCategory!.id,
      'categoryName': _selectedCategory!.name,
      'categoryIcon': _selectedCategory!.icon.codePoint,
      'categoryColor': _selectedCategory!.color.value,
      'frequency': _selectedFrequency,
      'type': _selectedType,
      'target': int.tryParse(_targetController.text) ?? 1,
      'increment': int.tryParse(_incrementController.text) ?? 1,
      'time': '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      'progress': widget.isEditing ? (widget.habitData!['progress'] ?? 0.0) : 0.0,
    };

    Navigator.of(context).pop(habit);
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