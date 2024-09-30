import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:ui'; // 블러 효과를 위해 필요

class QuestionAnswerView extends StatefulWidget {
  const QuestionAnswerView({super.key});

  @override
  _QuestionAnswerViewState createState() => _QuestionAnswerViewState();
}

class _QuestionAnswerViewState extends State<QuestionAnswerView> {
  bool isExistingCategory = true;
  final PageController pageController =
      PageController(viewportFraction: 1, keepPage: true);

  // 각 페이지에 대한 ScrollController를 생성합니다.
  List<ScrollController> scrollControllers =
      List.generate(5, (index) => ScrollController());

  void _showCategoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  // 추가: 스크롤 가능하도록 변경
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('카테고리 선택',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 20),
                      ToggleButtons(
                        isSelected: [isExistingCategory, !isExistingCategory],
                        onPressed: (index) {
                          setState(() {
                            isExistingCategory = index == 0;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('기존 카테고리'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('새 카테고리'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      isExistingCategory
                          ? DropdownButtonFormField<String>(
                              value: null,
                              onChanged: (String? newValue) {},
                              items: <String>[
                                'Category 1',
                                'Category 2',
                                'Category 3'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              decoration: const InputDecoration(
                                labelText: '기존 카테고리',
                                border: OutlineInputBorder(),
                              ),
                            )
                          : const TextField(
                              decoration: InputDecoration(
                                labelText: '새 카테고리 이름',
                                border: OutlineInputBorder(),
                              ),
                            ),
                      const SizedBox(height: 20),
                      const TextField(
                        // 질문 이름 입력 칸
                        decoration: InputDecoration(
                          labelText: '질문 이름',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const TextField(
                        // 메모할 내용 입력 칸
                        maxLines: 3, // 메모 필드를 여러 줄 입력 가능하게 설정
                        decoration: InputDecoration(
                          labelText: '메모할 내용',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text('저장'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
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
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Q$index: 질문 내용",
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
                              index], // 각 페이지마다 별도의 ScrollController 사용
                          thumbVisibility: true,
                          child: ListView.builder(
                            controller: scrollControllers[index],
                            itemCount: 1,
                            itemBuilder: (context, _) => Text(
                              "긴 답변 내용 $index ..." * 200,
                              style: const TextStyle(fontSize: 14),
                            ),
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
              count: 5,
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
      title: Image.asset('assets/images/NoteLens.png', width: 40, height: 40),
      actions: [
        InkWell(
          onTap: _showCategoryDialog, // 저장 버튼 클릭 이벤트를 _showCategoryDialog로 설정
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: const Icon(Icons.save, size: 30, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

void main() => runApp(MaterialApp(home: QuestionAnswerView()));
