import 'package:notelens_app/src/data/model/qna.dart';
import 'package:notelens_app/common/config/database_config.dart';

class QnARepository {
  final DatabaseConfig _databaseConfig = DatabaseConfig(); // 싱글톤 인스턴스를 가져옵니다.

  /// 새로운 QnA 생성
  Future<QnA> createQnA(QnA qna) async {
    final db = await _databaseConfig.database; // 데이터베이스 객체를 가져옵니다.
    final id = await db.insert(QnA.tableName, qna.toMap());
    return qna.copyWith(id: id);
  }

  /// QnA 조회 (ID로 조회)
  Future<QnA?> getQnAById(int id) async {
    final db = await _databaseConfig.database;

    final maps = await db.query(
      QnA.tableName,
      columns: [
        QnAFields.id,
        QnAFields.title,
        QnAFields.qContent,
        QnAFields.aContent,
        QnAFields.memo,
        QnAFields.createdAt,
        QnAFields.deletedAt,
        QnAFields.isDeleted,
        QnAFields.categoryId,
      ],
      where: '${QnAFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return QnA.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// 특정 카테고리에 속한 QnA 목록 조회 (isDeleted = false)
  Future<List<QnA>> getQnAsByCategory(int categoryId) async {
    final db = await _databaseConfig.database;

    final maps = await db.query(
      QnA.tableName,
      where: '${QnAFields.categoryId} = ? AND ${QnAFields.isDeleted} = 0',
      whereArgs: [categoryId],
    );

    return maps.map((map) => QnA.fromMap(map)).toList();
  }

  /// 전체 QnA 목록 조회 (삭제되지 않은 항목만)
  Future<List<QnA>> getAllQnAs() async {
    final db = await _databaseConfig.database;

    final maps = await db.query(
      QnA.tableName,
      where: '${QnAFields.isDeleted} = 0',
    );

    return maps.map((map) => QnA.fromMap(map)).toList();
  }

  /// QnA 업데이트 (ID로 업데이트)
  Future<int> updateQnA(QnA qna) async {
    final db = await _databaseConfig.database;
    return await db.update(
      QnA.tableName,
      qna.toMap(),
      where: '${QnAFields.id} = ?',
      whereArgs: [qna.id],
    );
  }

  /// QnA soft delete (논리 삭제)
  Future<int> deleteQnA(int id) async {
    final db = await _databaseConfig.database;
    final currentDate = DateTime.now();
    return await db.update(
      QnA.tableName,
      {
        QnAFields.isDeleted: 1,
        QnAFields.deletedAt: currentDate.toIso8601String(),
      },
      where: '${QnAFields.id} = ?',
      whereArgs: [id],
    );
  }

  /// 제목으로 QnA 검색 (삭제되지 않은 항목만)
  Future<List<QnA>> searchQnAsByTitle(String title) async {
    final db = await _databaseConfig.database;

    final maps = await db.query(
      QnA.tableName,
      where: '${QnAFields.title} LIKE ? AND ${QnAFields.isDeleted} = 0',
      whereArgs: ['%$title%'],
    );

    return maps.map((map) => QnA.fromMap(map)).toList();
  }
}
