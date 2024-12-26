
import 'package:flutter/material.dart';

extension MediaQueryExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Returns 10% of the screen width
  double get screenWidth1 => screenWidth * 0.1;
  double get screenWidth2 => screenWidth * 0.2;
  double get screenWidth3 => screenWidth * 0.3;
  double get screenWidth4 => screenWidth * 0.4;

  double get screenWidth45 => screenWidth * 0.45;
  double get screenWidth5 => screenWidth * 0.5;
  double get screenWidth6 => screenWidth * 0.6;

  double get screenWidth65 => screenWidth * 0.65;
  double get screenWidth7 => screenWidth * 0.7;
  double get screenWidth8 => screenWidth * 0.8;
  double get screenWidth9 => screenWidth * 0.9;

  /// Returns 10% of the screen height
  double get screenHeight1 => screenHeight * 0.1;
  double get screenHeight2 => screenHeight * 0.2;
  double get screenHeight3 => screenHeight * 0.3;
  double get screenHeight4 => screenHeight * 0.4;
  double get screenHeight5 => screenHeight * 0.5;
  double get screenHeight6 => screenHeight * 0.6;
  double get screenHeight7 => screenHeight * 0.7;
  double get screenHeight8 => screenHeight * 0.8;
  double get screenHeight9 => screenHeight * 0.9;

}