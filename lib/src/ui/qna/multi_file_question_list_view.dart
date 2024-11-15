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
