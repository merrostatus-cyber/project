import 'package:flutter/material.dart';

class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 480,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= maxWidth) return child;
    return Center(
      child: SizedBox(
        width: maxWidth,
        child: child,
      ),
    );
  }
}
