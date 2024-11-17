import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notelens_app/src/ui/qna/multi_file_question_list_view.dart';
import '../view_model/category_list_view_model.dart';
import '../../question/view/question_extract_view.dart';

class BlurredRightIcons extends StatefulWidget {
  final CategoryListViewModel viewModel;

  const BlurredRightIcons({super.key, required this.viewModel});

  @override
  _BlurredRightIconsState createState() => _BlurredRightIconsState();
}

class _BlurredRightIconsState extends State<BlurredRightIcons> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        List<File> imageFiles =
            pickedFiles.map((xfile) => File(xfile.path)).toList();

        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const QuestionExtractView(),
        ));

        // 여러 파일의 응답을 저장할 리스트
        List<Map<String, dynamic>> allFileResponses = [];

        // 각 파일에 대해 서버 요청
        for (var file in imageFiles) {
          final response = await widget.viewModel.uploadFileToServer(file);

          if (response != null) {
            final questions =
                List<String>.from(response['underlined_text']?.keys ?? []);
            final contents =
                List<String>.from(response['underlined_text']?.values ?? []);
            final originalContent = response['original_content'] ?? '';

            allFileResponses.add({
              "questions": questions,
              "contents": contents,
              "originalContent": originalContent,
              "isChecked":
                  List<bool>.filled(questions.length, false), // 초기 체크 상태
            });
          } else {
            _showErrorDialog(
                'Failed to get response from server for one of the files.');
          }
        }

        // 파일별 데이터를 MultiFileQuestionListView에 전달
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MultiFileQuestionListView(
            fileResponses: allFileResponses,
          ),
        ));
      } else {
        _showErrorDialog('No images selected.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while picking images.');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        // 로딩 화면으로 이동
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const QuestionExtractView(),
        ));

        // API 요청 전송 및 응답 처리
        final response = await widget.viewModel.uploadFileToServer(imageFile);

        if (response != null) {
          final questions =
              List<String>.from(response['underlined_text']?.keys ?? []);
          final contents =
              List<String>.from(response['underlined_text']?.values ?? []);
          final originalContent = response['original_content'] ?? '';

          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => MultiFileQuestionListView(
              fileResponses: [
                {
                  "questions": questions,
                  "contents": contents,
                  "originalContent": originalContent,
                  "isChecked": List<bool>.filled(questions.length, false),
                }
              ],
            ),
          ));
        } else {
          _showErrorDialog('Failed to get response from server.');
        }
      } else {
        _showErrorDialog('No image selected.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while picking an image.');
    }
  }

  // TODO: 파일 확장자 변경작업 해야함
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        // 로딩 화면으로 이동
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const QuestionExtractView(),
        ));

        // API 요청 전송 및 응답 처리
        final response = await widget.viewModel.uploadFileToServer(file);

        if (response != null) {
          final questions =
              List<String>.from(response['underlined_text']?.keys ?? []);
          final contents =
              List<String>.from(response['underlined_text']?.values ?? []);
          final originalContent = response['original_content'] ?? '';

          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => MultiFileQuestionListView(
              fileResponses: [
                {
                  "questions": questions,
                  "contents": contents,
                  "originalContent": originalContent,
                  "isChecked": List<bool>.filled(questions.length, false),
                }
              ],
            ),
          ));
        } else {
          _showErrorDialog('Failed to get response from server.');
        }
      } else {
        _showErrorDialog('No file selected.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while picking a file.');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showFileOrImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('파일 선택하기'),
              onTap: () {
                Navigator.of(context).pop();
                _pickFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('이미지 선택하기'),
              onTap: () {
                Navigator.of(context).pop();
                _pickMultipleImages(); // 다중 이미지 선택 기능 사용
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 15,
      right: 15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              _showFileOrImagePicker(context);
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
              _pickImage(ImageSource.camera);
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
}
