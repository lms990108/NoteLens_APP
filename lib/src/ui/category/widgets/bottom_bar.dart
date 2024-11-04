import 'package:flutter/material.dart';

Widget myBottomBar({
  required BuildContext context,
  required bool isLeftBlurred,
  required bool isRightBlurred,
  required VoidCallback onHelpTap,
  required VoidCallback onFileTap,
  required VoidCallback onTempQuestionTap,
  required VoidCallback onAddCategoryTap,
  required VoidCallback onLeftIconToggle,
  required VoidCallback onRightIconToggle,
}) {
  return BottomAppBar(
    height: 50,
    color: Colors.white,
    padding: const EdgeInsets.all(10),
    child: Row(
      children: [
        GestureDetector(
          onTap: onLeftIconToggle,
          child: Icon(
            Icons.help_outline_rounded,
            color: isLeftBlurred
                ? Colors.black
                : const Color.fromARGB(255, 203, 203, 203),
            size: 40,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onFileTap,
          child: const Icon(Icons.one_k, size: 40),
        ),
        GestureDetector(
          onTap: onTempQuestionTap,
          child: const Icon(Icons.two_k, size: 40),
        ),
        GestureDetector(
          onTap: onAddCategoryTap,
          child: const Icon(Icons.add, size: 40),
        ),
        GestureDetector(
          onTap: onRightIconToggle,
          child: Icon(
            Icons.add_circle_outline_rounded,
            color: isRightBlurred
                ? Colors.black
                : const Color.fromARGB(255, 203, 203, 203),
            size: 40,
          ),
        ),
      ],
    ),
  );
}
