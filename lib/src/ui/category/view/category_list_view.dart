import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:notelens_app/src/data/model/category.dart';
import 'package:provider/provider.dart';
import 'package:notelens_app/src/ui/category/view_model/category_list_view_model.dart';
import 'create_category_view.dart';
import 'update_category_view.dart';
import 'package:image_picker/image_picker.dart';
import 'how_to_use_view.dart';
import '../../question/question_list_view.dart';

// 카테고리 리스트 뷰 위젯
class CategoryListView extends StatefulWidget {
  const CategoryListView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CategoryListViewState createState() => _CategoryListViewState();
}

// 카테고리 리스트 뷰의 상태 관리 클래스
class _CategoryListViewState extends State<CategoryListView> {
  // 왼쪽 블러 상태를 관리하는 변수
  bool _isLeftBlurred = false;
  // 오른쪽 블러 상태를 관리하는 변수
  bool _isRightBlurred = false;

  @override
  Widget build(BuildContext context) {
    // 카테고리 리스트의 뷰모델을 가져옴
    final categoryListViewModel = Provider.of<CategoryListViewModel>(context);

    return Scaffold(
      appBar: _myAppBar(categoryListViewModel),
      body: Stack(
        children: [
          _buildCategoryList(context, categoryListViewModel), // 카테고리 리스트를 빌드
          if (_isLeftBlurred || _isRightBlurred)
            _buildBlurredOverlay(), // 블러 효과 및 터치 감지
          if (_isLeftBlurred)
            _buildBlurredLeftIcons(context), // 왼쪽 블러 상태에서 나타나는 아이콘들
          if (_isRightBlurred)
            _buildBlurredRightIcons(), // 오른쪽 블러 상태에서 나타나는 아이콘들
        ],
      ),
      bottomNavigationBar: _myBottomBar(context, categoryListViewModel),
    );
  }

  // 앱 바를 생성하는 메서드
  PreferredSizeWidget _myAppBar(CategoryListViewModel viewModel) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 206, 206, 206),
      leading: InkWell(
        child: const Icon(
          Icons.sort,
          size: 30,
        ),
        onTap: () {}, // 정렬 아이콘 클릭 시 수행할 동작 (현재 비어 있음)
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
          onTap: () {}, // 설정 아이콘 클릭 시 수행할 동작 (현재 비어 있음)
        ),
      ],
    );
  }

  // 카테고리 리스트를 생성하는 위젯
  Widget _buildCategoryList(
      BuildContext context, CategoryListViewModel viewModel) {
    // 삭제되지 않은 카테고리만 필터링
    final activeCategories = viewModel.categories
        .where((category) => category.isDeleted == false)
        .toList();

    return FutureBuilder(
      future: viewModel.fetchCategories(), // 카테고리 데이터를 비동기적으로 가져옴
      builder: (context, snapshot) {
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              // 카테고리 헤더
              Container(
                margin: const EdgeInsets.fromLTRB(12, 20, 0, 3),
                alignment: Alignment.bottomLeft,
                child: const Text("Category"),
              ),
              // 구분선
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.black,
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              ),
              // 카테고리 리스트
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
            // 취소 버튼
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // 확인 버튼
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

  // 블러 효과와 터치 감지를 위한 오버레이 위젯
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

  // 왼쪽 블러 상태에서 나타나는 아이콘들을 표시하는 위젯
  Widget _buildBlurredLeftIcons(BuildContext context) {
    return Positioned(
      bottom: 15,
      left: 15, // 좌측에 배치
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.send, size: 30),
              SizedBox(width: 8),
              Text('Report / Feedback'),
            ],
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              // 'How to use' 화면으로 이동하는 코드
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const HowToUseView(), // 'How to use' 화면으로 이동
                ),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.book, size: 30),
                SizedBox(width: 8),
                Text('How to use'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 오른쪽 블러 상태에서 나타나는 아이콘들을 표시하는 위젯
  Widget _buildBlurredRightIcons() {
    return Positioned(
      bottom: 15,
      right: 15, // 우측에 배치
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 파일 선택 버튼
          GestureDetector(
            onTap: () {
              _pickImage(ImageSource.gallery); // 갤러리에서 이미지 선택 기능 호출
            },
            child: const Row(
              children: [
                Text('Select file'),
                SizedBox(width: 8),
                Icon(Icons.file_open, size: 30),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // 사진 촬영 버튼
          GestureDetector(
            onTap: () {
              _pickImage(ImageSource.camera); // 카메라로 사진 촬영 기능 호출
            },
            child: const Row(
              children: [
                Text('Take a picture'),
                SizedBox(width: 8),
                Icon(Icons.camera_alt, size: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 이미지 선택 또는 촬영을 위한 메서드
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      // TODO : Notelens 서버 API 호출로직 필요
      if (pickedFile != null) {
        // 선택된 이미지를 처리하는 로직 추가 (예: 이미지 표시, 업로드 등)
        print('Selected image path: ${pickedFile.path}');
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('An error occurred while picking an image: $e');
      // ignore: use_build_context_synchronously
      _showErrorDialog(context, 'An error occurred while picking an image.');
    }
  }

  // 에러 발생 시 에러 메시지를 표시하는 다이얼로그 메서드
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            // 확인 버튼
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

  // 하단 바를 생성하는 위젯
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
          // 새 카테고리 추가 버튼
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QuestionListView(),
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
