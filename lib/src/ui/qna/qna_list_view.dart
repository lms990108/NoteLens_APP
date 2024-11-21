import 'package:flutter/material.dart';
import 'package:notelens_app/src/data/model/qna.dart';
import 'package:notelens_app/src/data/repository/qna_repository.dart';
import 'package:notelens_app/src/ui/qna/qna_view.dart';
import '../custom/custom_appbar.dart';

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
      appBar: const CustomAppBar(),
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
                        builder: (context) => QnAView(
                            question: qna.qContent, answer: qna.aContent),
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
}
