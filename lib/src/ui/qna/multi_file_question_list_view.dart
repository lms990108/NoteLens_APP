import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:notelens_app/src/ui/question/view/question_answer_view.dart';
import 'package:notelens_app/src/ui/question/view/question_list_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MultiFileQuestionListView extends StatefulWidget {
  final List<Map<String, dynamic>> fileResponses;

  const MultiFileQuestionListView({super.key, required this.fileResponses});

  @override
  _MultiFileQuestionListViewState createState() =>
      _MultiFileQuestionListViewState();
}

class _MultiFileQuestionListViewState extends State<MultiFileQuestionListView> {
  final PageController _pageController = PageController();
  late List<List<bool>> _isChecked; // 각 파일의 체크 상태 저장
  late List<List<String>> _questions; // 질문 상태
  late List<List<String>> _contents; // 내용 상태

  @override
  void initState() {
    super.initState();

    // 상태 초기화
    _isChecked = widget.fileResponses
        .map((fileData) =>
            List<bool>.filled(fileData["questions"].length, false))
        .toList();

    _questions = widget.fileResponses
        .map((fileData) => List<String>.from(fileData["questions"]))
        .toList();

    _contents = widget.fileResponses
        .map((fileData) => List<String>.from(fileData["contents"]))
        .toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateFileData(
      int fileIndex, List<String> newQuestions, List<String> newContents) {
    setState(() {
      _questions[fileIndex] = newQuestions;
      _contents[fileIndex] = newContents;
      _isChecked[fileIndex] =
          List<bool>.filled(newQuestions.length, false); // 체크 상태 초기화
    });
  }

  Future<void> _sendSelectedQuestionsToGpt() async {
    // 체크된 질문을 모두 수집
    List<String> selectedQuestions = [];
    List<String> originalContents = [];

    for (int fileIndex = 0; fileIndex < _isChecked.length; fileIndex++) {
      for (int questionIndex = 0;
          questionIndex < _isChecked[fileIndex].length;
          questionIndex++) {
        if (_isChecked[fileIndex][questionIndex]) {
          selectedQuestions.add(_contents[fileIndex][questionIndex]);
        }
      }
      originalContents.add(widget.fileResponses[fileIndex]["originalContent"]);
    }

    if (selectedQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No questions selected.")),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      List<String> responses = await _sendQuestionsToChatGpt(
        selectedQuestions,
        originalContents,
      );

      Navigator.of(context).pop();

      // 다음 화면으로 이동하여 응답을 표시
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionAnswerView(
            questions: selectedQuestions,
            answers: responses,
          ),
        ),
      );
    } catch (error) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }

  Future<List<String>> _sendQuestionsToChatGpt(
      List<String> selectedQuestions, List<String> originalContents) async {
    final apiKey = dotenv.env['OPENAI_API_KEY']!;
    const apiUrl = 'https://api.openai.com/v1/chat/completions';

    // 각 질문에 대해 API 요청 생성
    List<Future<String>> apiRequests =
        selectedQuestions.asMap().entries.map<Future<String>>((entry) async {
      final int index = entry.key;
      final String question = entry.value;
      final String originalContent = originalContents.isNotEmpty
          ? originalContents[index % originalContents.length]
          : '';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'gpt-3.5-turbo',
            'messages': [
              {
                'role': 'user',
                'content':
                    '"$originalContent"의 내용 중에서, "$question" 부분에 대해 설명해줘. 설명은 무조건 한글로 해줘'
              }
            ],
            'max_tokens': 500,
          }),
        );

        if (response.statusCode == 200) {
          final utf8ResponseBody = utf8.decode(response.bodyBytes);
          final responseData = jsonDecode(utf8ResponseBody);
          return responseData['choices'][0]['message']['content'];
        } else {
          throw Exception(
              'Failed to get response from ChatGPT API: ${response.statusCode}');
        }
      } catch (error) {
        throw Exception('Error sending request to ChatGPT API: $error');
      }
    }).toList();

    // 모든 요청 완료 후 결과 반환
    return Future.wait(apiRequests);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView with QuestionListView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.fileResponses.length,
            itemBuilder: (context, index) {
              return QuestionListView(
                questions: _questions[index],
                contents: _contents[index],
                originalContent: widget.fileResponses[index]["originalContent"],
                isChecked: _isChecked[index],
                onCheckChanged: (questionIndex, value) {
                  setState(() {
                    _isChecked[index][questionIndex] = value;
                  });
                },
                onMergeCompleted: (newQuestions, newContents, newChecked) {
                  _updateFileData(index, newQuestions, newContents);
                },
              );
            },
          ),
          // Page indicator at the bottom
          Positioned(
            bottom: 60.0,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: widget.fileResponses.length,
                effect: const WormEffect(
                  dotWidth: 10.0,
                  dotHeight: 10.0,
                  spacing: 8.0,
                  activeDotColor: Colors.deepPurple,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 206, 206, 206),
            minimumSize: const Size(0, 40),
            elevation: 4,
          ),
          onPressed: _sendSelectedQuestionsToGpt,
          child: const Text(
            "질문하기",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
