import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

/// Displays a PDF asset with page navigation and zoom controls.
class PdfAssetPlayer extends StatelessWidget {
  const PdfAssetPlayer({
    super.key,
    required this.asset,
    this.network = false,
  });

  final String asset;
  final bool network;

  @override
  Widget build(BuildContext context) => network
      ? PdfViewer.uri(Uri.parse(asset))
      : PdfViewer.asset(asset);
}
