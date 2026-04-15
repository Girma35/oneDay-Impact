import 'package:flutter/material.dart';

/// Breakpoints for responsive layout, following Material 3 adaptive guidelines.
class Breakpoints {
  /// Phone: < 600dp
  static const double phone = 600;

  /// Tablet: 600–839dp
  static const double tablet = 840;

  /// Desktop: >= 840dp
  static const double desktop = 840;
}

/// Returns true if the current width is phone-sized.
bool isPhone(BuildContext context) =>
    MediaQuery.sizeOf(context).width < Breakpoints.phone;

/// Returns true if the current width is tablet-sized.
bool isTablet(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  return w >= Breakpoints.phone && w < Breakpoints.tablet;
}

/// Returns true if the current width is desktop-sized.
bool isDesktop(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

/// Wraps a child in a centered max-width container on desktop/tablet.
///
/// On phone: returns [child] unmodified.
/// On tablet: constrains to 600dp centered.
/// On desktop: constrains to [maxWidth] (default 720dp) centered.
Widget responsiveMaxWidth({
  required Widget child,
  double maxWidth = 720,
  double tabletMaxWidth = 600,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      if (width >= Breakpoints.desktop) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      }
      if (width >= Breakpoints.phone) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tabletMaxWidth),
            child: child,
          ),
        );
      }
      return child;
    },
  );
}

/// Returns the number of columns for a grid based on screen width.
int gridColumns(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= Breakpoints.desktop) return 3;
  if (width >= Breakpoints.tablet) return 2;
  return 1;
}
