import 'package:notelens_app/common/config/database_config.dart';
import 'package:notelens_app/src/model/category.dart';
import 'package:notelens_app/src/model/qna.dart';

class DatabaseUtils {
  static Future<void> initializeDatabase() async {
    final db = await DatabaseConfig().database;

    // 새로운 Category 객체를 생성합니다.
    final category = Category(
      title: 'Sample Category',
      description: 'This is a sample category',
      createdAt: DateTime.now(),
      isDeleted: false,
    );

    // 데이터를 데이터베이스에 삽입합니다.
    final categoryId = await db.insert(Category.tableName, category.toMap());

    // 새로운 QnA 객체를 생성합니다.
    final qna = QnA(
      title: 'Sample QnA',
      qContent: 'What is this?',
      aContent: 'This is a sample QnA.',
      createdAt: DateTime.now(),
      isDeleted: false,
      categoryId: categoryId,
    );

    // 데이터를 데이터베이스에 삽입합니다.
    await db.insert(QnA.tableName, qna.toMap());

    // 데이터베이스에서 모든 Category 객체를 읽어옵니다.
    final categories = await db.query(Category.tableName);

    // 각 Category 객체를 출력합니다.
    categories.forEach((categoryMap) {
      final category = Category.fromMap(categoryMap);
      print(category);
    });

    // 데이터베이스에서 모든 QnA 객체를 읽어옵니다.
    final qnas = await db.query(QnA.tableName);

    // 각 QnA 객체를 출력합니다.
    qnas.forEach((qnaMap) {
      final qna = QnA.fromMap(qnaMap);
      print(qna);
    });

    // 데이터베이스를 닫습니다.
    await DatabaseConfig().closeDatabase();
  }
}
