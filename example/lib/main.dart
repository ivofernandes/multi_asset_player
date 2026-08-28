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
  static const _wideLayoutBreakpoint = 700.0;

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
      appBar: AppBar(
        title: const Text('Multi Asset Player'),
        actions: [
          IconButton(
            tooltip: 'Open URL',
            icon: const Icon(Icons.link),
            onPressed: _openUrl,
          ),
        ],
      ),
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
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < _wideLayoutBreakpoint) {
                return _CompactGallery(
                  assets: assets,
                  selected: selected,
                  bundle: widget.bundle,
                  onSelected: _selectAsset,
                );
              }

              return Row(
                children: [
                  SizedBox(
                    width: 280,
                    child: _AssetList(
                      assets: assets,
                      selected: selected,
                      onSelected: _selectAsset,
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: _playerFor(selected)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _selectAsset(String asset) => setState(() => _selectedAsset = asset);

  Future<void> _openUrl() async {
    var input = (_selectedAsset?.startsWith('http') ?? false)
        ? _selectedAsset!
        : '';
    final formKey = GlobalKey<FormState>();
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open URL'),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: input,
            autofocus: true,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            decoration: const InputDecoration(
              labelText: 'URL',
              hintText: 'https://example.com/image.png',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final uri = Uri.tryParse(value?.trim() ?? '');
              if (uri == null ||
                  !const {'http', 'https'}.contains(uri.scheme) ||
                  uri.host.isEmpty) {
                return 'Enter a valid HTTP or HTTPS URL';
              }
              return null;
            },
            onChanged: (value) => input = value,
            onFieldSubmitted: (value) => _submitUrl(context, formKey, value),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _submitUrl(context, formKey, input),
            child: const Text('Open'),
          ),
        ],
      ),
    );
    if (url != null) _selectAsset(url);
  }

  void _submitUrl(
    BuildContext dialogContext,
    GlobalKey<FormState> formKey,
    String url,
  ) {
    if (formKey.currentState!.validate()) {
      Navigator.pop(dialogContext, url.trim());
    }
  }

  Widget _playerFor(String asset) => MultiAssetPlayer(
    asset,
    key: ValueKey(asset),
    bundle: widget.bundle,
  );
}

class _CompactGallery extends StatelessWidget {
  const _CompactGallery({
    required this.assets,
    required this.selected,
    required this.onSelected,
    this.bundle,
  });

  final List<String> assets;
  final String selected;
  final ValueChanged<String> onSelected;
  final AssetBundle? bundle;

  @override
  Widget build(BuildContext context) {
    final filename = selected.startsWith('assets/')
        ? selected.substring('assets/'.length)
        : selected;
    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: ListTile(
            leading: const Icon(Icons.folder_open_outlined),
            title: Text(filename, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.expand_more),
            onTap: () => _showAssetPicker(context),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: MultiAssetPlayer(
            selected,
            key: ValueKey(selected),
            bundle: bundle,
          ),
        ),
      ],
    );
  }

  Future<void> _showAssetPicker(BuildContext context) async {
    final asset = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (context) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  'Choose an asset',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: _AssetList(
                  assets: assets,
                  selected: selected,
                  onSelected: (asset) => Navigator.pop(context, asset),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (asset != null) onSelected(asset);
  }
}

class _AssetList extends StatelessWidget {
  const _AssetList({
    required this.assets,
    required this.selected,
    required this.onSelected,
  });

  final List<String> assets;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        return ListTile(
          selected: selected == asset,
          leading: const Icon(Icons.insert_drive_file_outlined),
          title: Text(
            asset.substring('assets/'.length),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => onSelected(asset),
        );
      },
    );
  }
}
