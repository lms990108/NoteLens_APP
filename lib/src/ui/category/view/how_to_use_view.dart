import 'package:flutter/material.dart';
import '../../custom/custom_appbar.dart';

class HowToUseView extends StatelessWidget {
  const HowToUseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(),
        body: Container(
          color: Colors.white,
          child: const Center(
            child: Text('사용법 적으면 됨'),
          ),
        ));
  }
}
