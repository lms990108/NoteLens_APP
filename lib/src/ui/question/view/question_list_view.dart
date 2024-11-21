import 'package:flutter/material.dart';
import '../../custom/custom_appbar.dart';

class QuestionListView extends StatefulWidget {
  final List<String> questions;
  final List<String> contents;
  final String originalContent;
  final List<bool> isChecked; // 체크 상태 리스트
  final Function(int, bool) onCheckChanged; // 체크 상태 변경 콜백

  const QuestionListView({
    super.key,
    required this.questions,
    required this.contents,
    required this.originalContent,
    required this.isChecked,
    required this.onCheckChanged,
  });

  @override
  _QuestionListViewState createState() => _QuestionListViewState();
}

class _QuestionListViewState extends State<QuestionListView> {
  // 병합 상태를 위한 선택 관리
  List<bool> _mergeSelections = [];

  @override
  void initState() {
    super.initState();
    _mergeSelections = List<bool>.filled(widget.questions.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 병합 버튼
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _mergeSelectedQuestions,
              child: const Text("Merge Selected Questions"),
            ),
          ),
          // 질문 리스트
          Expanded(
            child: ListView.builder(
              itemCount: widget.questions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 병합 선택 체크박스
                      Checkbox(
                        value: _mergeSelections[index],
                        onChanged: (value) {
                          setState(() {
                            _mergeSelections[index] = value ?? false;
                          });
                        },
                      ),
                      // 기존의 선택 상태 아이콘
                      IconButton(
                        icon: Icon(
                          widget.isChecked[index]
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: widget.isChecked[index]
                              ? Colors.green
                              : Colors.grey,
                        ),
                        onPressed: () {
                          widget.onCheckChanged(
                              index, !widget.isChecked[index]);
                        },
                      ),
                    ],
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
          ),
        ],
      ),
    );
  }

  // 병합 기능 구현
  void _mergeSelectedQuestions() {
    // 선택된 질문들의 인덱스 가져오기
    final selectedIndexes = _mergeSelections
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedIndexes.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Select at least two questions to merge.")),
      );
      return;
    }

    // 병합된 질문과 내용 생성
    final mergedQuestion = selectedIndexes
        .map((index) => widget.questions[index])
        .join(" "); // 질문 병합
    final mergedContent = selectedIndexes
        .map((index) => widget.contents[index])
        .join("\n"); // 내용 병합

    // 병합된 질문을 편집 가능하도록 다이얼로그 제공
    TextEditingController questionController =
        TextEditingController(text: mergedQuestion);
    TextEditingController contentController =
        TextEditingController(text: mergedContent);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Merged Question and Content"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration:
                    const InputDecoration(hintText: "Edit merged question"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration:
                    const InputDecoration(hintText: "Edit merged content"),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // 선택된 질문 및 내용을 제거
                  selectedIndexes.reversed.forEach((index) {
                    widget.questions.removeAt(index);
                    widget.contents.removeAt(index);
                  });

                  // 병합된 질문 및 내용을 추가
                  widget.questions.add(questionController.text);
                  widget.contents.add(contentController.text);

                  // 병합 상태 초기화
                  _mergeSelections =
                      List<bool>.filled(widget.questions.length, false);
                });
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
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
}
