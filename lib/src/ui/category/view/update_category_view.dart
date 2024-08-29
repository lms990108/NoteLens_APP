import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/category_list_view_model.dart';
import '../../../data/model/category.dart';

class UpdateCategoryView extends StatefulWidget {
  final int categoryId;

  const UpdateCategoryView({Key? key, required this.categoryId})
      : super(key: key);

  @override
  _UpdateCategoryViewState createState() => _UpdateCategoryViewState();
}

class _UpdateCategoryViewState extends State<UpdateCategoryView> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String? _description;
  bool _isDeleted = false;

  @override
  void initState() {
    super.initState();

    // Initialize the fields with the existing category data
    final categoryListViewModel =
        Provider.of<CategoryListViewModel>(context, listen: false);
    final existingCategory = categoryListViewModel.categories
        .firstWhere((category) => category.id == widget.categoryId);

    _title = existingCategory.title;
    _description = existingCategory.description;
    _isDeleted = existingCategory.isDeleted;
  }

  void _submitForm(CategoryListViewModel categoryListViewModel) {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final updatedCategory = Category(
        id: widget.categoryId,
        title: _title,
        description: _description,
        createdAt: DateTime.now(),
        isDeleted: _isDeleted,
      );

      // updatedCategory를 데이터베이스 또는 상태 관리에 저장하는 코드 추가
      categoryListViewModel.updateCategory(updatedCategory);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리가 수정되었습니다.')),
      );

      Navigator.of(context).pop(); // 수정 후 이전 화면으로 돌아감
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryListViewModel = Provider.of<CategoryListViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리 수정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: '제목'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력하세요.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: '설명'),
                onSaved: (value) {
                  _description = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _submitForm(categoryListViewModel),
                child: const Text('수정'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
