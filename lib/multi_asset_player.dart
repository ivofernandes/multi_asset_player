import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/image_asset_player.dart';
import 'src/svg_asset_player.dart';
import 'src/pdf_asset_player.dart';
import 'src/html_asset_player.dart';
import 'src/video_asset_player.dart';
import 'src/audio_asset_player.dart';
import 'src/text_asset_player.dart';
import 'src/csv_asset_player.dart';
import 'src/json/json_asset_player.dart';
import 'src/asset_message.dart';

export 'src/image_asset_player.dart';
export 'src/svg_asset_player.dart';
export 'src/pdf_asset_player.dart';
export 'src/html_asset_player.dart';
export 'src/video_asset_player.dart';
export 'src/audio_asset_player.dart';
export 'src/text_asset_player.dart';
export 'src/csv_asset_player.dart';
export 'src/json/json_asset_player.dart';
export 'src/json/json_tree_node.dart';

/// The kind of viewer selected for an asset.
enum MultiAssetType {
  image,
  svg,
  text,
  csv,
  json,
  html,
  pdf,
  video,
  audio,
  unsupported,
}

/// Displays a bundled asset with a viewer selected from its file extension.
///
/// Add the file to the application's `flutter.assets` list, then use it with:
///
/// ```dart
/// const MultiAssetPlayer('assets/logo.png')
/// ```
class MultiAssetPlayer extends StatelessWidget {
  const MultiAssetPlayer(
    this.asset, {
    super.key,
    this.bundle,
    this.package,
    this.fit = BoxFit.contain,
  });

  /// The asset key registered in `pubspec.yaml`.
  final String asset;

  /// An optional bundle, primarily useful for custom asset sources and tests.
  final AssetBundle? bundle;

  /// The package containing [asset], when it is not an application asset.
  final String? package;

  /// How raster and SVG images are inscribed into their available space.
  final BoxFit fit;

  /// Determines the viewer used for [asset].
  static MultiAssetType typeFor(String asset) {
    final path = asset.split(RegExp(r'[?#]')).first.toLowerCase();
    final dot = path.lastIndexOf('.');
    final extension = dot < 0 ? '' : path.substring(dot + 1);

    if (const {'png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'}.contains(extension)) {
      return MultiAssetType.image;
    }
    if (extension == 'svg') return MultiAssetType.svg;
    if (extension == 'json') return MultiAssetType.json;
    if (const {'html', 'htm'}.contains(extension)) {
      return MultiAssetType.html;
    }
    if (extension == 'pdf') return MultiAssetType.pdf;
    if (const {'mp4', 'm4v', 'mov', 'webm', 'avi', 'mkv'}.contains(extension)) {
      return MultiAssetType.video;
    }
    if (const {
      'mp3',
      'wav',
      'm4a',
      'aac',
      'ogg',
      'opus',
      'flac',
    }.contains(extension)) {
      return MultiAssetType.audio;
    }
    if (extension == 'csv') return MultiAssetType.csv;
    if (const {'txt', 'md', 'markdown', 'log'}.contains(extension)) {
      return MultiAssetType.text;
    }
    return MultiAssetType.unsupported;
  }

  @override
  Widget build(BuildContext context) {
    switch (typeFor(asset)) {
      case MultiAssetType.image:
        return ImageAssetPlayer(
          asset,
          bundle: bundle,
          package: package,
          fit: fit,
        );
      case MultiAssetType.svg:
        return SvgAssetPlayer(
          asset,
          bundle: bundle,
          package: package,
          fit: fit,
        );
      case MultiAssetType.text:
        return TextAssetPlayer(
          asset: _assetKey(asset, package),
          bundle: bundle,
        );
      case MultiAssetType.csv:
        return CsvAssetPlayer(
          asset: _assetKey(asset, package),
          bundle: bundle,
        );
      case MultiAssetType.json:
        return JsonAssetPlayer(
          asset: _assetKey(asset, package),
          bundle: bundle,
        );
      case MultiAssetType.html:
        return HtmlAssetPlayer(
          asset: _assetKey(asset, package),
          bundle: bundle,
        );
      case MultiAssetType.pdf:
        return PdfAssetPlayer(asset: _assetKey(asset, package));
      case MultiAssetType.video:
        return VideoAssetPlayer(asset: asset, package: package);
      case MultiAssetType.audio:
        return AudioAssetPlayer(asset: _assetKey(asset, package));
      case MultiAssetType.unsupported:
        return AssetMessage(
          icon: Icons.insert_drive_file_outlined,
          message: 'Unsupported asset type: $asset',
        );
    }
  }

  static String _assetKey(String asset, String? package) {
    return package == null ? asset : 'packages/$package/$asset';
  }
}
