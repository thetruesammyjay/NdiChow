import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// Compact progress treatment backed by the bundled Rive asset.
class AppProgressAnimation extends StatelessWidget {
  const AppProgressAnimation({super.key, this.height = 56});

  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Loading',
        child: ExcludeSemantics(
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: const RiveAnimation.asset(
              'assets/animations/login_progress_bar.riv',
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
}
