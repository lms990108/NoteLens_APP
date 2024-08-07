import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notelens_app/src/ui/category/view/category_list_view.dart';
import 'package:notelens_app/src/ui/category/view_model/category_list_view_model.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CategoryListViewModel>(
          create: (_) => CategoryListViewModel())
      ],
      child: CategoryListView(),
    );
  }
}