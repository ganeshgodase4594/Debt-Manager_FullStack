import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget webBody;

  const ResponsiveLayout({
    Key? key,
    required this.mobileBody,
    required this.webBody,
  }) : super(key: key);

  // This size is considered as the breakpoint between mobile and web layouts
  static const int breakpoint = 600;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          // Mobile layout
          return mobileBody;
        } else {
          // Web layout
          return webBody;
        }
      },
    );
  }
}