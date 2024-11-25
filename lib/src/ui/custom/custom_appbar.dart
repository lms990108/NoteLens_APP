import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../category/view/category_list_view.dart';
import '../category/view_model/category_list_view_model.dart';

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
              _showBackConfirmationDialog(context);
            },
          ),
      actions: actions ??
          [
            InkWell(
              child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: const Icon(Icons.settings, size: 30)),
              onTap: () {
                _showViewOptionDialog(context);
              },
            )
          ],
    );
  }

  void _showBackConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("뒤로 가시겠습니까?"),
          content: const Text("현재 페이지에서 나가시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).pop(); // 이전 화면으로 이동
              },
              child: const Text("뒤로가기"),
            ),
          ],
        );
      },
    );
  }

  void _showViewOptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('보기 방식 선택'),
          content: const Text('리스트 또는 그리드 보기 방식을 선택하세요.'),
          actions: <Widget>[
            TextButton(
              child: const Text('리스트 보기'),
              onPressed: () {
                Provider.of<CategoryListViewModel>(context, listen: false)
                    .setGrid(false);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('그리드 보기'),
              onPressed: () {
                Provider.of<CategoryListViewModel>(context, listen: false)
                    .setGrid(true);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
