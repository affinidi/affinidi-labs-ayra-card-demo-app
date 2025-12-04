import 'package:flutter/material.dart';

class ScreensizeHelper {
  static double getRadiusForScreenWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 1024 ? 6.0 : 2.0;
  }

  static double getConstrainedWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 1024 ? 1024 : screenWidth;
  }
}
