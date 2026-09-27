import 'package:flutter/material.dart';
import 'package:travella/core/constants/app_constants.dart';

/// Responsive breakpoint system for Travella
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = AppConstants.mobileBreakpoint;    // < 600
  static const double tablet = AppConstants.tabletBreakpoint;    // < 1024
  static const double desktop = AppConstants.desktopBreakpoint;  // >= 1280

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobile && w < desktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  static bool isSmallTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobile && w < tablet;
  }

  static bool isLargeTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= tablet && w < desktop;
  }

  static DeviceType deviceType(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < mobile) return DeviceType.mobile;
    if (w < desktop) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// Constrains content to a max width for readability on large screens
  static double contentMaxWidth(BuildContext context) =>
      AppConstants.maxContentWidth;

  /// Horizontal padding based on screen size
  static double horizontalPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < mobile) return 16.0;
    if (w < tablet) return 24.0;
    if (w < desktop) return 40.0;
    return 64.0;
  }

  /// Section vertical padding based on screen size
  static double verticalSectionPadding(BuildContext context) {
    if (isMobile(context)) return 56.0;
    if (isTablet(context)) return 72.0;
    return 96.0;
  }

  /// Responsive value helper — returns a value based on current device type
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    final device = deviceType(context);
    return switch (device) {
      DeviceType.mobile => mobile,
      DeviceType.tablet => tablet ?? desktop,
      DeviceType.desktop => desktop,
    };
  }

  /// Grid column count
  static int gridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isSmallTablet(context)) return 2;
    if (isLargeTablet(context)) return 3;
    return 4;
  }

  static int cardColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }
}

enum DeviceType { mobile, tablet, desktop }

/// ResponsiveBuilder that rebuilds when layout changes
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    DeviceType deviceType,
    BoxConstraints constraints,
  ) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final device = AppBreakpoints.deviceType(context);
        return builder(context, device, constraints);
      },
    );
  }
}

/// Renders different widgets per screen size
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, _) => switch (deviceType) {
        DeviceType.mobile => mobile,
        DeviceType.tablet => tablet ?? desktop,
        DeviceType.desktop => desktop,
      },
    );
  }
}

/// Constrains content width to [AppConstants.maxContentWidth]
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? AppConstants.maxContentWidth,
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Section wrapper with consistent padding and max width
class SectionContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? customPadding;
  final double? maxWidth;

  const SectionContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.customPadding,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final vPad = AppBreakpoints.verticalSectionPadding(context);

    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: customPadding ??
          EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      child: MaxWidthContainer(
        maxWidth: maxWidth,
        child: child,
      ),
    );
  }
}
