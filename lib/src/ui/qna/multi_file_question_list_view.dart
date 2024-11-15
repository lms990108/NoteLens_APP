import 'package:flutter/material.dart';
import 'package:notelens_app/src/ui/question/view/question_list_view.dart';

class MultiFileQuestionListView extends StatelessWidget {
  final List<Map<String, dynamic>> fileResponses;

  const MultiFileQuestionListView({Key? key, required this.fileResponses})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Questions by File")),
      body: PageView.builder(
        itemCount: fileResponses.length,
        itemBuilder: (context, index) {
          final fileData = fileResponses[index];

          // 타입 안정성 검증
          final questions = List<String>.from(fileData["questions"]);
          final contents = List<String>.from(fileData["contents"]);
          final originalContent = fileData["originalContent"] as String;

          return QuestionListView(
            questions: questions,
            contents: contents,
            originalContent: originalContent,
          );
        },
      ),
    );
  }
}
