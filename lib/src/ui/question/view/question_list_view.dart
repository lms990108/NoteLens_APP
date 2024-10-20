import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:notelens_app/src/ui/question/view/question_answer_view.dart';

class QuestionListView extends StatefulWidget {
  final List<String> questions;
  final List<String> contents;

  const QuestionListView(
      {super.key, required this.questions, required this.contents});

  @override
  _QuestionListViewState createState() => _QuestionListViewState();
}

class _QuestionListViewState extends State<QuestionListView> {
  late List<bool> _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = List<bool>.filled(widget.questions.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _myAppBar(context),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: widget.questions.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: IconButton(
              icon: Icon(
                _isChecked[index]
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: _isChecked[index] ? Colors.green : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isChecked[index] = !_isChecked[index];
                });
              },
            ),
            title: Text(widget.questions[index]),
            subtitle: Text(widget.contents[index]),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _editContent(index);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () async {
            // 선택된 질문과 내용을 필터링
            List<String> selectedQuestions = [];
            for (int i = 0; i < _isChecked.length; i++) {
              if (_isChecked[i]) {
                selectedQuestions.add(widget.contents[i]);
              }
            }

            if (selectedQuestions.isNotEmpty) {
              // 선택된 질문들을 병렬적으로 ChatGPT API로 전송
              try {
                List<String> responses =
                    await sendQuestionsToChatGpt(selectedQuestions);
                print('ChatGPT Responses: $responses');

                // 응답과 질문을 함께 QuestionAnswerView로 전달
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
                print('Error: $error');
              }
            } else {
              print('No questions selected');
            }
          },
          child: const Text('Send Selected Questions to GPT'),
        ),
      ),
    );
  }

  PreferredSizeWidget _myAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 206, 206, 206),
      leading: InkWell(
        child: const Icon(
          Icons.arrow_back,
          size: 30,
        ),
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
      title: Image.asset('assets/images/NoteLens.png', width: 40, height: 40),
      actions: [
        InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: const Icon(
              Icons.search,
              size: 30,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  void _editContent(int index) {
    TextEditingController controller =
        TextEditingController(text: widget.contents[index]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Content'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter new content"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.contents[index] = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ChatGPT API 호출 함수
  Future<List<String>> sendQuestionsToChatGpt(
      List<String> selectedQuestions) async {
    final apiKey = dotenv.env['OPENAI_API_KEY']!; // .env에서 API 키 가져오기
    final apiUrl =
        'https://api.openai.com/v1/chat/completions'; // ChatGPT API 엔드포인트

    // 병렬적으로 질문을 ChatGPT API로 전송
    List<Future<String>> apiRequests =
        selectedQuestions.map<Future<String>>((String question) async {
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'gpt-3.5-turbo', // 사용하려는 GPT 모델
            'messages': [
              {'role': 'user', 'content': question}
            ],
            'max_tokens': 500, // 필요한 토큰 길이
          }),
        );

        if (response.statusCode == 200) {
          final utf8ResponseBody =
              utf8.decode(response.bodyBytes); // 응답을 UTF-8로 디코딩
          final responseData = jsonDecode(utf8ResponseBody);
          return responseData['choices'][0]['message']
              ['content']; // GPT의 응답 내용 반환
        } else {
          throw Exception('Failed to get response from ChatGPT API');
        }
      } catch (error) {
        print('Error sending request to ChatGPT API: $error');
        throw Exception('Error sending request to ChatGPT API');
      }
    }).toList();

    return Future.wait(apiRequests); // 병렬로 모든 요청을 수행하고 결과를 반환
  }
}
