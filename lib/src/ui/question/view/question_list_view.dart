import 'package:flutter/material.dart';
import '../../custom/custom_appbar.dart';

class QuestionListView extends StatefulWidget {
  final List<String> questions;
  final List<String> contents;
  final String originalContent;
  final List<bool> isChecked; // 체크 상태 리스트
  final Function(int, bool) onCheckChanged; // 체크 상태 변경 콜백
  final Function(List<String>, List<String>, List<bool>)
      onMergeCompleted; // 병합 완료 콜백

  const QuestionListView({
    super.key,
    required this.questions,
    required this.contents,
    required this.originalContent,
    required this.isChecked,
    required this.onCheckChanged,
    required this.onMergeCompleted,
  });

  @override
  _QuestionListViewState createState() => _QuestionListViewState();
}

class _QuestionListViewState extends State<QuestionListView> {
  bool _isEditing = false; // 수정 모드 여부
  late List<bool> _mergeSelections; // 병합 상태 관리

  @override
  void initState() {
    super.initState();
    _mergeSelections = List<bool>.filled(widget.questions.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Mode" : "Questions"),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing; // 수정 모드 토글
                _mergeSelections =
                    List<bool>.filled(widget.questions.length, false);
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.questions.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: _isEditing
                ? Checkbox(
                    value: _mergeSelections[index],
                    onChanged: (value) {
                      setState(() {
                        _mergeSelections[index] = value ?? false;
                      });
                    },
                  )
                : IconButton(
                    icon: Icon(
                      widget.isChecked[index]
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color:
                          widget.isChecked[index] ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {
                      widget.onCheckChanged(index, !widget.isChecked[index]);
                    },
                  ),
            title: Text(widget.questions[index]),
            subtitle: Text(widget.contents[index]),
            trailing: _isEditing
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _editContent(index);
                    },
                  )
                : null,
          );
        },
      ),
      bottomNavigationBar: _isEditing
          ? ElevatedButton(
              onPressed: _mergeSelectedQuestions,
              child: const Text("Merge Selected Questions"),
            )
          : ElevatedButton(
              onPressed: _callApiWithSelectedQuestions,
              child: const Text("Send Selected Questions to API"),
            ),
    );
  }

  void _mergeSelectedQuestions() {
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

    final mergedQuestion =
        selectedIndexes.map((index) => widget.questions[index]).join(" ");
    final mergedContent =
        selectedIndexes.map((index) => widget.contents[index]).join("\n");

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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  final updatedQuestions = List<String>.from(widget.questions);
                  final updatedContents = List<String>.from(widget.contents);
                  final updatedIsChecked = List<bool>.from(widget.isChecked);

                  // 기존 선택된 질문과 내용을 삭제
                  for (int i = selectedIndexes.length - 1; i >= 0; i--) {
                    updatedQuestions.removeAt(selectedIndexes[i]);
                    updatedContents.removeAt(selectedIndexes[i]);
                    updatedIsChecked.removeAt(selectedIndexes[i]);
                  }

                  // 병합된 질문과 내용을 추가
                  updatedQuestions.add(questionController.text);
                  updatedContents.add(contentController.text);
                  updatedIsChecked.add(false); // 병합된 질문의 초기 체크 상태

                  // 부모 위젯에 업데이트된 상태 전달
                  widget.onMergeCompleted(
                      updatedQuestions, updatedContents, updatedIsChecked);

                  // 병합 선택 상태 초기화
                  _mergeSelections =
                      List<bool>.filled(updatedQuestions.length, false);
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
              onPressed: () => Navigator.of(context).pop(),
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

  void _callApiWithSelectedQuestions() {
    final selectedQuestions = widget.questions
        .asMap()
        .entries
        .where((entry) => widget.isChecked[entry.key])
        .map((entry) => entry.value)
        .toList();

    if (selectedQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No questions selected.")),
      );
      return;
    }

    // 여기에 API 호출 로직 추가
    print("Selected Questions: $selectedQuestions");
  }
}
