import 'package:flutter/material.dart';
import 'package:sleep/shared/app_colors.dart';

class AppTextStyles {
  /// Body
  static const TextStyle body =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.25);

  /// Body Lg
  static const TextStyle bodyLg =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.25);

  static const TextStyle bodyLgSm =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.25);

  static const TextStyle bodyLgBold =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3);

  static const TextStyle bodyLgRegular =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.25);

  static const TextStyle bodyLgRegular2 =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.25);

  static const TextStyle bodyLgMd =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.25);

  /// Body Md

  static const TextStyle bodyMd =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.25);

  static const TextStyle bodyMdSm =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3);

  static const TextStyle bodyMdBold =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.3);

  static const TextStyle bodyMdRegular =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.25);

  static const TextStyle bodyMdMedium =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.25);

  /// Body Sm
  static const TextStyle bodySm =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w300, height: 1.25);

  static const TextStyle bodySmMd =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.25);

  static const TextStyle bodySmSb = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: -0.02,);

  static const TextStyle bodySmBold =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w700, height: 1.3);

  static const TextStyle bodySmRegular =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.25);

  /// Body Xs
  static const TextStyle bodyXs =
      TextStyle(fontSize: 10, fontWeight: FontWeight.w300, height: 1.25);

  static const TextStyle bodyXsBold =
      TextStyle(fontSize: 10, fontWeight: FontWeight.w700, height: 1.25);

  static const TextStyle bodyXsRegular =
      TextStyle(fontSize: 10, fontWeight: FontWeight.w400, height: 1.25);

  /// Text style for heading

  static const TextStyle h1 =
      TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.4);

  static const TextStyle h1White = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  /// Title style
  static const TextStyle title3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle title4 =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.4);
  static const TextStyle title5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  /// Button
  static const TextStyle buttonMd = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle buttonLg = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 20 / 16,
    letterSpacing: -0.02,
  );

  // Appbar
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
}
