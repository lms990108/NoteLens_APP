import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final bool isLeftBlurred;
  final bool isRightBlurred;
  final VoidCallback onLeftIconTap;
  final VoidCallback onRightIconTap;

  const CustomBottomBar({
    super.key,
    required this.isLeftBlurred,
    required this.isRightBlurred,
    required this.onLeftIconTap,
    required this.onRightIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 50,
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          GestureDetector(
            onTap: onLeftIconTap,
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
            onTap: onRightIconTap,
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
}
