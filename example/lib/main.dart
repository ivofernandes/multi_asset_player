import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_asset_player/multi_asset_player.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi Asset Player',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const AssetGallery(),
    );
  }
}

/// Discovers every bundled example asset from Flutter's generated manifest.
class AssetGallery extends StatefulWidget {
  const AssetGallery({super.key, this.bundle});

  final AssetBundle? bundle;

  @override
  State<AssetGallery> createState() => _AssetGalleryState();
}

class _AssetGalleryState extends State<AssetGallery> {
  late final Future<List<String>> _assets = _loadAssets();
  String? _selectedAsset;

  Future<List<String>> _loadAssets() async {
    final manifest = await AssetManifest.loadFromAssetBundle(
      widget.bundle ?? rootBundle,
    );
    return manifest
        .listAssets()
        .where((asset) => asset.startsWith('assets/'))
        .toList()
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asset manifest gallery')),
      body: FutureBuilder<List<String>>(
        future: _assets,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Unable to read AssetManifest: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final assets = snapshot.data!;
          if (assets.isEmpty) {
            return const Center(child: Text('No files were found in assets/'));
          }
          final selected = _selectedAsset ?? assets.first;
          return Row(
            children: [
              SizedBox(
                width: 260,
                child: ListView.builder(
                  itemCount: assets.length,
                  itemBuilder: (context, index) {
                    final asset = assets[index];
                    return ListTile(
                      selected: selected == asset,
                      title: Text(asset.substring('assets/'.length)),
                      subtitle: Text(MultiAssetPlayer.typeFor(asset).name),
                      onTap: () => setState(() => _selectedAsset = asset),
                    );
                  },
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: MultiAssetPlayer(
                  selected,
                  key: ValueKey(selected),
                  bundle: widget.bundle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
