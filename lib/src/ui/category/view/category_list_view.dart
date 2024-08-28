import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notelens_app/src/ui/category/view_model/category_list_view_model.dart';
import 'package:notelens_app/src/data/model/category.dart';

class CategoryListView extends StatelessWidget {
  CategoryListView({super.key});

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
    return FutureBuilder(
      future: viewModel.fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load categories'));
        } else {
          return ListView.builder(
            itemCount: viewModel.categories.length,
            itemBuilder: (context, index) {
              final category = viewModel.categories[index];
              return ListTile(
                title: Text(category.title),
                subtitle: Text(category.description ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // 업데이트 로직 추가
                        // viewModel.updateCategory(category);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        viewModel.deleteCategory(category.id!);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _myBottomBar(CategoryListViewModel viewModel) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded,
                color: Color.fromARGB(255, 203, 203, 203)),
            onPressed: () {}, // 추가할 기능
            iconSize: 40,
          ),
          IconButton(
            onPressed: () {
              // 새로운 카테고리 추가 로직
              viewModel.addCategory(
                Category(
                  title: 'New Category',
                  description: 'New Description',
                  createdAt: DateTime.now(),
                  isDeleted: false,
                ),
              );
            },
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: Color.fromARGB(255, 203, 203, 203)),
          ),
        ],
      ),
    );
  }
}
