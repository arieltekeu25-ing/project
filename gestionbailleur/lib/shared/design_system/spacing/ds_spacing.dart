import 'package:flutter/material.dart';

/// Système d'espacements du Design System
class DSSpacing {
  // ============================================
  // Espacements en pixels
  // ============================================
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;
  static const double massive = 64.0;

  // ============================================
  // EdgeInsets helpers
  // ============================================
  static const EdgeInsets allXxs = EdgeInsets.all(xxs);
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);
  static const EdgeInsets allXxxl = EdgeInsets.all(xxxl);
  static const EdgeInsets allHuge = EdgeInsets.all(huge);
  static const EdgeInsets allMassive = EdgeInsets.all(massive);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets horizontalXxl = EdgeInsets.symmetric(horizontal: xxl);
  static const EdgeInsets horizontalXxxl = EdgeInsets.symmetric(horizontal: xxxl);
  static const EdgeInsets horizontalHuge = EdgeInsets.symmetric(horizontal: huge);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets verticalXxl = EdgeInsets.symmetric(vertical: xxl);
  static const EdgeInsets verticalXxxl = EdgeInsets.symmetric(vertical: xxxl);
  static const EdgeInsets verticalHuge = EdgeInsets.symmetric(vertical: huge);

  static const EdgeInsets onlyTopXs = EdgeInsets.only(top: xs);
  static const EdgeInsets onlyTopSm = EdgeInsets.only(top: sm);
  static const EdgeInsets onlyTopMd = EdgeInsets.only(top: md);
  static const EdgeInsets onlyTopLg = EdgeInsets.only(top: lg);
  static const EdgeInsets onlyTopXl = EdgeInsets.only(top: xl);

  static const EdgeInsets onlyBottomXs = EdgeInsets.only(bottom: xs);
  static const EdgeInsets onlyBottomSm = EdgeInsets.only(bottom: sm);
  static const EdgeInsets onlyBottomMd = EdgeInsets.only(bottom: md);
  static const EdgeInsets onlyBottomLg = EdgeInsets.only(bottom: lg);
  static const EdgeInsets onlyBottomXl = EdgeInsets.only(bottom: xl);

  static const EdgeInsets onlyLeftXs = EdgeInsets.only(left: xs);
  static const EdgeInsets onlyLeftSm = EdgeInsets.only(left: sm);
  static const EdgeInsets onlyLeftMd = EdgeInsets.only(left: md);
  static const EdgeInsets onlyLeftLg = EdgeInsets.only(left: lg);
  static const EdgeInsets onlyLeftXl = EdgeInsets.only(left: xl);

  static const EdgeInsets onlyRightXs = EdgeInsets.only(right: xs);
  static const EdgeInsets onlyRightSm = EdgeInsets.only(right: sm);
  static const EdgeInsets onlyRightMd = EdgeInsets.only(right: md);
  static const EdgeInsets onlyRightLg = EdgeInsets.only(right: lg);
  static const EdgeInsets onlyRightXl = EdgeInsets.only(right: xl);
}
