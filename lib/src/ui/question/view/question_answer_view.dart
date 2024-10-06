import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:ui'; // 블러 효과를 위해 필요

class QuestionAnswerView extends StatefulWidget {
  final List<String> answers;

  const QuestionAnswerView({super.key, required this.answers});

  @override
  _QuestionAnswerViewState createState() => _QuestionAnswerViewState();
}

class _QuestionAnswerViewState extends State<QuestionAnswerView> {
  final PageController pageController =
      PageController(viewportFraction: 1, keepPage: true);

  // 각 페이지에 대한 ScrollController를 생성합니다.
  late List<ScrollController> scrollControllers;

  @override
  void initState() {
    super.initState();
    // 각 질문마다 ScrollController를 생성
    scrollControllers =
        List.generate(widget.answers.length, (index) => ScrollController());
  }

  @override
  void dispose() {
    // 생성된 모든 ScrollController를 dispose 합니다.
    for (var controller in scrollControllers) {
      controller.dispose();
    }
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _myAppBar(context),
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: PageView.builder(
              controller: pageController,
              itemCount: widget.answers.length, // 질문 수만큼 페이지를 생성
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Q$index: 질문에 대한 답변",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Scrollbar(
                          controller: scrollControllers[
                              index], // 각 페이지마다 ScrollController 사용
                          thumbVisibility: true,
                          child: ListView(
                            controller: scrollControllers[index],
                            children: [
                              Text(
                                widget.answers[index], // 질문에 대한 답변 표시
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SmoothPageIndicator(
              controller: pageController,
              count: widget.answers.length, // 질문 수만큼 점 표시
              effect: const WormEffect(
                  dotWidth: 25,
                  dotHeight: 25,
                  spacing: 8,
                  activeDotColor: Colors.green),
              onDotClicked: (index) => pageController.animateToPage(index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _myAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 206, 206, 206),
      leading: InkWell(
        child: const Icon(Icons.arrow_back, size: 30),
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
      title: const Text("ChatGPT Responses", style: TextStyle(fontSize: 20)),
    );
  }
}
