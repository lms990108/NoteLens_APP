import 'package:flutter/material.dart';
import 'package:notelens_app/src/ui/category/view/category_list_view.dart';

class HowToUseView extends StatelessWidget {
  const HowToUseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _myAppBar(context),
        body: Container(
          color: Colors.white,
          child: const Center(
            child: Text('사용법 적으면 됨'),
          ),
        ));
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
