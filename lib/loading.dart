import 'package:flutter/material.dart';
import 'package:notelens_app/src/ui/category/view/category_list_view.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({super.key});

  @override
  _LoadingViewState createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  @override
  void initState() {
    super.initState();
    // 스플래시 화면을 3초 동안 표시하고, 이후에 CategoryListView로 이동
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CategoryListView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // 배경색 설정 (밝은 회색)
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circle with search icon
            Container(
              width: 120, // 원 크기
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.green, // 원의 배경색
                shape: BoxShape.circle, // 원 모양
              ),
              child: const Icon(
                Icons.search, // 돋보기 아이콘
                color: Colors.white, // 아이콘 색상
                size: 60, // 아이콘 크기
              ),
            ),
            const SizedBox(height: 20), // 간격
            // App Name Text
            const Text(
              'NoteLens',
              style: TextStyle(
                fontSize: 30, // 폰트 크기
                fontStyle: FontStyle.italic, // 이탤릭체
                color: Colors.black, // 텍스트 색상
              ),
            ),
          ],
        ),
      ),
    );
  }
}
