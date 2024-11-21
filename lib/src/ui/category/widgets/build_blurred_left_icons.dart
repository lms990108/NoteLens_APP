import 'package:flutter/material.dart';
import 'package:notelens_app/src/ui/category/view_model/category_list_view_model.dart';
import '../view/how_to_use_view.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildBlurredLeftIcons(
    BuildContext context, CategoryListViewModel viewModel) {
  return Positioned(
    bottom: 15,
    left: 15,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
            onTap: () {
              launchURL();
              viewModel.resetBlur();
            },
            child: const Row(
              children: [
                Icon(Icons.send, size: 30),
                SizedBox(width: 8),
                Text('Report / Feedback')
              ],
            )),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const HowToUseView(),
              ),
            );
            viewModel.resetBlur();
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

void launchURL() async {
  const url =
      'https://docs.google.com/forms/d/e/1FAIpQLScP8rXDoj_nydCOCnIwpL96WtA6N6gjYyaNUx4ANQfhFdjwrw/viewform?usp=sf_link';
  final Uri uri = Uri.parse(url);
  try {
    await launchUrl(uri);
  } catch (e) {
    print('Launch error: $e');
  }
}
