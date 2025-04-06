import 'package:flutter/material.dart';

/// This class replaces the yellow/black warning stripes on product cards
/// Now completely hidden to remove the text strings like "CURRENT_OVERDRAWING_AT_A_GLANCE"
class WarningBanner extends StatelessWidget {
  final String? text;
  final bool visible;

  const WarningBanner({
    Key? key,
    this.text,
    this.visible = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Return a completely transparent widget with zero height
    return Container(
      height: 0,
      color: Colors.transparent,
    );
  }
} 