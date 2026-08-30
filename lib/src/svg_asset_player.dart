import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Displays an SVG asset.
class SvgAssetPlayer extends StatelessWidget {
  const SvgAssetPlayer(
    this.asset, {
    super.key,
    this.bundle,
    this.package,
    this.fit = BoxFit.contain,
    this.network = false,
  });

  final String asset;
  final AssetBundle? bundle;
  final String? package;
  final BoxFit fit;
  final bool network;

  @override
  Widget build(BuildContext context) {
    Widget placeholder(BuildContext context) =>
        const Center(child: CircularProgressIndicator());

    return network
        ? SvgPicture.network(asset, fit: fit, placeholderBuilder: placeholder)
        : SvgPicture.asset(
            asset,
            bundle: bundle,
            package: package,
            fit: fit,
            placeholderBuilder: placeholder,
          );
  }
}
