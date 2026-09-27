import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../constants/app_constants.dart';

// ── Animation Durations ───────────────────────────────────────────────────────

const kFastDuration = Duration(milliseconds: AppConstants.fastAnimationMs);
const kNormalDuration = Duration(milliseconds: AppConstants.normalAnimationMs);
const kSlowDuration = Duration(milliseconds: AppConstants.slowAnimationMs);

// ── FadeInOnScroll ─────────────────────────────────────────────────────────────
/// Fades in a widget when it becomes visible in the viewport
class FadeInOnScroll extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double visibilityThreshold;

  const FadeInOnScroll({
    super.key,
    required this.child,
    this.duration = kNormalDuration,
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    this.visibilityThreshold = 0.05,
  });

  @override
  State<FadeInOnScroll> createState() => _FadeInOnScrollState();
}

class _FadeInOnScrollState extends State<FadeInOnScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animate() {
    if (_hasAnimated) return;
    _hasAnimated = true;
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.key ?? UniqueKey(),
      onVisibilityChanged: (info) {
        if (info.visibleFraction >= widget.visibilityThreshold) _animate();
      },
      child: FadeTransition(opacity: _opacity, child: widget.child),
    );
  }
}

// ── SlideInOnScroll ────────────────────────────────────────────────────────────
class SlideInOnScroll extends StatefulWidget {
  final Widget child;
  final Offset beginOffset;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double visibilityThreshold;

  const SlideInOnScroll({
    super.key,
    required this.child,
    this.beginOffset = const Offset(0, 0.08),
    this.duration = kSlowDuration,
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.visibilityThreshold = 0.05,
  });

  @override
  State<SlideInOnScroll> createState() => _SlideInOnScrollState();
}

class _SlideInOnScrollState extends State<SlideInOnScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _opacity;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _slide = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animate() {
    if (_hasAnimated) return;
    _hasAnimated = true;
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.key ?? UniqueKey(),
      onVisibilityChanged: (info) {
        if (info.visibleFraction >= widget.visibilityThreshold) _animate();
      },
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(opacity: _opacity, child: widget.child),
      ),
    );
  }
}

// ── ScaleInOnScroll ────────────────────────────────────────────────────────────
class ScaleInOnScroll extends StatefulWidget {
  final Widget child;
  final double beginScale;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double visibilityThreshold;

  const ScaleInOnScroll({
    super.key,
    required this.child,
    this.beginScale = 0.92,
    this.duration = kNormalDuration,
    this.delay = Duration.zero,
    this.curve = Curves.easeOutBack,
    this.visibilityThreshold = 0.05,
  });

  @override
  State<ScaleInOnScroll> createState() => _ScaleInOnScrollState();
}

class _ScaleInOnScrollState extends State<ScaleInOnScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(begin: widget.beginScale, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animate() {
    if (_hasAnimated) return;
    _hasAnimated = true;
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.key ?? UniqueKey(),
      onVisibilityChanged: (info) {
        if (info.visibleFraction >= widget.visibilityThreshold) _animate();
      },
      child: ScaleTransition(
        scale: _scale,
        child: FadeTransition(opacity: _opacity, child: widget.child),
      ),
    );
  }
}

// ── StaggeredAnimation ─────────────────────────────────────────────────────────
/// Animates a list of children with a stagger delay
class StaggeredAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration initialDelay;
  final Axis direction;

  const StaggeredAnimation({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 80),
    this.initialDelay = Duration.zero,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return direction == Axis.vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildAnimatedChildren(),
          )
        : Row(children: _buildAnimatedChildren());
  }

  List<Widget> _buildAnimatedChildren() {
    return List.generate(children.length, (i) {
      return SlideInOnScroll(
        delay: initialDelay + (staggerDelay * i),
        child: children[i],
      );
    });
  }
}

// ── FloatingElement ────────────────────────────────────────────────────────────
/// Subtle floating up-and-down animation (for hero decorations)
class FloatingElement extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double amplitude;

  const FloatingElement({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 3),
    this.amplitude = 8.0,
  });

  @override
  State<FloatingElement> createState() => _FloatingElementState();
}

class _FloatingElementState extends State<FloatingElement>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _slide = Tween<double>(begin: 0, end: widget.amplitude).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slide,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -_slide.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}

// ── AnimatedCounter ────────────────────────────────────────────────────────────
/// Counts up from 0 to [end] when visible
class AnimatedCounter extends StatefulWidget {
  final int end;
  final Duration duration;
  final String prefix;
  final String suffix;
  final TextStyle? style;

  const AnimatedCounter({
    super.key,
    required this.end,
    this.duration = const Duration(seconds: 2),
    this.prefix = '',
    this.suffix = '',
    this.style,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    if (_hasAnimated) return;
    _hasAnimated = true;
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.key ?? UniqueKey(),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.3) _start();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final value = (_animation.value * widget.end).round();
          return Text(
            '${widget.prefix}$value${widget.suffix}',
            style: widget.style,
          );
        },
      ),
    );
  }
}

// ── ParallaxImage ──────────────────────────────────────────────────────────────
/// Parallax scroll effect for background images
class ParallaxImage extends StatefulWidget {
  final ImageProvider imageProvider;
  final double parallaxFactor;
  final double height;
  final Widget? child;
  final BoxFit fit;

  const ParallaxImage({
    super.key,
    required this.imageProvider,
    this.parallaxFactor = 0.3,
    required this.height,
    this.child,
    this.fit = BoxFit.cover,
  });

  @override
  State<ParallaxImage> createState() => _ParallaxImageState();
}

class _ParallaxImageState extends State<ParallaxImage> {
  double _offset = 0;

  void _onScroll(BuildContext context) {
    // Simple parallax using render object position
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final progress = 1 - (position.dy / screenHeight);
    setState(() {
      _offset = progress * widget.height * widget.parallaxFactor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _onScroll(context);
        return false;
      },
      child: SizedBox(
        height: widget.height,
        child: ClipRect(
          child: OverflowBox(
            maxHeight: widget.height * (1 + widget.parallaxFactor),
            child: Transform.translate(
              offset: Offset(0, -_offset),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: widget.imageProvider,
                    fit: widget.fit,
                  ),
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── PulseAnimation ─────────────────────────────────────────────────────────────
/// Subtle pulsing scale animation for CTAs / badges
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration duration;

  const PulseAnimation({
    super.key,
    required this.child,
    this.minScale = 0.97,
    this.maxScale = 1.03,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: widget.minScale, end: widget.maxScale)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}

// ── ShimmerLoader ──────────────────────────────────────────────────────────────
/// Shimmer loading placeholder
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + _animation.value * 3, 0),
              end: Alignment(0 + _animation.value * 3, 0),
              colors: const [
                Color(0xFFE8EDF4),
                Color(0xFFF8FAFC),
                Color(0xFFE8EDF4),
              ],
            ),
          ),
        );
      },
    );
  }
}
