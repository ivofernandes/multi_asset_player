import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'asset_message.dart';

/// Displays an HTML asset in an interactive WebView.
class HtmlAssetPlayer extends StatefulWidget {
  const HtmlAssetPlayer({
    super.key,
    required this.asset,
    this.bundle,
    this.network = false,
  });

  final String asset;
  final AssetBundle? bundle;
  final bool network;

  @override
  State<HtmlAssetPlayer> createState() => _HtmlAssetState();
}

class _HtmlAssetState extends State<HtmlAssetPlayer> {
  late final Future<WebViewController> _controller = _initialize();

  Future<WebViewController> _initialize() async {
    final controller = WebViewController();
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setBackgroundColor(Colors.transparent);
    if (widget.network) {
      await controller.loadRequest(Uri.parse(widget.asset));
    } else {
      final html = await (widget.bundle ?? rootBundle).loadString(widget.asset);
      await controller.loadHtmlString(html);
    }
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _controller,
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
        return WebViewWidget(controller: snapshot.data!);
      },
    );
  }
}
