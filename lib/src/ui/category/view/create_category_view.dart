import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/category_list_view_model.dart';
import '../../../data/model/category.dart';

class CreateCategoryView extends StatefulWidget {
  const CreateCategoryView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateCategoryViewState createState() => _CreateCategoryViewState();
}

class _CreateCategoryViewState extends State<CreateCategoryView> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String? _description;
  bool _isDeleted = false;

  void _submitForm(CategoryListViewModel categoryListViewModel) {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final newCategory = Category(
        title: _title,
        description: _description,
        createdAt: DateTime.now(),
        isDeleted: _isDeleted,
      );

      // newCategory를 데이터베이스 또는 상태 관리에 저장하는 코드 추가
      categoryListViewModel.addCategory(newCategory);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리가 생성되었습니다.')),
      );

      Navigator.of(context).pop(); // 생성 후 이전 화면으로 돌아감
    }
  }

  @override
  Widget build(BuildContext context) {
    // build 메서드 내에서 viewModel 참조
    final categoryListViewModel = Provider.of<CategoryListViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리 생성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
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
                decoration: const InputDecoration(labelText: '설명'),
                onSaved: (value) {
                  _description = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _submitForm(categoryListViewModel),
                child: const Text('생성'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
