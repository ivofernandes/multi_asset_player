import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:json_view/json_view.dart';

/// The kind of viewer selected for an asset.
enum MultiAssetType { image, svg, text, json, unsupported }

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
    if (const {'txt', 'md', 'markdown', 'csv', 'log'}.contains(extension)) {
      return MultiAssetType.text;
    }
    return MultiAssetType.unsupported;
  }

  @override
  Widget build(BuildContext context) {
    switch (typeFor(asset)) {
      case MultiAssetType.image:
        return Image.asset(
          asset,
          bundle: bundle,
          package: package,
          fit: fit,
          errorBuilder: _errorBuilder,
        );
      case MultiAssetType.svg:
        return SvgPicture.asset(
          asset,
          bundle: bundle,
          package: package,
          fit: fit,
          placeholderBuilder: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      case MultiAssetType.text:
        return _SearchableTextAsset(
          asset: _assetKey(asset, package),
          bundle: bundle,
        );
      case MultiAssetType.json:
        return _JsonAsset(asset: _assetKey(asset, package), bundle: bundle);
      case MultiAssetType.unsupported:
        return _AssetMessage(
          icon: Icons.insert_drive_file_outlined,
          message: 'Unsupported asset type: $asset',
        );
    }
  }

  static String _assetKey(String asset, String? package) {
    return package == null ? asset : 'packages/$package/$asset';
  }

  Widget _errorBuilder(BuildContext context, Object error, StackTrace? stack) {
    return _AssetMessage(
      icon: Icons.broken_image_outlined,
      message: 'Unable to load $asset',
    );
  }
}

class _SearchableTextAsset extends StatefulWidget {
  const _SearchableTextAsset({required this.asset, this.bundle});

  final String asset;
  final AssetBundle? bundle;

  @override
  State<_SearchableTextAsset> createState() => _SearchableTextAssetState();
}

class _SearchableTextAssetState extends State<_SearchableTextAsset> {
  late final Future<String> _content;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _content = (widget.bundle ?? rootBundle).loadString(widget.asset);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Search text',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          child: FutureBuilder<String>(
            future: _content,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _AssetMessage(
                  icon: Icons.error_outline,
                  message: 'Unable to load ${widget.asset}',
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final text = snapshot.data!;
              final matches = _query.isEmpty
                  ? text
                  : text
                        .split('\n')
                        .where(
                          (line) => line.toLowerCase().contains(
                            _query.toLowerCase(),
                          ),
                        )
                        .join('\n');
              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  matches,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _JsonAsset extends StatefulWidget {
  const _JsonAsset({required this.asset, this.bundle});

  final String asset;
  final AssetBundle? bundle;

  @override
  State<_JsonAsset> createState() => _JsonAssetState();
}

class _JsonAssetState extends State<_JsonAsset> {
  late final Future<String> _content;

  @override
  void initState() {
    super.initState();
    _content = (widget.bundle ?? rootBundle).loadString(widget.asset);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _content,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _AssetMessage(
            icon: Icons.error_outline,
            message: 'Unable to load ${widget.asset}',
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: JsonView(json: snapshot.data!),
        );
      },
    );
  }
}

class _AssetMessage extends StatelessWidget {
  const _AssetMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
