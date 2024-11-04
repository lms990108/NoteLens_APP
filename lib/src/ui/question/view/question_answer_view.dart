import 'package:flutter/material.dart';
import 'package:notelens_app/src/ui/category/view/category_list_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:ui'; // 블러 효과를 위해 필요
import 'package:notelens_app/src/data/model/category.dart';
import 'package:notelens_app/src/data/model/qna.dart';
import 'package:notelens_app/src/data/repository/category_repository.dart';
import 'package:notelens_app/src/data/repository/qna_repository.dart';

class QuestionAnswerView extends StatefulWidget {
  final List<String> questions; // 질문 리스트
  final List<String> answers; // 답변 리스트

  const QuestionAnswerView({
    super.key,
    required this.questions,
    required this.answers,
  });

  @override
  _QuestionAnswerViewState createState() => _QuestionAnswerViewState();
}

class _QuestionAnswerViewState extends State<QuestionAnswerView> {
  bool isExistingCategory = true;
  final PageController pageController =
      PageController(viewportFraction: 1, keepPage: true);

  final CategoryRepository _categoryRepository = CategoryRepository();
  final QnARepository _qnaRepository = QnARepository(); // QnA 레포지토리 인스턴스

  List<Category> categories = [];
  String? selectedCategory;
  String? memo;

  late List<ScrollController> scrollControllers;

  @override
  void initState() {
    super.initState();
    scrollControllers =
        List.generate(widget.answers.length, (index) => ScrollController());

    _loadCategories();
  }

  @override
  void dispose() {
    for (var controller in scrollControllers) {
      controller.dispose();
    }
    pageController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final loadedCategories = await _categoryRepository.getAllCategories();
      print('Loaded Categories: ${loadedCategories.map((e) => e.title)}');

      setState(() {
        categories = loadedCategories;
      });
    } catch (e) {
      print("Failed to load categories: $e");
    }
  }

  void _saveQnA(int index) async {
    if (selectedCategory == null) {
      print("카테고리를 선택해주세요.");
      return;
    }

    // 선택된 카테고리의 ID 가져오기
    final category =
        categories.firstWhere((cat) => cat.title == selectedCategory);

    // QnA 객체 생성
    final qna = QnA(
      title: "QnA ${index + 1}",
      qContent: widget.questions[index],
      aContent: widget.answers[index],
      memo: memo,
      createdAt: DateTime.now(),
      isDeleted: false,
      categoryId: category.id!,
    );

    try {
      await _qnaRepository.createQnA(qna);
      print("QnA 저장 성공: ${qna.title}");
      Navigator.of(context).pop();
    } catch (e) {
      print("QnA 저장 실패: $e");
    }
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
              itemCount: widget.answers.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "질문: ${widget.questions[index]}",
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
                          controller: scrollControllers[index],
                          thumbVisibility: true,
                          child: ListView(
                            controller: scrollControllers[index],
                            children: [
                              Text(
                                widget.answers[index],
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
              count: widget.answers.length,
              effect: const WormEffect(
                dotWidth: 25,
                dotHeight: 25,
                spacing: 8,
                activeDotColor: Colors.green,
              ),
              onDotClicked: (index) => pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
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
          onTap: _showCategoryDialog,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: const Icon(Icons.save, size: 30, color: Colors.black),
          ),
        ),
      ],
    );
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            String? newCategoryName;
            bool isLoading = categories.isEmpty;

            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                          '카테고리 선택',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
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
                            ? isLoading
                                ? const CircularProgressIndicator()
                                : DropdownButtonFormField<String>(
                                    value: selectedCategory,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedCategory = newValue;
                                      });
                                    },
                                    items: categories.map((category) {
                                      return DropdownMenuItem<String>(
                                        value: category.title,
                                        child: Row(
                                          children: [
                                            const Icon(Icons.folder,
                                                color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Text(category.title),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    decoration: const InputDecoration(
                                      labelText: '기존 카테고리',
                                      border: OutlineInputBorder(),
                                    ),
                                  )
                            : Column(
                                children: [
                                  TextField(
                                    onChanged: (value) {
                                      newCategoryName = value;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: '새 카테고리 이름',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    onChanged: (value) {
                                      memo = value;
                                    },
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      labelText: '메모할 내용',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (!isExistingCategory &&
                                (newCategoryName?.isNotEmpty ?? false)) {
                              // 새 카테고리 생성 로직 추가
                              final newCategory = Category(
                                id: null, // ID는 DB에서 자동 생성되도록 null로 설정
                                title: newCategoryName!,
                                description: memo,
                                createdAt: DateTime.now(),
                                isDeleted: false,
                              );

                              try {
                                final savedCategory = await _categoryRepository
                                    .createCategory(newCategory);
                                setState(() {
                                  categories.add(savedCategory);
                                  selectedCategory = savedCategory.title;
                                });
                                print("새 카테고리 저장 성공: ${savedCategory.title}");
                              } catch (e) {
                                print("새 카테고리 저장 실패: $e");
                              }
                            }

                            final currentIndex =
                                pageController.page?.round() ?? 0;
                            _saveQnA(currentIndex);
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CategoryListView()));
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
          },
        );
      },
    );
  }
}
