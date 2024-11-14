import 'package:flutter/material.dart';
import 'package:notelens_app/src/ui/category/view_model/category_list_view_model.dart';
import 'package:notelens_app/src/ui/custom/custom_bottombar.dart';
import 'package:provider/provider.dart';
import '../../custom/custom_appbar.dart';
import '../widgets/build_category_list.dart';
import '../widgets/build_blurred_overlay.dart';
import '../widgets/build_blurred_left_icons.dart';
import '../widgets/build_blurred_right_icons.dart';

class CategoryListView extends StatefulWidget {
  const CategoryListView({super.key});

  @override
  _CategoryListViewState createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CategoryListViewModel>(context);

    return Scaffold(
      appBar: CustomAppBar(
        leading: const Icon(null),
        title: Image.asset('assets/images/NoteLens.png', width: 40, height: 40),
      ),
      body: Stack(
        children: [
          buildCategoryList(context, viewModel),
          if (viewModel.isLeftBlurred || viewModel.isRightBlurred)
            buildBlurredOverlay(viewModel),
          if (viewModel.isLeftBlurred) buildBlurredLeftIcons(context),
          if (viewModel.isRightBlurred)
            BlurredRightIcons(viewModel: viewModel), // 수정된 부분
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        isLeftBlurred: viewModel.isLeftBlurred,
        isRightBlurred: viewModel.isRightBlurred,
        onLeftIconTap: () {
          viewModel.toggleLeftBlur();
        },
        onRightIconTap: () {
          viewModel.toggleRightBlur();
        },
      ),
    );
  }
}
