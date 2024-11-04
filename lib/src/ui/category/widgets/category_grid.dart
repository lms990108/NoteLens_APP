import 'package:flutter/material.dart';
import 'package:notelens_app/src/data/model/category.dart';
import 'package:notelens_app/src/ui/category/view_model/category_list_view_model.dart';
import 'package:notelens_app/src/ui/qna/qna_list_view.dart';

Widget buildCategoryGrid(BuildContext context, CategoryListViewModel viewModel,
    Function(Category) onCategoryLongPress) {
  final activeCategories =
      viewModel.categories.where((category) => !category.isDeleted).toList();

  return Expanded(
    child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 1,
      ),
      itemCount: activeCategories.length,
      itemBuilder: (context, index) {
        final category = activeCategories[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => QnAListView(
                categoryId: category.id!,
                categoryTitle: category.title,
              ),
            ));
          },
          onLongPress: () => onCategoryLongPress(category),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_rounded, size: 64, color: Colors.black54),
              const SizedBox(height: 8),
              Text(category.title, style: const TextStyle(fontSize: 16)),
            ],
          ),
        );
      },
    ),
  );
}
