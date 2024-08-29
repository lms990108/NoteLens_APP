import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notelens_app/src/ui/category/view_model/category_list_view_model.dart';
import 'package:notelens_app/src/data/model/category.dart';
import 'create_category_view.dart';
import 'update_category_view.dart';

class CategoryListView extends StatelessWidget {
  const CategoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryListViewModel = Provider.of<CategoryListViewModel>(context);

    return Scaffold(
      appBar: _myAppBar(categoryListViewModel),
      body: _buildCategoryList(context, categoryListViewModel),
      bottomNavigationBar: _myBottomBar(context, categoryListViewModel),
    );
  }

  PreferredSizeWidget _myAppBar(CategoryListViewModel viewModel) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 206, 206, 206),
      leading: IconButton(
        icon: const Icon(Icons.sort),
        onPressed: () {}, // 추가할 기능
        tooltip: 'Sidebar',
        iconSize: 30,
      ),
      title: Image.asset('assets/images/NoteLens.png', width: 40, height: 40),
      actions: [
        IconButton(
          onPressed: () {}, // 추가할 기능
          icon: const Icon(Icons.settings),
          iconSize: 30,
        ),
      ],
    );
  }

  Widget _buildCategoryList(
      BuildContext context, CategoryListViewModel viewModel) {
    // isDeleted가 false인 카테고리만 필터링
    final activeCategories = viewModel.categories
        .where((category) => category.isDeleted == false)
        .toList();

    return FutureBuilder(
      future: viewModel.fetchCategories(),
      builder: (context, snapshot) {
        return ListView.builder(
          itemCount: activeCategories.length,
          itemBuilder: (context, index) {
            final category = activeCategories[index];
            return ListTile(
              title: Text(category.title),
              subtitle: Text(category.description ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              UpdateCategoryView(categoryId: category.id!),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteConfirmationDialog(
                          context, viewModel, category.id!);
                    },
                  ),
                ],
              ),
            );
          },
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
          title: const Text('삭제 확인'),
          content: const Text('이 카테고리를 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                viewModel.deleteCategory(categoryId); // 카테고리 삭제
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Widget _myBottomBar(BuildContext context, CategoryListViewModel viewModel) {
    return BottomAppBar(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: Row(
        children: [
          IconButton(
              icon: const Icon(Icons.help_outline_rounded,
                  color: Color.fromARGB(255, 203, 203, 203)),
              onPressed: () {},
              iconSize: 40),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: Color.fromARGB(255, 203, 203, 203)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateCategoryView(),
                ),
              );
            },
            iconSize: 40,
          )
        ],
      ),
    );
  }
}
