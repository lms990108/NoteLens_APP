import 'package:flutter/material.dart';
import '../view/how_to_use_view.dart';

Widget buildBlurredLeftIcons(BuildContext context) {
  return Positioned(
    bottom: 15,
    left: 15,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.send, size: 30),
            SizedBox(width: 8),
            Text('Report / Feedback'),
          ],
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const HowToUseView(),
              ),
            );
          },
          child: const Row(
            children: [
              Icon(Icons.book, size: 30),
              SizedBox(width: 8),
              Text('How to use'),
            ],
          ),
        ),
      ],
    ),
  );
}
