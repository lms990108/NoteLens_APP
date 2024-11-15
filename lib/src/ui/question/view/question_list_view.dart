import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:notelens_app/src/ui/question/view/question_answer_view.dart';
import '../../custom/custom_appbar.dart';

class QuestionListView extends StatefulWidget {
  final List<String> questions;
  final List<String> contents;
  final String originalContent;
  final List<bool> isChecked; // 체크 상태 리스트 추가
  final Function(int, bool) onCheckChanged; // 체크 상태 변경 시 콜백 추가

  const QuestionListView({
    super.key,
    required this.questions,
    required this.contents,
    required this.originalContent,
    required this.isChecked, // 체크 상태 리스트 받기
    required this.onCheckChanged, // 체크 상태 변경 콜백 받기
  });

  @override
  _QuestionListViewState createState() => _QuestionListViewState();
}

class _QuestionListViewState extends State<QuestionListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: widget.questions.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: IconButton(
              icon: Icon(
                widget.isChecked[index]
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: widget.isChecked[index] ? Colors.green : Colors.grey,
              ),
              onPressed: () {
                widget.onCheckChanged(
                    index, !widget.isChecked[index]); // 체크 상태 변경 시 콜백 호출
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
            List<String> selectedQuestions = [];
            for (int i = 0; i < widget.isChecked.length; i++) {
              if (widget.isChecked[i]) {
                selectedQuestions.add(widget.contents[i]);
              }
            }

            if (selectedQuestions.isNotEmpty) {
              try {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                List<String> responses = await sendQuestionsToChatGpt(
                    selectedQuestions, widget.originalContent);
                print('ChatGPT Responses: $responses');
                Navigator.of(context).pop();
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

  Future<List<String>> sendQuestionsToChatGpt(
      List<String> selectedQuestions, String originalContent) async {
    final apiKey = dotenv.env['OPENAI_API_KEY']!;
    final apiUrl = 'https://api.openai.com/v1/chat/completions';

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
            'model': 'gpt-3.5-turbo',
            'messages': [
              {
                'role': 'user',
                'content': '"$originalContent"의 내용 중에서, "$question" 부분에 대해 설명해줘'
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
          throw Exception('Failed to get response from ChatGPT API');
        }
      } catch (error) {
        print('Error sending request to ChatGPT API: $error');
        throw Exception('Error sending request to ChatGPT API');
      }
    }).toList();

    return Future.wait(apiRequests);
  }
}
