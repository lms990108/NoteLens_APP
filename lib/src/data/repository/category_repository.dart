import 'package:notelens_app/src/data/model/category.dart';
import 'package:notelens_app/common/config/database_config.dart';

class CategoryRepository {
  final DatabaseConfig _databaseConfig = DatabaseConfig(); // 싱글톤 인스턴스를 가져옵니다.

  /// 새로운 카테고리 생성
  Future<Category> createCategory(Category category) async {
    final db = await _databaseConfig.database; // 데이터베이스 객체를 가져옵니다.
    final id = await db.insert(Category.tableName, category.toMap());
    return category.copyWith(id: id);
  }

  /// 카테고리 조회 (ID)
  Future<Category?> getCategoryById(int id) async {
    final db = await _databaseConfig.database; // 데이터베이스 객체를 가져옵니다.

    // 필드 목록을 직접 지정하여 쿼리를 실행합니다.
    final maps = await db.query(
      Category.tableName, // "category"
      columns: [
        // 조회할 열 지정
        CategoryFields.id,
        CategoryFields.title,
        CategoryFields.description,
        CategoryFields.createdAt,
        CategoryFields.deletedAt,
        CategoryFields.isDeleted,
      ], // 필요한 필드 목록 지정 (입력될 값)
      where: '${CategoryFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// 카테고리 리스트 조회
  Future<List<Category>> getAllCategories() async {
    final db = await _databaseConfig.database; // 데이터베이스 객체를 가져옵니다.
    final maps = await db.query(Category.tableName);

    return maps.map((map) => Category.fromMap(map)).toList();
  }

  /// 기존의 카테고리를 업데이트합니다. 업데이트된 행의 개수를 반환합니다.
  Future<int> updateCategory(Category category) async {
    final db = await _databaseConfig.database; // 데이터베이스 객체를 가져옵니다.
    return await db.update(
      Category.tableName,
      category.toMap(),
      where: '${CategoryFields.id} = ?',
      whereArgs: [category.id],
    );
  }

  /// 카테고리 soft Delete
  Future<int> deleteCategory(int id) async {
    final db = await _databaseConfig.database; // 데이터베이스 객체를 가져옵니다.
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

  /// 제목을 기준으로 카테고리를 검색하여 일치하는 카테고리 리스트를 반환합니다.
  Future<List<Category>> getCategoriesByTitle(String title) async {
    final db = await _databaseConfig.database; // 데이터베이스 객체를 가져옵니다.
    final maps = await db.query(
      Category.tableName,
      where: '${CategoryFields.title} LIKE ?',
      whereArgs: ['%$title%'],
    );

    return maps.map((map) => Category.fromMap(map)).toList();
  }
}
