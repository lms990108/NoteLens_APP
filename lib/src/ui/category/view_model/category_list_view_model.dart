import 'package:flutter/material.dart';
import 'package:notelens_app/src/data/repository/category_repository.dart';
import 'package:notelens_app/src/data/model/category.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CategoryListViewModel extends ChangeNotifier {
  bool _isLeftBlurred = false;
  bool _isRightBlurred = false;
  bool get isLeftBlurred => _isLeftBlurred;
  bool get isRightBlurred => _isRightBlurred;

  File? selectedFile;
  File? get file => selectedFile;
  static const String apiUrl =
      'http://13.124.185.96:8001/api/yolo/yolo_clova_once';

  // 왼쪽 하단 아이콘 토글
  void toggleLeftBlur() {
    _isLeftBlurred = !_isLeftBlurred;
    if (_isRightBlurred) _isRightBlurred = false;
    notifyListeners();
  }

  // 오른쪽 하단 아이콘 토글
  void toggleRightBlur() {
    _isRightBlurred = !_isRightBlurred;
    if (_isLeftBlurred) _isLeftBlurred = false;
    notifyListeners();
  }

  // 블러 리셋
  void resetBlur() {
    _isLeftBlurred = false;
    _isRightBlurred = false;
    notifyListeners();
  }

  // 파일 선택
  void setSelectedFile(File file) {
    selectedFile = file;
    notifyListeners();
  }

  // 파일 서버 업로드
  Future<Map<String, dynamic>?> uploadFileToServer(File file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath(
        'file', // 서버에서 기대하는 파일 필드 이름
        file.path,
      ));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        print('Failed to upload file: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('An error occurred during the upload: $e');
      return null;
    }
  }

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
