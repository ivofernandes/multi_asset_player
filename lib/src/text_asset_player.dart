import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'asset_message.dart';

/// Displays a searchable plain-text asset.
class TextAssetPlayer extends StatefulWidget {
  const TextAssetPlayer({super.key, required this.asset, this.bundle});

  final String asset;
  final AssetBundle? bundle;

  @override
  State<TextAssetPlayer> createState() => _SearchableTextAssetState();
}

class _SearchableTextAssetState extends State<TextAssetPlayer> {
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
                return AssetMessage(
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
