import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notelens_app/src/data/model/category.dart';
import 'package:notelens_app/src/ui/category/view_model/category_list_view_model.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'create_category_view.dart';
import 'update_category_view.dart';
import 'how_to_use_view.dart';
import 'dart:convert'; // JSON 파싱을 위한 라이브러리

// 카테고리 리스트 뷰 위젯
class CategoryListView extends StatefulWidget {
  const CategoryListView({super.key});

  @override
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
    final categoryListViewModel = Provider.of<CategoryListViewModel>(context);

    return Scaffold(
      appBar: _myAppBar(categoryListViewModel),
      body: Stack(
        children: [
          _buildCategoryList(context, categoryListViewModel),
          if (_isLeftBlurred || _isRightBlurred) _buildBlurredOverlay(),
          if (_isLeftBlurred) _buildBlurredLeftIcons(context),
          if (_isRightBlurred) _buildBlurredRightIcons(),
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
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 1,
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
                Navigator.of(context).pop();
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
          _isLeftBlurred = false;
          _isRightBlurred = false;
        });
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          color: Colors.black.withOpacity(0),
        ),
      ),
    );
  }

  Widget _buildBlurredLeftIcons(BuildContext context) {
    return Positioned(
      bottom: 15,
      left: 15,
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HowToUseView(),
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

  Widget _buildBlurredRightIcons() {
    return Positioned(
      bottom: 15,
      right: 15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 파일 선택 버튼
          GestureDetector(
            onTap: () {
              _showFileOrImagePicker(); // 파일 또는 이미지 선택 옵션 제공
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

  // 파일 또는 이미지 선택을 위한 옵션 제공
  void _showFileOrImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('파일 선택하기'),
              onTap: () {
                Navigator.of(context).pop(); // BottomSheet 닫기
                _pickFile(); // 파일 선택 기능 호출
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('이미지 선택하기'),
              onTap: () {
                Navigator.of(context).pop(); // BottomSheet 닫기
                _pickImage(ImageSource.gallery); // 갤러리에서 이미지 선택
              },
            ),
          ],
        );
      },
    );
  }

  // 이미지 촬영 또는 갤러리에서 선택을 위한 메서드
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        // API 요청 전송
        await _uploadFileToServer(imageFile);
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('An error occurred while picking an image: $e');
      _showErrorDialog(context, 'An error occurred while picking an image.');
    }
  }

  // 파일 선택을 위한 메서드 (모든 파일 형식)
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // 모든 파일 형식 허용
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        // API 요청 전송
        await _uploadFileToServer(file);
      } else {
        print('No file selected.');
      }
    } catch (e) {
      print('An error occurred while picking a file: $e');
      _showErrorDialog(context, 'An error occurred while picking a file.');
    }
  }

// 서버로 이미지를 업로드하는 메서드
  Future<void> _uploadFileToServer(File file) async {
    final String apiUrl =
        'http://13.124.185.96:8001/api/yolo/yolo'; // API 엔드포인트 주소

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // 파일을 멀티파트 요청에 추가
      request.files.add(await http.MultipartFile.fromPath(
        'file', // 서버에서 기대하는 파일 필드 이름
        file.path,
      ));

      var response = await request.send();

      // 응답 본문을 받아서 JSON 파싱
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // 서버에서 전송한 JSON을 파싱
        var jsonResponse = jsonDecode(responseBody);
        print('File uploaded successfully');
        print('Server Response: $jsonResponse'); // 서버의 JSON 응답 출력
      } else {
        print('Failed to upload file: ${response.statusCode}');
        print('Response: $responseBody'); // 에러 발생 시 서버 응답 출력
      }
    } catch (e) {
      print('An error occurred during the upload: $e');
      _showErrorDialog(context, 'An error occurred during the upload.');
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
                _isLeftBlurred = !_isLeftBlurred;
                if (_isRightBlurred) _isRightBlurred = false;
              });
            },
            child: Icon(
              Icons.help_outline_rounded,
              color: _isLeftBlurred
                  ? Colors.black
                  : const Color.fromARGB(255, 203, 203, 203),
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
                _isRightBlurred = !_isRightBlurred;
                if (_isLeftBlurred) _isLeftBlurred = false;
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
