import 'package:flutter/material.dart';
import 'dart:ui';

Widget buildBlurredOverlay(VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: Container(
        color: Colors.black.withOpacity(0),
      ),
    ),
  );
}
