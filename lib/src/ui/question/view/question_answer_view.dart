import 'package:flutter/material.dart';
import 'package:notelens_app/src/ui/category/view/category_list_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:ui';
import 'package:notelens_app/src/data/model/category.dart';
import 'package:notelens_app/src/data/model/qna.dart';
import 'package:notelens_app/src/data/repository/category_repository.dart';
import 'package:notelens_app/src/data/repository/qna_repository.dart';
import '../../custom/custom_appbar.dart';

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

  void _showSaveOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('저장 옵션'),
          content: const Text('저장 후 계속할지, 메인으로 돌아갈지 선택하세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: const Text('저장 취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: const Text('계속 저장하기'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const CategoryListView(),
                ));
              },
              child: const Text('저장하고 나가기'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        actions: [
          InkWell(
            onTap: _showCategoryDialog,
            child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.save, size: 30, color: Colors.black)),
          )
        ],
      ),
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
                    const Text(
                      "Question",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Text(
                      widget.questions[index],
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
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

  void _showCategoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            String? newCategoryName;

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
                            isSelected: [
                              isExistingCategory,
                              !isExistingCategory
                            ],
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
                                  value: selectedCategory,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedCategory = newValue;
                                    });
                                  },
                                  items: categories.isEmpty
                                      ? [
                                          const DropdownMenuItem(
                                            value: null,
                                            child: Text(
                                              "카테고리가 없습니다",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                        ]
                                      : categories.map((category) {
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
                              final currentIndex =
                                  pageController.page?.round() ?? 0;

                              if (isExistingCategory) {
                                if (selectedCategory == null ||
                                    selectedCategory!.isEmpty) {
                                  _showOverlayMessage(context, '카테고리를 선택해주세요.');
                                  return; // 카테고리가 선택되지 않았으면 저장하지 않음
                                }
                                // 기존 카테고리에 저장
                                _saveExistingCategory(currentIndex);
                              } else if (!isExistingCategory &&
                                  (newCategoryName?.isNotEmpty ?? false)) {
                                // 새 카테고리 저장
                                await _saveNewCategory(
                                    newCategoryName!, currentIndex);
                              } else {
                                _showOverlayMessage(
                                    context, '새 카테고리 이름을 입력해주세요.');
                                return; // 새 카테고리 이름이 비어 있으면 저장하지 않음
                              }

                              // 저장 후 옵션 다이얼로그 표시
                              _showSaveOptionsDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                            child: const Text('저장'),
                          ),
                        ],
                      )),
                    )));
          },
        );
      },
    );
  }

  void _saveExistingCategory(int index) async {
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      print("카테고리를 선택해주세요."); // 디버그 로그
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리를 선택해주세요.')),
      );
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
      print("기존 카테고리에 QnA 저장 성공: ${qna.title}");
    } catch (e) {
      print("기존 카테고리에 QnA 저장 실패: $e");
    }
  }

  Future<void> _saveNewCategory(String newCategoryName, int index) async {
    if (newCategoryName.isEmpty) {
      print("새 카테고리 이름을 입력해주세요.");
      return;
    }

    // 새 카테고리 객체 생성
    final newCategory = Category(
      id: null, // ID는 DB에서 자동 생성되도록 null로 설정
      title: newCategoryName,
      description: memo,
      createdAt: DateTime.now(),
      isDeleted: false,
    );

    try {
      final savedCategory =
          await _categoryRepository.createCategory(newCategory);
      setState(() {
        categories.add(savedCategory);
        selectedCategory = savedCategory.title; // 새 카테고리를 자동 선택
      });
      print("새 카테고리 저장 성공: ${savedCategory.title}");
    } catch (e) {
      print("새 카테고리 저장 실패: $e");
      return;
    }

    // 저장 후 QnA 생성
    _saveExistingCategory(index);
  }

  void _showOverlayMessage(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.1,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
