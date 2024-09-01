import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notelens_app/src/ui/category/view_model/category_list_view_model.dart';
import 'create_category_view.dart';
import 'update_category_view.dart';
import 'package:image_picker/image_picker.dart';

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
                child: ListView.builder(
                  itemCount: activeCategories.length,
                  itemBuilder: (context, index) {
                    final category = activeCategories[index];
                    return ListTile(
                      title: Text(category.title),
                      subtitle: Text(category.description ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => UpdateCategoryView(
                                      categoryId: category.id!),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _showDeleteConfirmationDialog(
                                  context, viewModel, category.id!);
                            },
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

  void _showDeleteConfirmationDialog(
      BuildContext context, CategoryListViewModel viewModel, int categoryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('이 카테고리를 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                viewModel.deleteCategory(categoryId); // 카테고리 삭제
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('확인'),
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
    return Positioned(
      bottom: 15,
      right: 15, // 우측에 배치
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              _pickImage(ImageSource.gallery); // 갤러리에서 이미지 선택 기능 호출
            },
            child: Row(
              children: [
                const Text('Select file'),
                const SizedBox(width: 8),
                const Icon(Icons.file_open, size: 30),
              ],
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              _pickImage(ImageSource.camera); // 카메라로 사진 촬영 기능 호출
            },
            child: Row(
              children: [
                const Text('Take a picture'),
                const SizedBox(width: 8),
                const Icon(Icons.camera_alt, size: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 이미지 선택 또는 촬영을 위한 메서드 추가
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker _picker = ImagePicker();
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        // 선택된 이미지를 처리하는 로직 추가 (예: 이미지 표시, 업로드 등)
        print('Selected image path: ${pickedFile.path}');
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('An error occurred while picking an image: $e');
      _showErrorDialog(context, 'An error occurred while picking an image.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
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
