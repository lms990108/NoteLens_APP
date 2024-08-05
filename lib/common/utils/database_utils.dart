import 'package:notelens_app/common/config/database_config.dart';

class DatabaseUtils {
  // 데이터베이스 초기화
  static Future<void> initializeDatabase() async {
    await DatabaseConfig().database;
  }
}
