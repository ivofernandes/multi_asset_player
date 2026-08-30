import 'package:flutter/material.dart';

import 'asset_message.dart';

/// Displays a raster image asset.
class ImageAssetPlayer extends StatelessWidget {
  const ImageAssetPlayer(
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
  Widget build(BuildContext context) => Image(
    image: network
        ? NetworkImage(asset)
        : AssetImage(asset, bundle: bundle, package: package),
    fit: fit,
    errorBuilder: (_, _, _) => AssetMessage(
      icon: Icons.broken_image_outlined,
      message: 'Unable to load $asset',
    ),
  );
}
