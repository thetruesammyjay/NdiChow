import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum AppAnimationType { loading, success, failure, done, welcome }

/// Centralized renderer for the app's bundled Lottie animations.
class AppAnimation extends StatelessWidget {
  const AppAnimation(
    this.type, {
    super.key,
    this.size = 120,
    this.repeat,
    this.semanticLabel,
  });

  final AppAnimationType type;
  final double size;
  final bool? repeat;
  final String? semanticLabel;

  static const _assets = <AppAnimationType, String>{
    AppAnimationType.loading: 'assets/animations/lottie/loading.json',
    AppAnimationType.success: 'assets/animations/lottie/success.json',
    AppAnimationType.failure: 'assets/animations/lottie/Failed.json',
    AppAnimationType.done: 'assets/animations/lottie/done.json',
    AppAnimationType.welcome: 'assets/animations/lottie/lottie.json',
  };

  @override
  Widget build(BuildContext context) {
    final shouldRepeat = repeat ?? type == AppAnimationType.loading;
    return Semantics(
      image: true,
      label: semanticLabel ?? _defaultLabel(type),
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: Lottie.asset(
            _assets[type]!,
            fit: BoxFit.contain,
            repeat: shouldRepeat,
          ),
        ),
      ),
    );
  }

  String _defaultLabel(AppAnimationType value) => switch (value) {
    AppAnimationType.loading => 'Loading',
    AppAnimationType.success => 'Success',
    AppAnimationType.failure => 'Something went wrong',
    AppAnimationType.done => 'Complete',
    AppAnimationType.welcome => 'Welcome',
  };
}
