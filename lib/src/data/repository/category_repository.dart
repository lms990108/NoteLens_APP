import 'package:notelens_app/src/data/model/category.dart';
import 'package:notelens_app/common/config/database_config.dart';

class CategoryRepository {
  final DatabaseConfig _databaseConfig = DatabaseConfig(); // 싱글톤 인스턴스를 가져옵니다.

  /// 새로운 카테고리 생성
  Future<Category> createCategory(Category category) async {
    final db = await _databaseConfig.database;
    final id = await db.insert(Category.tableName, category.toMap());
    return category.copyWith(id: id);
  }

  /// 카테고리 조회 (ID)
  Future<Category?> getCategoryById(int id) async {
    final db = await _databaseConfig.database;

    final maps = await db.query(
      Category.tableName,
      columns: [
        CategoryFields.id,
        CategoryFields.title,
        CategoryFields.description,
        CategoryFields.createdAt,
        CategoryFields.deletedAt,
        CategoryFields.isDeleted,
      ],
      where: '${CategoryFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// 삭제되지 않은 카테고리만 조회
  Future<List<Category>> getAllCategories() async {
    final db = await _databaseConfig.database;

    // isDeleted가 false(0)인 항목만 가져옴
    final maps = await db.query(
      Category.tableName,
      where: '${CategoryFields.isDeleted} = ?',
      whereArgs: [0], // 0은 false를 의미
    );

    return maps.map((map) => Category.fromMap(map)).toList();
  }

  /// 기존의 카테고리를 업데이트
  Future<int> updateCategory(Category category) async {
    final db = await _databaseConfig.database;
    return await db.update(
      Category.tableName,
      category.toMap(),
      where: '${CategoryFields.id} = ?',
      whereArgs: [category.id],
    );
  }

  /// 카테고리 soft delete
  Future<int> deleteCategory(int id) async {
    final db = await _databaseConfig.database;
    final currentDate = DateTime.now();
    return await db.update(
      Category.tableName,
      {
        CategoryFields.isDeleted: 1,
        CategoryFields.deletedAt: currentDate.toIso8601String(),
      },
      where: '${CategoryFields.id} = ?',
      whereArgs: [id],
    );
  }

  /// 제목을 기준으로 카테고리 검색
  Future<List<Category>> getCategoriesByTitle(String title) async {
    final db = await _databaseConfig.database;
    final maps = await db.query(
      Category.tableName,
      where:
          '${CategoryFields.title} LIKE ? AND ${CategoryFields.isDeleted} = ?',
      whereArgs: ['%$title%', 0], // 삭제되지 않은 항목만 검색
    );

    return maps.map((map) => Category.fromMap(map)).toList();
  }
}
