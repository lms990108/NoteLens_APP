import 'package:flutter/material.dart';
import 'package:notelens_app/src/data/repository/category_repository.dart';
import 'package:notelens_app/src/data/model/category.dart';

class CategoryListViewModel extends ChangeNotifier {
  final CategoryRepository _categoryRepository = CategoryRepository();

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  // 모든 카테고리 가져오기
  Future<void> fetchCategories() async {
    _categories = await _categoryRepository.getAllCategories();
    notifyListeners(); // UI 업데이트
  }

  // 카테고리 추가하기
  Future<void> addCategory(Category category) async {
    final newCategory = await _categoryRepository.createCategory(category);
    _categories.add(newCategory);
    notifyListeners(); // UI 업데이트
  }

  // 카테고리 업데이트하기
  Future<void> updateCategory(Category category) async {
    await _categoryRepository.updateCategory(category);
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
    notifyListeners(); // UI 업데이트
  }

  // 카테고리 삭제하기
  Future<void> deleteCategory(int id) async {
    await _categoryRepository.deleteCategory(id);
    _categories.removeWhere((category) => category.id == id);
    notifyListeners(); // UI 업데이트
  }
}
