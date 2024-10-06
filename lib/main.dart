import 'package:flutter/material.dart';
import 'package:notelens_app/common/utils/database_utils.dart';
import 'package:notelens_app/src/ui/category/view_model/category_list_view_model.dart';
import 'package:provider/provider.dart';
import 'loading.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 데이터베이스 초기화 및 환경 변수 로딩에 대한 오류 처리 및 로그 추가
  try {
    await DatabaseUtils.initializeDatabase();
    print("Database initialized successfully");

    await dotenv.load(fileName: ".env");
    print("dotenv loaded successfully");

    // 환경 변수 확인
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('ERROR: OPENAI_API_KEY is missing or not loaded from .env file');
    } else {
      print('SUCCESS: OPENAI_API_KEY loaded successfully');
    }
  } catch (e) {
    print("Error during initialization: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CategoryListViewModel>(
            create: (_) => CategoryListViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteLens',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 0, 0)),
        useMaterial3: true,
      ),
      home: const LoadingView(), // 로딩 화면을 확인할 수 있도록 수정
    );
  }
}
