import 'package:flutter/material.dart';
import '../spacing/ds_spacing.dart';
import '../typography/ds_text_style.dart';

/// Type de loader du Design System
enum DSLoaderType {
  circular,
  linear,
  dots,
  pulse,
}

/// Loader du Design System
class DSLoader extends StatelessWidget {
  final DSLoaderType type;
  final String? message;
  final Color? color;
  final double size;

  const DSLoader({
    super.key,
    this.type = DSLoaderType.circular,
    this.message,
    this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loaderColor = color ?? theme.colorScheme.primary;

    Widget loader;

    switch (type) {
      case DSLoaderType.circular:
        loader = SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
          ),
        );
        break;
      case DSLoaderType.linear:
        loader = SizedBox(
          width: size * 3,
          child: LinearProgressIndicator(
            color: loaderColor,
          ),
        );
        break;
      case DSLoaderType.dots:
        loader = _DotsLoader(color: loaderColor, size: size);
        break;
      case DSLoaderType.pulse:
        loader = _PulseLoader(color: loaderColor, size: size);
        break;
    }

    if (message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loader,
          const SizedBox(height: DSSpacing.md),
          Text(
            message!,
            style: DSTextStyle.bodyMedium,
          ),
        ],
      );
    }

    return loader;
  }
}

/// Loader avec points animés
class _DotsLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _DotsLoader({required this.color, required this.size});

  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final value = (_controller.value + delay) % 1.0;
              final scale = 0.5 + 0.5 * (1 - (value - 0.5).abs() * 2);
              return Transform.scale(
                scale: scale.clamp(0.5, 1.0),
                child: Container(
                  width: widget.size / 4,
                  height: widget.size / 4,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// Loader avec effet pulse
class _PulseLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _PulseLoader({required this.color, required this.size});

  @override
  State<_PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<_PulseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
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
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _animation.value * 0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: widget.size * _animation.value,
              height: widget.size * _animation.value,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
