import 'package:flutter/material.dart';
import '../view_model/category_list_view_model.dart';
import '../../qna/qna_list_view.dart';
import '../../../data/model/category.dart';

Widget buildCategoryList(
    BuildContext context, CategoryListViewModel viewModel) {
  final activeCategories = viewModel.categories
      .where((category) => category.isDeleted == false)
      .toList();

  return FutureBuilder(
    future: viewModel.fetchCategories(),
    builder: (context, snapshot) {
      return Container(
          color: Colors.white,
          child: Column(children: [
            Container(
              margin: const EdgeInsets.fromLTRB(12, 20, 0, 3),
              alignment: Alignment.bottomLeft,
              child: const Text("Category"),
            ),
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.black,
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            ),
            Expanded(
                child: viewModel.isGrid
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                                childAspectRatio: 1),
                        itemCount: activeCategories.length,
                        itemBuilder: (context, index) {
                          final category = activeCategories[index];
                          return _buildGridItem(context, category, viewModel);
                        },
                      )
                    : ListView.builder(
                        itemCount: activeCategories.length,
                        itemBuilder: (context, index) {
                          final category = activeCategories[index];
                          return _buildListItem(context, category, viewModel);
                        },
                      ))
          ]));
    },
  );
}

Widget _buildListItem(
    BuildContext context, Category category, CategoryListViewModel viewModel) {
  return ListTile(
    leading: const Icon(
      Icons.folder_rounded,
      size: 40,
      color: Colors.black54,
    ),
    title: Text(category.title),
    subtitle: Text(category.description ?? ''), // 카테고리 설명이 있을 경우 사용
    onLongPress: () {
      _showCategoryOptions(context, viewModel, category);
    },
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QnAListView(
            categoryId: category.id!,
            categoryTitle: category.title,
          ),
        ),
      );
    },
  );
}

Widget _buildGridItem(
    BuildContext context, Category category, CategoryListViewModel viewModel) {
  return GestureDetector(
      onTap: () {
        // 카테고리 클릭 시 QnA 목록으로 이동
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => QnAListView(
                    categoryId: category.id!,
                    categoryTitle: category.title,
                  )),
        );
      },
      onLongPress: () {
        _showCategoryOptions(context, viewModel, category);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.folder_rounded,
            size: 64,
            color: Colors.black54,
          ),
          const SizedBox(height: 8),
          Text(
            category.title,
            style: const TextStyle(fontSize: 16),
          )
        ],
      ));
}

void _showCategoryOptions(
    BuildContext context, CategoryListViewModel viewModel, Category category) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('수정'),
            onTap: () {
              Navigator.of(context).pop(); // 메뉴 닫기
              // 카테고리 수정 화면으로 이동
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('삭제'),
            onTap: () {
              Navigator.of(context).pop();
              _showDeleteConfirmationDialog(context, viewModel, category.id!);
            },
          ),
        ],
      );
    },
  );
}

void _showDeleteConfirmationDialog(
    BuildContext context, CategoryListViewModel viewModel, int categoryId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('카테고리 삭제'),
        content: const Text('선택한 카테고리를 삭제하시겠습니까?'),
        actions: <Widget>[
          TextButton(
            child: const Text('취소'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('삭제'),
            onPressed: () {
              viewModel.deleteCategory(categoryId);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
