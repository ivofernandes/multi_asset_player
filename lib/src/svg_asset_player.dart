import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Displays an SVG asset.
class SvgAssetPlayer extends StatelessWidget {
  const SvgAssetPlayer(
    this.asset, {
    super.key,
    this.bundle,
    this.package,
    this.fit = BoxFit.contain,
  });

  final String asset;
  final AssetBundle? bundle;
  final String? package;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    asset,
    bundle: bundle,
    package: package,
    fit: fit,
    placeholderBuilder: (_) => const Center(child: CircularProgressIndicator()),
  );
}
