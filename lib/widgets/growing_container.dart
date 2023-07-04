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
  const GrowingContainer({
    super.key,
    required this.startingSize,
    required this.finalSize,
    required this.growingTime,
    required this.fadingTime,
    required this.backgroundColor,
  });

  final double startingSize;
  final double finalSize;
  final Duration growingTime;
  final Duration fadingTime;
  final Color backgroundColor;

  @override
  State<GrowingContainer> createState() => GrowingContainerState();
}

class GrowingContainerState extends State<GrowingContainer>
    with TickerProviderStateMixin {
  String? _text;

  late int fullAnimationTime =
      widget.growingTime.inMilliseconds + widget.fadingTime.inMilliseconds;

  late double startingGrowingNormalizedTime = 0;
  late double endingGrowingNormalizedTime =
      widget.growingTime.inMilliseconds / fullAnimationTime;

  late double startingFadingNormalizedTime = endingGrowingNormalizedTime;
  late double endingFadingNormalizedTime = 1;

  late AnimationController animationController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: fullAnimationTime),
  );

  void showMessage(String message) {
    if (animationController.isAnimating) return;

    _text = message;
    animationController.forward();
    setState(() {});

    // Remove the message after the animation is done
    Future.delayed(Duration(milliseconds: fullAnimationTime)).then((value) {
      _text = null;
      animationController.reset();
      setState(() {});
      return;
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  double get _animationSizeValue =>
      min(animationController.value / endingGrowingNormalizedTime, 1);

  double get _currentSize {
    return widget.startingSize +
        easeOutElastic(_animationSizeValue) *
            (widget.finalSize - widget.startingSize);
  }

  double get _animationOpacityValue {
    final sizeOffset = animationController.value - endingGrowingNormalizedTime;
    return max(
        sizeOffset /
            (endingFadingNormalizedTime - startingFadingNormalizedTime),
        0);
  }

  double get _currentOpacity {
    return 1 - _animationOpacityValue;
  }

  @override
  Widget build(BuildContext context) {
    // We have to copy because of race condition
    final text = _text;

    return text == null
        ? Container()
        : AnimatedBuilder(
            animation: animationController,
            builder: (ctx, child) {
              return Container(
                decoration: BoxDecoration(
                    color: widget.backgroundColor
                        .withOpacity(max(_currentOpacity - 0.2, 0))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    style: TextStyle(
                        fontSize: _currentSize,
                        color: Colors.white.withOpacity(_currentOpacity)),
                    textAlign: TextAlign.center,
                    text,
                  ),
                ),
              );
            },
          );
  }
}
