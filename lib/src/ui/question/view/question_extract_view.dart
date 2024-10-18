import 'package:flutter/material.dart';

import '../../category/view/category_list_view.dart';

class QuestionExtractView extends StatelessWidget {
  const QuestionExtractView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _myAppBar(context),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              width: 400,
              height: 400,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "질문내용을 추출하고 있습니다...",
              style: TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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
      title: InkWell(
          child:
              Image.asset('assets/images/NoteLens.png', width: 40, height: 40),
          onTap: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const CategoryListView()));
          }),
      actions: [
        InkWell(
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: const Icon(
              Icons.settings,
              size: 30,
            ),
          ),
          onTap: () {},
        ),
      ],
    );
  }
}
