import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../view_model/category_list_view_model.dart';
import '../../question/view/question_extract_view.dart';
import '../../question/view/question_list_view.dart';

class BlurredRightIcons extends StatefulWidget {
  final CategoryListViewModel viewModel;

  const BlurredRightIcons({Key? key, required this.viewModel})
      : super(key: key);

  @override
  _BlurredRightIconsState createState() => _BlurredRightIconsState();
}

class _BlurredRightIconsState extends State<BlurredRightIcons> {
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
        final response = await widget.viewModel.uploadFileToServer(imageFile);

        if (response != null) {
          final originalContent = response['original_content'] ?? '';
          final data = response['underlined_text'] ?? {};

          List<String> questions = [];
          List<String> contents = [];

          data.forEach((key, value) {
            questions.add(key);
            contents.add(value);
          });

          // 응답을 받은 후 QuestionListView로 이동하며 데이터 전달
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => QuestionListView(
              questions: questions,
              contents: contents,
              originalContent: originalContent,
            ),
          ));
        } else {
          print('Failed to get response from server.');
          _showErrorDialog('Failed to get response from server.');
        }
      } else {
        print('No image selected.');
        _showErrorDialog('No image selected.');
      }
    } catch (e) {
      print('An error occurred while picking an image: $e');
      _showErrorDialog('An error occurred while picking an image.');
    }
  }

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
          final originalContent = response['original_content'] ?? '';
          final data = response['underlined_text'] ?? {};

          List<String> questions = [];
          List<String> contents = [];

          data.forEach((key, value) {
            questions.add(key);
            contents.add(value);
          });

          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => QuestionListView(
              questions: questions,
              contents: contents,
              originalContent: originalContent,
            ),
          ));
        } else {
          print('Failed to get response from server.');
          _showErrorDialog('Failed to get response from server.');
        }
      } else {
        print('No file selected.');
        _showErrorDialog('No file selected.');
      }
    } catch (e) {
      print('An error occurred while picking a file: $e');
      _showErrorDialog('An error occurred while picking a file.');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return; // 위젯이 dispose된 경우 반환

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
                Navigator.of(context).pop();
                _pickFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('이미지 선택하기'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
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
            onTap: _showFileOrImagePicker,
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
