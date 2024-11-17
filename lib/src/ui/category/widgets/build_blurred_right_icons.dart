import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notelens_app/src/ui/qna/multi_file_question_list_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
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

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'], // 허용 확장자
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        // 파일 확장자 확인
        final extension = file.path.split('.').last.toLowerCase();
        if (extension == 'pdf') {
          // PDF를 이미지로 변환
          List<File> convertedImages = await _convertPdfToImages(file);

          if (convertedImages.isNotEmpty) {
            // 변환된 이미지 처리
            _handleConvertedImages(convertedImages);
          } else {
            _showErrorDialog('No images could be extracted from the PDF.');
          }
        } else if (['jpg', 'jpeg', 'png'].contains(extension)) {
          // 이미지 파일인 경우 기존 `_pickImage` 로직과 동일
          _pickImage(ImageSource.gallery);
        } else {
          _showErrorDialog('Unsupported file type selected.');
        }
      } else {
        _showErrorDialog('No file selected.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while picking a file.');
    }
  }

  Future<List<File>> _convertPdfToImages(File pdfFile) async {
    try {
      final document = await PdfDocument.openFile(pdfFile.path);
      List<File> imageFiles = [];

      for (int i = 1; i <= document.pageCount; i++) {
        final page = await document.getPage(i);
        final image = await page.render(
          width: 1080, // 원하는 해상도
          height: 1920,
        );

        if (image != null) {
          final imageData =
              await image.createImageIfNotAvailable(); // 이미지 데이터를 생성
          final byteData = await imageData.toByteData(
              format: ImageByteFormat.png); // PNG 포맷으로 변환
          if (byteData != null) {
            final tempDir = await getTemporaryDirectory();
            final imagePath = '${tempDir.path}/page_$i.png';
            final imageFile = File(imagePath)
              ..writeAsBytesSync(byteData.buffer.asUint8List());
            imageFiles.add(imageFile);
          }
        }
      }

      return imageFiles;
    } catch (e) {
      _showErrorDialog('Failed to convert PDF to images: $e');
      return [];
    }
  }

  void _handleConvertedImages(List<File> imageFiles) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const QuestionExtractView(),
    ));

    List<Map<String, dynamic>> allFileResponses = [];

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
          "isChecked": List<bool>.filled(questions.length, false),
        });
      } else {
        _showErrorDialog(
            'Failed to get response from server for one of the converted images.');
      }
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => MultiFileQuestionListView(
        fileResponses: allFileResponses,
      ),
    ));
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
