import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

class CategoryService {
  static const String _categoriesKey = 'user_categories';

  // Obtener todas las categorías de un usuario
  Future<List<Category>> getUserCategories(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString('${_categoriesKey}_$userId');

    if (categoriesJson == null) {
      return [];
    }

    final List<dynamic> categoriesList = json.decode(categoriesJson);
    return categoriesList.map((json) => Category.fromMap(json)).toList();
  }

  // Guardar todas las categorías
  Future<void> _saveCategories(String userId, List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = json.encode(
      categories.map((c) => c.toMap()).toList(),
    );
    await prefs.setString('${_categoriesKey}_$userId', categoriesJson);
  }

  // Crear una nueva categoría
  Future<void> createCategory(Category category) async {
    try {
      final categories = await getUserCategories(category.userId);
      categories.add(category);
      await _saveCategories(category.userId, categories);
    } catch (e) {
      throw 'Error al crear la categoría: $e';
    }
  }

  // Actualizar una categoría existente
  Future<void> updateCategory(Category category) async {
    try {
      final categories = await getUserCategories(category.userId);
      final index = categories.indexWhere((c) => c.id == category.id);

      if (index != -1) {
        categories[index] = category;
        await _saveCategories(category.userId, categories);
      }
    } catch (e) {
      throw 'Error al actualizar la categoría: $e';
    }
  }

  // Eliminar una categoría
  Future<void> deleteCategory(String categoryId, String userId) async {
    try {
      final categories = await getUserCategories(userId);
      categories.removeWhere((c) => c.id == categoryId);
      await _saveCategories(userId, categories);
    } catch (e) {
      throw 'Error al eliminar la categoría: $e';
    }
  }

  // Crear categorías predeterminadas para un nuevo usuario
  Future<void> createDefaultCategories(String userId) async {
    final existing = await getUserCategories(userId);

    if (existing.isEmpty) {
      final defaultCategories = [
        Category(
          id: '${userId}_salud',
          name: 'Salud',
          icon: Icons.favorite,
          color: Colors.red,
          userId: userId,
        ),
        Category(
          id: '${userId}_productividad',
          name: 'Productividad',
          icon: Icons.work,
          color: Colors.blue,
          userId: userId,
        ),
        Category(
          id: '${userId}_bienestar',
          name: 'Bienestar',
          icon: Icons.spa,
          color: Colors.green,
          userId: userId,
        ),
        Category(
          id: '${userId}_aprendizaje',
          name: 'Aprendizaje',
          icon: Icons.school,
          color: Colors.orange,
          userId: userId,
        ),
        Category(
          id: '${userId}_ejercicio',
          name: 'Ejercicio',
          icon: Icons.fitness_center,
          color: Colors.orange,
          userId: userId,
        ),
      ];

      await _saveCategories(userId, defaultCategories);
    }
  }

  // Verificar si una categoría está siendo usada por algún hábito
  Future<bool> isCategoryInUse(String categoryId, String userId) async {
    // Por ahora retornamos false, se implementará cuando tengas el sistema de hábitos
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getString('user_habits_$userId');

    if (habitsJson == null) return false;

    final List<dynamic> habits = json.decode(habitsJson);
    return habits.any((habit) => habit['categoryId'] == categoryId);
  }
}
