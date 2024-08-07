import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notelens_app/src/ui/category/view_model/category_list_view_model.dart';

class CategoryListView extends StatelessWidget {
  CategoryListView({super.key});

  late final CategoryListViewModel _categoryListViewModel;

  @override
  Widget build(BuildContext context) {
    _categoryListViewModel = Provider.of<CategoryListViewModel>(context, listen: false);

    return Scaffold(
      appBar: _myAppBar(),
      body: _myMainPage(),
      bottomNavigationBar: _myBottomBar()
    );
  }

  PreferredSizeWidget _myAppBar() {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 206, 206, 206),
      leading: IconButton(
        icon: const Icon(Icons.sort),
        onPressed: () {_categoryListViewModel.incrementCounter();},
        tooltip: 'Sidebar',
        iconSize: 30),
      title: Image.asset('assets/images/NoteLens.png', width: 40, height: 40),
      actions: [ IconButton(
        onPressed: () {_categoryListViewModel.incrementCounter();},
        icon: const Icon(Icons.settings),
        iconSize: 30)]
    );
  }

  Widget _myMainPage() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(12, 20, 0, 3),
          alignment: Alignment.bottomLeft,
          child: const Text('Category')
        ),
        Container(
          height: 1,
          width: double.infinity,
          color: Colors.black,
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0)
        )
      ],
    );
  }

  Widget _myBottomBar() {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Color.fromARGB(255, 203, 203, 203)),
            onPressed: () {_categoryListViewModel.incrementCounter();},
            iconSize: 40
          ),
          IconButton(
            onPressed: () {_categoryListViewModel.incrementCounter();},
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color.fromARGB(255, 203, 203, 203))
          )
        ],
      ),
    );
  }
}