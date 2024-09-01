import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:notelens_app/src/data/model/category.dart';
import 'package:provider/provider.dart';
import 'package:notelens_app/src/ui/category/view_model/category_list_view_model.dart';
import 'create_category_view.dart';
import 'update_category_view.dart';

class CategoryListView extends StatefulWidget {
  const CategoryListView({super.key});

  @override
  _CategoryListViewState createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView> {
  bool _isLeftBlurred = false; // 왼쪽 블러 상태를 관리하는 변수
  bool _isRightBlurred = false; // 오른쪽 블러 상태를 관리하는 변수

  @override
  Widget build(BuildContext context) {
    final categoryListViewModel = Provider.of<CategoryListViewModel>(context);

    return Scaffold(
      appBar: _myAppBar(categoryListViewModel),
      body: Stack(
        children: [
          _buildCategoryList(context, categoryListViewModel), // 기본 콘텐츠
          if (_isLeftBlurred || _isRightBlurred)
            _buildBlurredOverlay(), // 블러 효과 및 터치 감지
          if (_isLeftBlurred) _buildBlurredLeftIcons(), // 왼쪽 블러 상태에서 나타나는 아이콘들
          if (_isRightBlurred)
            _buildBlurredRightIcons(), // 오른쪽 블러 상태에서 나타나는 아이콘들
        ],
      ),
      bottomNavigationBar: _myBottomBar(context, categoryListViewModel),
    );
  }

  PreferredSizeWidget _myAppBar(CategoryListViewModel viewModel) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 206, 206, 206),
      leading: InkWell(
        child: const Icon(
          Icons.sort,
          size: 30,
        ),
        onTap: () {},
      ),
      title: Image.asset('assets/images/NoteLens.png', width: 40, height: 40),
      actions: [
        InkWell(
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: const Icon(
              Icons.settings,
              size: 30,
            ),
          ),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildCategoryList(
      BuildContext context, CategoryListViewModel viewModel) {
    final activeCategories = viewModel.categories
        .where((category) => category.isDeleted == false)
        .toList();

    return FutureBuilder(
      future: viewModel.fetchCategories(),
      builder: (context, snapshot) {
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(12, 20, 0, 3),
                alignment: Alignment.bottomLeft,
                child: const Text("Category"),
              ),
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.black,
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 한 줄에 두 개의 카테고리를 표시
                    crossAxisSpacing: 10.0, // 열 간 간격
                    mainAxisSpacing: 10.0, // 행 간 간격
                    childAspectRatio: 1, // 폴더 아이콘의 가로 세로 비율
                  ),
                  itemCount: activeCategories.length,
                  itemBuilder: (context, index) {
                    final category = activeCategories[index];
                    return GestureDetector(
                      onLongPress: () {
                        _showCategoryOptions(context, viewModel, category);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.folder_rounded,
                            size: 64,
                            color: Colors.black54,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.title,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryOptions(BuildContext context,
      CategoryListViewModel viewModel, Category category) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('수정'),
              onTap: () {
                Navigator.of(context).pop(); // 메뉴 닫기
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        UpdateCategoryView(categoryId: category.id!),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('삭제'),
              onTap: () {
                Navigator.of(context).pop(); // 메뉴 닫기
                _showDeleteConfirmationDialog(context, viewModel, category.id!);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, CategoryListViewModel viewModel, int categoryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('카테고리 삭제'),
          content: const Text('선택한 카테고리를 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () {
                viewModel.deleteCategory(categoryId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBlurredOverlay() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isLeftBlurred = false; // 왼쪽 블러 상태 초기화
          _isRightBlurred = false; // 오른쪽 블러 상태 초기화
        });
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // 블러 효과 적용
        child: Container(
          color: Colors.black.withOpacity(0), // 블러 처리된 부분의 배경색 (투명하게 유지)
        ),
      ),
    );
  }

  Widget _buildBlurredLeftIcons() {
    return const Positioned(
      bottom: 15,
      left: 15, // 좌측에 배치
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.send, size: 30),
              SizedBox(width: 8),
              Text('Report / Feedback'),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.book, size: 30),
              SizedBox(width: 8),
              Text('How to use'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredRightIcons() {
    return const Positioned(
      bottom: 15,
      right: 15, // 우측에 배치
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Text('Select file'),
              SizedBox(width: 8),
              Icon(Icons.file_open, size: 30),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Text('Take a picture'),
              SizedBox(width: 8),
              Icon(Icons.camera_alt, size: 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _myBottomBar(BuildContext context, CategoryListViewModel viewModel) {
    return BottomAppBar(
      height: 50,
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isLeftBlurred = !_isLeftBlurred; // 왼쪽 블러 상태를 토글
                if (_isRightBlurred) _isRightBlurred = false; // 오른쪽 블러 상태를 끔
              });
            },
            child: Icon(
              Icons.help_outline_rounded,
              color: _isLeftBlurred
                  ? Colors.black
                  : const Color.fromARGB(255, 203, 203, 203), // 조건부 색상 변경
              size: 40,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateCategoryView(),
                ),
              );
            },
            child: const Icon(
              Icons.add,
              size: 40,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isRightBlurred = !_isRightBlurred; // 오른쪽 블러 상태를 토글
                if (_isLeftBlurred) _isLeftBlurred = false; // 왼쪽 블러 상태를 끔
              });
            },
            child: Icon(
              Icons.add_circle_outline_rounded,
              color: _isRightBlurred
                  ? Colors.black
                  : const Color.fromARGB(255, 203, 203, 203),
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}
