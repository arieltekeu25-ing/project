import 'package:flutter/material.dart';

/// Système de rayons du Design System
class DSRadius {
  // ============================================
  // Rayons en pixels
  // ============================================
  static const double none = 0.0;
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
  static const double circle = 999.0;

  // ============================================
  // BorderRadius helpers
  // ============================================
  static const BorderRadius xxsRadius = BorderRadius.all(Radius.circular(xxs));
  static const BorderRadius xsRadius = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlRadius = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius xxxlRadius = BorderRadius.all(Radius.circular(xxxl));
  static const BorderRadius circleRadius = BorderRadius.all(Radius.circular(circle));

  // ============================================
  // BorderRadiusDirectional helpers
  // ============================================
  static const BorderRadiusDirectional xxsRadiusDirectional = BorderRadiusDirectional.all(Radius.circular(xxs));
  static const BorderRadiusDirectional xsRadiusDirectional = BorderRadiusDirectional.all(Radius.circular(xs));
  static const BorderRadiusDirectional smRadiusDirectional = BorderRadiusDirectional.all(Radius.circular(sm));
  static const BorderRadiusDirectional mdRadiusDirectional = BorderRadiusDirectional.all(Radius.circular(md));
  static const BorderRadiusDirectional lgRadiusDirectional = BorderRadiusDirectional.all(Radius.circular(lg));
  static const BorderRadiusDirectional xlRadiusDirectional = BorderRadiusDirectional.all(Radius.circular(xl));
  static const BorderRadiusDirectional xxlRadiusDirectional = BorderRadiusDirectional.all(Radius.circular(xxl));
  static const BorderRadiusDirectional xxxlRadiusDirectional = BorderRadiusDirectional.all(Radius.circular(xxxl));
  static const BorderRadiusDirectional circleRadiusDirectional = BorderRadiusDirectional.all(Radius.circular(circle));

  // ============================================
  // RoundedRectangleBorder helpers
  // ============================================
  static RoundedRectangleBorder xxsBorder = const RoundedRectangleBorder(borderRadius: xxsRadius);
  static RoundedRectangleBorder xsBorder = const RoundedRectangleBorder(borderRadius: xsRadius);
  static RoundedRectangleBorder smBorder = const RoundedRectangleBorder(borderRadius: smRadius);
  static RoundedRectangleBorder mdBorder = const RoundedRectangleBorder(borderRadius: mdRadius);
  static RoundedRectangleBorder lgBorder = const RoundedRectangleBorder(borderRadius: lgRadius);
  static RoundedRectangleBorder xlBorder = const RoundedRectangleBorder(borderRadius: xlRadius);
  static RoundedRectangleBorder xxlBorder = const RoundedRectangleBorder(borderRadius: xxlRadius);
  static RoundedRectangleBorder xxxlBorder = const RoundedRectangleBorder(borderRadius: xxxlRadius);
  static RoundedRectangleBorder circleBorder = const RoundedRectangleBorder(borderRadius: circleRadius);
}
