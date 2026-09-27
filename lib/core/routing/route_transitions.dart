import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';

/// Custom page transitions for GoRouter
CustomTransitionPage<void> buildPageTransition({
  required LocalKey key,
  required Widget child,
  PageTransitionType type = PageTransitionType.fade,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(
      milliseconds: AppConstants.pageTransitionMs,
    ),
    reverseTransitionDuration: const Duration(
      milliseconds: AppConstants.normalAnimationMs,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return switch (type) {
        PageTransitionType.fade => _FadeTransition(
            animation: animation,
            child: child,
          ),
        PageTransitionType.slideUp => _SlideTransition(
            animation: animation,
            direction: SlideDirection.up,
            child: child,
          ),
        PageTransitionType.slideRight => _SlideTransition(
            animation: animation,
            direction: SlideDirection.right,
            child: child,
          ),
        PageTransitionType.scale => _ScaleTransition(
            animation: animation,
            child: child,
          ),
        PageTransitionType.fadeScale => _FadeScaleTransition(
            animation: animation,
            child: child,
          ),
      };
    },
  );
}

// ── Transition Types ───────────────────────────────────────────────────────

enum PageTransitionType { fade, slideUp, slideRight, scale, fadeScale }

enum SlideDirection { up, right }

class _FadeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _FadeTransition({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: child,
    );
  }
}

class _SlideTransition extends StatelessWidget {
  final Animation<double> animation;
  final SlideDirection direction;
  final Widget child;

  const _SlideTransition({
    required this.animation,
    required this.direction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final begin = direction == SlideDirection.up
        ? const Offset(0, 0.06)
        : const Offset(-0.06, 0);

    return SlideTransition(
      position: Tween(begin: begin, end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.8),
        ),
        child: child,
      ),
    );
  }
}

class _ScaleTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _ScaleTransition({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.96, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
        child: child,
      ),
    );
  }
}

class _FadeScaleTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _FadeScaleTransition({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween(begin: 0.97, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }
}
