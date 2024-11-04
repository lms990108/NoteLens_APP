import 'package:flutter/material.dart';
import 'package:notelens_app/src/ui/category/view_model/category_list_view_model.dart';

PreferredSizeWidget myAppBar(CategoryListViewModel viewModel) {
  return AppBar(
    backgroundColor: const Color.fromARGB(255, 206, 206, 206),
    leading: InkWell(
      child: const Icon(Icons.sort, size: 30),
      onTap: () {}, // 정렬 아이콘 클릭 시 수행할 동작
    ),
    title: Image.asset('assets/images/NoteLens.png', width: 40, height: 40),
    actions: [
      InkWell(
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
          child: const Icon(Icons.settings, size: 30),
        ),
        onTap: () {}, // 설정 아이콘 클릭 시 수행할 동작
      ),
    ],
  );
}
