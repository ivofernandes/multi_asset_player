import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

/// Displays a PDF asset with page navigation and zoom controls.
class PdfAssetPlayer extends StatelessWidget {
  const PdfAssetPlayer({super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) => PdfViewer.asset(asset);
}
