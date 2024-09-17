import 'package:flutter/material.dart';

class QuestionListView extends StatefulWidget {
  const QuestionListView({super.key});

  @override
  _QuestionListViewState createState() => _QuestionListViewState();
}

class _QuestionListViewState extends State<QuestionListView> {
  // 상태를 관리할 리스트
  final List<bool> _isChecked = [false, false, false, false, false, false];

  // Sample data for questions and content
  final List<String> questions = [
    "Question 1",
    "Question 2",
    "Question 3",
    "Question 4",
    "Question 5",
    "Question 6",
  ];

  final List<String> contents = [
    "content 1",
    "content 2",
    "content 3",
    "content 4",
    "content 5",
    "content 6",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _myAppBar(context),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: IconButton(
              icon: Icon(
                _isChecked[index]
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked, // 선택 여부에 따라 아이콘 변경
                color: _isChecked[index] ? Colors.green : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isChecked[index] = !_isChecked[index]; // 클릭할 때마다 상태 변경
                });
              },
            ),
            title: Text(questions[index]),
            subtitle: Text(contents[index]),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _editContent(index); // Edit 버튼을 눌렀을 때 다이얼로그를 띄우는 함수 호출
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

  // AppBar 커스텀
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
          onTap: () {
            // 돋보기 버튼 클릭 시 실행할 코드
          },
          child: Container(
            padding: const EdgeInsets.all(8.0), // 버튼에 패딩 추가
            child: const Icon(
              Icons.search, // 돋보기 아이콘 사용
              size: 30,
              color: Colors.black, // 아이콘 색상
            ),
          ),
        ),
      ],
    );
  }

  // content를 수정하는 함수
  void _editContent(int index) {
    TextEditingController controller =
        TextEditingController(text: contents[index]);

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
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  contents[index] = controller.text; // 새로운 content로 업데이트
                });
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
