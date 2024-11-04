import 'package:flutter/material.dart';
import 'package:notelens_app/src/data/model/category.dart';
import 'package:provider/provider.dart';
import '../widgets/app_bar.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/blurred_overlay.dart';
import '../widgets/category_grid.dart';
import '../utils/file_picker_utils.dart';
import '../utils/dialog_utils.dart';
import 'package:notelens_app/src/ui/category/view_model/category_list_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CategoryListView extends StatefulWidget {
  const CategoryListView({super.key});

  @override
  _CategoryListViewState createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView> {
  bool _isLeftBlurred = false;
  bool _isRightBlurred = false;
  File? selectedFile;

  @override
  Widget build(BuildContext context) {
    final categoryListViewModel = Provider.of<CategoryListViewModel>(context);

    return Scaffold(
      appBar: myAppBar(categoryListViewModel),
      body: Stack(
        children: [
          buildCategoryGrid(context, categoryListViewModel, (category) {
            _showCategoryOptions(context, categoryListViewModel, category);
          }),
          if (_isLeftBlurred || _isRightBlurred)
            buildBlurredOverlay(() {
              setState(() {
                _isLeftBlurred = false;
                _isRightBlurred = false;
              });
            }),
        ],
      ),
      bottomNavigationBar: myBottomBar(
        context: context,
        isLeftBlurred: _isLeftBlurred,
        isRightBlurred: _isRightBlurred,
        onHelpTap: () {},
        onFileTap: () async {
          // 파일 선택 및 처리 로직
        },
        onTempQuestionTap: () {},
        onAddCategoryTap: () {},
        onLeftIconToggle: () {
          setState(() {
            _isLeftBlurred = !_isLeftBlurred;
            if (_isRightBlurred) _isRightBlurred = false;
          });
        },
        onRightIconToggle: () {
          setState(() {
            _isRightBlurred = !_isRightBlurred;
            if (_isLeftBlurred) _isLeftBlurred = false;
          });
        },
      ),
    );
  }

  void _showCategoryOptions(BuildContext context,
      CategoryListViewModel viewModel, Category category) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('수정'),
              onTap: () {
                Navigator.of(context).pop();
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
}
