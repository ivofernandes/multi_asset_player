import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../asset_message.dart';
import 'json_tree_node.dart';

/// Displays JSON as a recursively expandable navigation tree.
class JsonAssetPlayer extends StatefulWidget {
  const JsonAssetPlayer({super.key, required this.asset, this.bundle});

  final String asset;
  final AssetBundle? bundle;

  @override
  State<JsonAssetPlayer> createState() => _JsonAssetState();
}

class _JsonAssetState extends State<JsonAssetPlayer> {
  late final Future<Object?> _content;

  @override
  void initState() {
    super.initState();
    _content = _loadJson();
  }

  Future<Object?> _loadJson() async {
    final source = await (widget.bundle ?? rootBundle).loadString(widget.asset);
    return jsonDecode(source);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object?>(
      future: _content,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AssetMessage(
            icon: Icons.error_outline,
            message: 'Unable to parse ${widget.asset} as JSON',
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: JsonTreeNode(value: snapshot.data, expanded: true),
        );
      },
    );
  }
}
