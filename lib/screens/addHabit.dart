import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedFrequency = 'Diario';
  String _selectedCategory = 'Salud';
  TimeOfDay _selectedTime = TimeOfDay.now();

  final List<String> _frequencies = ['Diario', 'Semanal', 'Mensual'];
  final List<String> _categories = [
    'Salud',
    'Productividad',
    'Bienestar',
    'Aprendizaje',
    'Ejercicio',
  ];

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
          'Nuevo Hábito',
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
              'Guardar',
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

  Widget _buildCategorySection() {
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
              children: _categories
                  .map(
                    (category) => ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      selectedColor: AppColors.action.withOpacity(0.3),
                      backgroundColor: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: _selectedCategory == category
                            ? Colors.white
                            : (isDark
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700),
                        fontWeight: _selectedCategory == category
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
        child: const Text(
          'Crear Hábito',
          style: TextStyle(
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

    // Crear el nuevo hábito
    final newHabit = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory,
      'frequency': _selectedFrequency,
      'time':
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      'progress': 0.0,
    };

    // Regresar el hábito a la pantalla anterior
    Navigator.of(context).pop(newHabit);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
