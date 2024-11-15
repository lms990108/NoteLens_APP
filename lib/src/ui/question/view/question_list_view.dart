import 'package:flutter/material.dart';
import '../../custom/custom_appbar.dart';

class QuestionListView extends StatefulWidget {
  final List<String> questions;
  final List<String> contents;
  final String originalContent;
  final List<bool> isChecked; // 체크 상태 리스트
  final Function(int, bool) onCheckChanged; // 체크 상태 변경 콜백

  const QuestionListView({
    Key? key,
    required this.questions,
    required this.contents,
    required this.originalContent,
    required this.isChecked,
    required this.onCheckChanged,
  }) : super(key: key);

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
