import 'package:flutter/material.dart';

class AppMotion {
  static const Duration quick = Duration(milliseconds: 180);
  static const Duration standard = Duration(milliseconds: 320);
  static const Duration relaxed = Duration(milliseconds: 520);

  static const Curve entranceCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;

  static PageTransitionsTheme get pageTransitionsTheme =>
      const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _AudifyPageTransitionsBuilder(),
          TargetPlatform.iOS: _AudifyPageTransitionsBuilder(),
          TargetPlatform.macOS: _AudifyPageTransitionsBuilder(),
          TargetPlatform.windows: _AudifyPageTransitionsBuilder(),
          TargetPlatform.linux: _AudifyPageTransitionsBuilder(),
          TargetPlatform.fuchsia: _AudifyPageTransitionsBuilder(),
        },
      );

  static PageRoute<T> route<T>(Widget child, {Duration duration = standard}) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: entranceCurve,
          reverseCurve: exitCurve,
        );

        final slide = Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(curved);

        final scale = Tween<double>(begin: 0.985, end: 1).animate(curved);

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(scale: scale, child: child),
          ),
        );
      },
    );
  }
}

class _AudifyPageTransitionsBuilder extends PageTransitionsBuilder {
  const _AudifyPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.entranceCurve,
      reverseCurve: AppMotion.exitCurve,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.02, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.99, end: 1).animate(curved),
          child: child,
        ),
      ),
    );
  }
}

class AppMotionEntry extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  const AppMotionEntry({
    Key? key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.standard,
    this.offset = const Offset(0, 0.04),
  }) : super(key: key);

  @override
  State<AppMotionEntry> createState() => _AppMotionEntryState();
}

class _AppMotionEntryState extends State<AppMotionEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curved = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.entranceCurve,
      reverseCurve: AppMotion.exitCurve,
    );
    _opacity = curved;
    _slide = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(curved);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class AppPressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  const AppPressScale({
    Key? key,
    required this.child,
    this.onTap,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<AppPressScale> createState() => _AppPressScaleState();
}

class _AppPressScaleState extends State<AppPressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) {
      return;
    }

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
      onTapCancel: widget.enabled ? () => _setPressed(false) : null,
      onTapUp: widget.enabled
          ? (_) {
              _setPressed(false);
              widget.onTap?.call();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: AppMotion.quick,
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: widget.enabled ? 1 : 0.7,
          duration: AppMotion.quick,
          child: widget.child,
        ),
      ),
    );
  }
}
