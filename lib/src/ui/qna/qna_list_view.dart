import 'package:flutter/material.dart';
import 'package:notelens_app/src/data/model/qna.dart';
import 'package:notelens_app/src/data/repository/qna_repository.dart';
import 'package:notelens_app/src/ui/question/view/question_answer_view.dart';

class QnAListView extends StatefulWidget {
  final int categoryId;
  final String categoryTitle;

  const QnAListView({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  _QnAListViewState createState() => _QnAListViewState();
}

class _QnAListViewState extends State<QnAListView> {
  late QnARepository qnaRepository;

  @override
  void initState() {
    super.initState();
    qnaRepository = QnARepository();
  }

  Future<void> _deleteQnA(int qnaId) async {
    try {
      await qnaRepository.deleteQnA(qnaId); // QnARepository의 삭제 메서드 호출
      setState(() {}); // 삭제 후 UI를 갱신
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete QnA')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _myAppBar(context),
      body: FutureBuilder<List<QnA>>(
        future: qnaRepository.getQnAsByCategory(widget.categoryId),
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
                  onLongPress: () {
                    // 삭제 확인 대화상자 표시
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete QnA'),
                        content: const Text(
                            'Are you sure you want to delete this QnA?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              if (qna.id != null) {
                                await _deleteQnA(qna.id!); // QnA 삭제 호출
                              }
                            },
                            child: const Text('Delete'),
                          ),
                        ],
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
}
