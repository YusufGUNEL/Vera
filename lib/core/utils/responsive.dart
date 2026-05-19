import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ResponsiveSize { mobile, tablet, desktop }

class ResponsiveInfo {
  const ResponsiveInfo(this.width);

  final double width;

  ResponsiveSize get size {
    if (width >= 1100) return ResponsiveSize.desktop;
    if (width >= 700) return ResponsiveSize.tablet;
    return ResponsiveSize.mobile;
  }

  bool get isMobile => size == ResponsiveSize.mobile;
  bool get isTablet => size == ResponsiveSize.tablet;
  bool get isDesktop => size == ResponsiveSize.desktop;

  bool get useDesktopNav => width >= 1100;
  bool get useHomeColumns => width >= 980;

  double get pageGutter => isDesktop ? 28 : (isTablet ? 24 : 16);
  double get contentMaxWidth => isDesktop ? 1320 : (isTablet ? 980 : width);
  double get authMaxWidth => isDesktop ? 560 : (isTablet ? 520 : width);
  double get sheetMaxWidth => isDesktop ? 760 : (isTablet ? 680 : width);
  double get modalHeightFactor => isDesktop ? 0.84 : 0.88;

  double twoColumnWidth(double availableWidth, {double gap = 24}) {
    return math.max(320, (availableWidth - gap) / 2);
  }
}

extension ResponsiveContext on BuildContext {
  ResponsiveInfo get responsive =>
      ResponsiveInfo(MediaQuery.sizeOf(this).width);
}
