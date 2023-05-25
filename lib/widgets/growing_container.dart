import 'dart:math';

import 'package:flutter/material.dart';

double easeOutElastic(double x) {
  const c4 = (2 * pi) / 3;

  return x <= 0
      ? 0
      : x >= 1
          ? 1
          : pow(2, -10 * x) * sin((x * 10 - 0.9) * c4) + 1;
}

class GrowingContainer extends StatefulWidget {
  const GrowingContainer(
      {super.key,
      required this.title,
      required this.startingSize,
      required this.finalSize,
      required this.growingTime,
      required this.fadingTime});

  final String title;
  final double startingSize;
  final double finalSize;
  final Duration growingTime;
  final Duration fadingTime;

  @override
  State<GrowingContainer> createState() => _GrowingContainerState();
}

class _GrowingContainerState extends State<GrowingContainer>
    with TickerProviderStateMixin {
  late int fullAnimationTime =
      widget.growingTime.inSeconds + widget.fadingTime.inSeconds;
  late double growingTimeRatio =
      widget.growingTime.inSeconds / fullAnimationTime;
  late double fadingTimeRatio = widget.fadingTime.inSeconds / fullAnimationTime;

  late AnimationController animationController = AnimationController(
    vsync: this,
    duration: Duration(seconds: fullAnimationTime),
  )..forward();

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  double get _animationSizeValue =>
      min(animationController.value / growingTimeRatio, 1);

  double get _currentSize {
    return widget.startingSize +
        easeOutElastic(_animationSizeValue) *
            (widget.finalSize - widget.startingSize);
  }

  double get _animationOpacityValue {
    if (_animationSizeValue < 1) return 0;
    final sizeOffset = animationController.value / growingTimeRatio;
    return max((animationController.value - sizeOffset) / fadingTimeRatio, 0);
  }

  double get _currentOpacity {
    return 1 - _animationOpacityValue;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (ctx, child) {
        return Text(
          style: TextStyle(
              fontSize: _currentSize,
              color: Colors.white.withOpacity(_currentOpacity)),
          widget.title,
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
