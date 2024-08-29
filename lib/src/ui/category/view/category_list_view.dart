import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notelens_app/src/ui/category/view_model/category_list_view_model.dart';
import 'package:notelens_app/src/data/model/category.dart';

class CategoryListView extends StatelessWidget {
  const CategoryListView({super.key});

  
  @override
  Widget build(BuildContext context) {
    final categoryListViewModel = Provider.of<CategoryListViewModel>(context);

    return Scaffold(
      appBar: _myAppBar(categoryListViewModel),
      body: _buildCategoryList(context, categoryListViewModel),
      bottomNavigationBar: _myBottomBar(categoryListViewModel),
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
        InkWell(
          child: const Icon(Icons.plus_one_outlined),
          onTap: () {
            // Logic to add a new category
              viewModel.addCategory(
                Category(
                  title: 'New Category',
                  description: 'New Description',
                  createdAt: DateTime.now(),
                  isDeleted: false,
                ),
              );
          },
        ),
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
                      // Update with the specific category's ID
                      viewModel.updateCategory(
                        // TODO : update 페이지로 이동
                        Category(
                          id: category
                              .id, // Use the existing ID of the category
                          title: 'Updated Category',
                          description: 'Updated Description',
                          createdAt: category.createdAt,
                          isDeleted: category.isDeleted,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Delete using the specific category's ID
                      viewModel.deleteCategory(category.id!);
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

  Widget _myBottomBar(CategoryListViewModel viewModel) {
    return BottomAppBar(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Color.fromARGB(255, 203, 203, 203)),
            onPressed: () {},
            iconSize: 40
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color.fromARGB(255, 203, 203, 203)),
            onPressed: () {},
            iconSize: 40,
          )
        ],
      ),
    );
  }
}
