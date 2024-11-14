import 'package:flutter/material.dart';
import '../custom/custom_appbar.dart';

class QnAView extends StatelessWidget {
  final String question;
  final String answer;

  const QnAView({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question',
              style: Theme.of(context).textTheme.titleLarge, // 변경된 스타일 적용
            ),
            const SizedBox(height: 8.0),
            Text(
              question,
              style: Theme.of(context).textTheme.bodyLarge, // 본문 스타일
            ),
            const Divider(height: 32.0),
            Text(
              'Answer',
              style: Theme.of(context).textTheme.titleLarge, // 변경된 스타일 적용
            ),
            const SizedBox(height: 8.0),
            Text(
              answer,
              style: Theme.of(context).textTheme.bodyLarge, // 본문 스타일
            ),
          ],
        ),
      ),
    );
  }
}
