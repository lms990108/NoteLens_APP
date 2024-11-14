import 'package:flutter/material.dart';
import '../category/view/category_list_view.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor;
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;

  const CustomAppBar(
      {super.key,
      this.backgroundColor = const Color.fromARGB(255, 206, 206, 206), // 기본 배경색
      this.title,
      this.leading,
      this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      title: title ??
          InkWell(
              child: Image.asset('assets/images/NoteLens.png',
                  width: 40, height: 40),
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const CategoryListView()));
              }),
      leading: leading ??
          InkWell(
            child: const Icon(Icons.arrow_back, size: 30),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
      actions: [
        InkWell(
            child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: const Icon(Icons.settings, size: 30)))
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
