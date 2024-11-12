import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../view_model/category_list_view_model.dart';
import '../../question/view/question_extract_view.dart';
import '../../question/view/question_list_view.dart';

Widget buildBlurredRightIcons(
    BuildContext context, CategoryListViewModel viewModel) {
  return Positioned(
    bottom: 15,
    right: 15,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            _showFileOrImagePicker(context, viewModel); // 파일 또는 이미지 선택 옵션 제공
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
            _pickImage(
                context, ImageSource.camera, viewModel); // 카메라로 사진 촬영 기능 호출
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

void _showFileOrImagePicker(
    BuildContext context, CategoryListViewModel viewModel) {
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
              _pickFile(context, viewModel); // 파일 선택 기능 호출
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('이미지 선택하기'),
            onTap: () {
              Navigator.of(context).pop(); // BottomSheet 닫기
              _pickImage(
                  context, ImageSource.gallery, viewModel); // 갤러리에서 이미지 선택
            },
          ),
        ],
      );
    },
  );
}

Future<void> _pickImage(BuildContext context, ImageSource source,
    CategoryListViewModel viewModel) async {
  // 현재 테스트시 사용하는 파일입력방식
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
      final response = await viewModel.uploadFileToServer(imageFile);

      if (response != null) {
        // print("Server Response: $response");

        // 새로운 응답 포맷에서 데이터를 파싱
        final originalContent = response['original_content'] ?? '';
        final data = response['underlined_text'] ?? {};

        // print("original 파일파일 : $original_content");

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
            originalContent: originalContent, // original_content 전달
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

Future<void> _pickFile(
    BuildContext context, CategoryListViewModel viewModel) async {
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
      final response = await viewModel.uploadFileToServer(file);

      if (response != null) {
        // 서버 응답 출력
        print("Server Response: $response");

        // 새로운 응답 포맷에서 데이터를 파싱
        final originalContent = response['original_content'] ?? '';
        final data = response['underlined_text'] ?? {};

        print("original 여기서 진행: $originalContent");

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
            originalContent: originalContent, // original_content 전달
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
