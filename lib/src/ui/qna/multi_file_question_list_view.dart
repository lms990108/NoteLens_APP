import 'package:flutter/material.dart';
import 'package:notelens_app/src/ui/question/view/question_list_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MultiFileQuestionListView extends StatefulWidget {
  final List<Map<String, dynamic>> fileResponses;

  const MultiFileQuestionListView({Key? key, required this.fileResponses})
      : super(key: key);

  @override
  _MultiFileQuestionListViewState createState() =>
      _MultiFileQuestionListViewState();
}

class _MultiFileQuestionListViewState extends State<MultiFileQuestionListView> {
  final PageController _pageController = PageController();
  late List<List<bool>> _isChecked; // 각 파일의 체크 상태를 저장할 리스트

  @override
  void initState() {
    super.initState();
    // 각 파일의 질문 개수에 맞게 체크박스 상태 초기화
    _isChecked = widget.fileResponses
        .map((fileData) =>
            List<bool>.filled(fileData["questions"].length, false))
        .toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView with QuestionListView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.fileResponses.length,
            itemBuilder: (context, index) {
              final fileData = widget.fileResponses[index];
              return QuestionListView(
                questions: List<String>.from(fileData["questions"]),
                contents: List<String>.from(fileData["contents"]),
                originalContent: fileData["originalContent"] as String,
                isChecked: _isChecked[index], // 현재 페이지의 체크 상태 전달
                onCheckChanged: (questionIndex, value) {
                  setState(() {
                    _isChecked[index][questionIndex] = value; // 체크 상태 업데이트
                  });
                },
              );
            },
          ),
          // Page indicator at the bottom
          Positioned(
            bottom: 16.0,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: widget.fileResponses.length,
                effect: WormEffect(
                  dotWidth: 10.0,
                  dotHeight: 10.0,
                  spacing: 8.0,
                  activeDotColor: Colors.deepPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
