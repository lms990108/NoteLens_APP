import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notelens_app/src/data/model/category.dart';
import 'package:notelens_app/src/ui/category/view/create_category_view.dart';
import 'package:notelens_app/src/ui/category/view/how_to_use_view.dart';
import 'package:notelens_app/src/ui/category/view_model/category_list_view_model.dart';
import 'package:notelens_app/src/ui/question/view/question_answer_view.dart';
import 'package:notelens_app/src/ui/question/view/question_list_view.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../question/view/question_extract_view.dart';

class CategoryListView extends StatefulWidget {
  const CategoryListView({super.key});

  @override
  _CategoryListViewState createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView> {
  bool _isLeftBlurred = false;
  bool _isRightBlurred = false;
  File? selectedFile; // 선택된 파일을 저장할 변수

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
        onTap: () {}, // 정렬 아이콘 클릭 시 수행할 동작
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
          onTap: () {}, // 설정 아이콘 클릭 시 수행할 동작
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
                // 카테고리 수정 화면으로 이동
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        // 로딩 화면으로 이동
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const QuestionExtractView(),
        ));

        // API 요청 전송 및 응답 처리
        final response = await _uploadFileToServer(imageFile);

        if (response != null) {
          print("Server Response: $response");

          // 새로운 응답 포맷에서 데이터를 파싱
          final data = response['underlined_text'] ?? {};

          List<String> questions = [];
          List<String> contents = [];

          data.forEach((key, value) {
            questions.add(key); // 파일명 추가
            contents.add(value); // 설명 추가
          });

          // 응답을 받은 후 QuestionListView로 이동하며 데이터 전달
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => QuestionListView(
              questions: questions, // 파일명 리스트
              contents: contents, // 설명 리스트
            ),
          ));
        } else {
          print('Failed to get response from server.');
        }
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('An error occurred while picking an image: $e');
      _showErrorDialog(context, 'An error occurred while picking an image.');
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        // QuestionExtractView로 이동하여 로딩 화면 표시
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const QuestionExtractView(),
        ));

        // API 요청 전송 및 응답 처리
        final response = await _uploadFileToServer(file);

        if (response != null) {
          // 서버 응답 출력
          print("Server Response: $response");

          // 서버 응답에서 파일명(key)과 설명(value)을 각각 questions와 contents에 매핑
          List<String> questions = [];
          List<String> contents = [];

          response.forEach((key, value) {
            questions.add(key); // 파일명을 questions에 추가
            contents.add(value); // 설명을 contents에 추가
          });

          // 응답을 받은 후 QuestionListView로 이동하며 데이터 전달
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => QuestionListView(
              questions: questions, // 파일명 리스트
              contents: contents, // 설명 리스트
            ),
          ));
        } else {
          print('Failed to get response from server.');
        }
      } else {
        print('No file selected.');
      }
    } catch (e) {
      print('An error occurred while picking a file: $e');
      _showErrorDialog(context, 'An error occurred while picking a file.');
    }
  }

  Future<Map<String, dynamic>?> _uploadFileToServer(File file) async {
    final String apiUrl =
        'http://13.124.185.96:8001/api/yolo/yolo'; // API 엔드포인트 주소

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.files.add(await http.MultipartFile.fromPath(
        'file', // 서버에서 기대하는 파일 필드 이름
        file.path,
      ));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        print('Failed to upload file: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('An error occurred during the upload: $e');
      return null;
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
            onTap: () async {
              if (selectedFile != null) {
                final response = await _uploadFileToServer(selectedFile!);

                if (response != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => QuestionListView(
                        questions: response['questions'],
                        contents: response['contents'],
                      ),
                    ),
                  );
                } else {
                  _showErrorDialog(
                      context, 'Failed to get response from server.');
                }
              } else {
                _showErrorDialog(context, 'No file selected.');
              }
            },
            child: const Icon(
              Icons.one_k,
              size: 40,
            ),
          ),
          GestureDetector(
            onTap: () {
              // 임시 질문과 답변 데이터 생성
              List<String> tempQuestions = ["질문 1", "질문 2", "질문 3"];
              List<String> tempAnswers = ["임시 답변 1", "임시 답변 2", "임시 답변 3"];

              // 임시 질문과 답변을 QuestionAnswerView로 전달
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QuestionAnswerView(
                    questions: tempQuestions, // 임시 질문 리스트
                    answers: tempAnswers, // 임시 답변 리스트
                  ),
                ),
              );
            },
            child: const Icon(
              Icons.two_k,
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
