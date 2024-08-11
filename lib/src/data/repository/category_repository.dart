import 'package:sqflite/sqflite.dart';
import 'package:notelens_app/src/data/model/category.dart';
import 'package:notelens_app/common/config/database_config.dart';

class CategoryRepository {
  final DatabaseConfig _databaseConfig = DatabaseConfig(); // 싱글톤 인스턴스를 가져옵니다.

  /// 데이터베이스에 새로운 카테고리를 생성하고 생성된 카테고리를 반환합니다.
  Future<Category> createCategory(Category category) async {
    final db = await _databaseConfig.database; // 데이터베이스 객체를 가져옵니다.
    final id = await db.insert(Category.tableName, category.toMap());
    return category.copyWith(id: id);
  }

  /// ID를 통해 카테고리를 조회합니다. 해당 ID의 카테고리가 존재하면 반환하고, 존재하지 않으면 null을 반환합니다.
  Future<Category?> getCategoryById(int id) async {
    final db = await _databaseConfig.database; // 데이터베이스 객체를 가져옵니다.
    final maps = await db.query(
      Category.tableName,
      columns: CategoryFields.values, // 필드 목록을 사용하여 쿼리할 열을 지정합니다.
      where: '${CategoryFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// 데이터베이스에 있는 모든 카테고리를 조회하여 리스트로 반환합니다.
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

  /// ID를 통해 카테고리를 삭제합니다. 삭제된 행의 개수를 반환합니다.
  Future<int> deleteCategory(int id) async {
    final db = await _databaseConfig.database; // 데이터베이스 객체를 가져옵니다.
    return await db.delete(
      Category.tableName,
      where: '${CategoryFields.id} = ?',
      whereArgs: [id],
    );
  }

  /// 소프트 삭제를 수행합니다. isDeleted 플래그를 true로 설정하고, deletedAt 시간을 현재 시간으로 업데이트합니다. 업데이트된 행의 개수를 반환합니다.
  Future<int> softDeleteCategory(int id) async {
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
