import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository/category_repository.dart';
import '../data/model/category.dart';

// CategoryRepository의 인스턴스를 제공하는 프로바이더
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

// 모든 카테고리를 불러오는 FutureProvider
final categoryListProvider = FutureProvider<List<Category>>((ref) async {
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  return await categoryRepository.getAllCategories();
});
