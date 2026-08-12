import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders an offline icon from the bundled Basil icon set.
///
/// [icon] is the filename without the `.svg` suffix, such as
/// `home-outline`, `shopping-cart-solid`, or `location-outline`.
class BasilIcon extends StatelessWidget {
  const BasilIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  final String icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final resolvedSize = size ?? iconTheme.size ?? 24;
    final resolvedColor = color ?? iconTheme.color;

    return SvgPicture.asset(
      'assets/icons/basil/$icon.svg',
      width: resolvedSize,
      height: resolvedSize,
      semanticsLabel: semanticLabel,
      colorFilter: resolvedColor == null
          ? null
          : ColorFilter.mode(resolvedColor, BlendMode.srcIn),
    );
  }
}
