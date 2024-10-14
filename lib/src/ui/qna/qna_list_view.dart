import 'package:flutter/material.dart';
import 'package:notelens_app/src/data/model/qna.dart';
import 'package:notelens_app/src/data/repository/qna_repository.dart';
import 'package:notelens_app/src/ui/question/view/question_answer_view.dart';

class QnAListView extends StatelessWidget {
  final int categoryId;
  final String categoryTitle;

  const QnAListView({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    final QnARepository qnaRepository = QnARepository();

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle),
      ),
      body: FutureBuilder<List<QnA>>(
        future: qnaRepository.getQnAsByCategory(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load QnAs'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No QnAs available.'));
          } else {
            final qnaList = snapshot.data!;

            return ListView.builder(
              itemCount: qnaList.length,
              itemBuilder: (context, index) {
                final qna = qnaList[index];

                return ListTile(
                  title: Text(qna.title),
                  subtitle: Text(qna.qContent),
                  onTap: () {
                    // QnA 상세 화면으로 이동
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => QuestionAnswerView(
                          questions: [qna.qContent],
                          answers: [qna.aContent],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
