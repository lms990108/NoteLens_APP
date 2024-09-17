import 'package:flutter/material.dart';

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
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "질문할 내용을 선택하고, 필요시 수정해 주세요",
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
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
}
