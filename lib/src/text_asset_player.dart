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
  final _firstMatchKey = GlobalKey();
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
            onChanged: _search,
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

              final lines = snapshot.data!.split('\n');
              var foundFirstMatch = false;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: lines.map((line) {
                    final matches = _query.isNotEmpty &&
                        line.toLowerCase().contains(_query.toLowerCase());
                    final isFirstMatch = matches && !foundFirstMatch;
                    foundFirstMatch |= matches;
                    return SelectableText.rich(
                      key: isFirstMatch ? _firstMatchKey : null,
                      TextSpan(children: _highlightedSpans(context, line)),
                      style: const TextStyle(fontFamily: 'monospace'),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _search(String value) {
    setState(() => _query = value);
    if (value.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final matchContext = _firstMatchKey.currentContext;
      if (matchContext != null) {
        Scrollable.ensureVisible(
          matchContext,
          duration: const Duration(milliseconds: 200),
          alignment: 0.15,
        );
      }
    });
  }

  List<InlineSpan> _highlightedSpans(BuildContext context, String text) {
    if (_query.isEmpty) return [TextSpan(text: text)];

    final spans = <InlineSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = _query.toLowerCase();
    var start = 0;
    while (true) {
      final match = lowerText.indexOf(lowerQuery, start);
      if (match < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (match > start) {
        spans.add(TextSpan(text: text.substring(start, match)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match, match + _query.length),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onTertiaryContainer,
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = match + _query.length;
    }
    return spans;
  }
}
