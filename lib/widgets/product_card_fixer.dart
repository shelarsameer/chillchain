import 'package:flutter/material.dart';

class ProductCardFixer extends StatelessWidget {
  final Widget child;
  
  const ProductCardFixer({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // This widget creates a constrained box that will forcibly clip 
    // any content that tries to overflow, including warning banners
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Create a fixed height constraint that prevents overflow
        return ClipRect(
          clipBehavior: Clip.hardEdge,
          child: PhysicalModel(
            color: Colors.transparent,
            elevation: 0,
            clipBehavior: Clip.hardEdge, // Most aggressive clipping
            child: SizedBox(
              height: constraints.maxHeight - 5, // Subtract 5 pixels to ensure no overflow
              width: constraints.maxWidth,
              child: OverflowBox(
                maxHeight: constraints.maxHeight - 5,
                maxWidth: constraints.maxWidth,
                minHeight: 0,
                minWidth: 0,
                alignment: Alignment.topCenter,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
} 