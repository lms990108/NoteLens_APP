import 'dart:ui';
import 'package:flutter/material.dart';
import '../view_model/category_list_view_model.dart';

Widget buildBlurredOverlay(CategoryListViewModel viewModel) {
  return GestureDetector(
    onTap: () {
      viewModel.resetBlur();
    },
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: Container(
        color: Colors.black.withOpacity(0),
      ),
    ),
  );
}
