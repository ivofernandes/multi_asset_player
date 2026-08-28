import 'package:flutter/services.dart';

bool isNetworkSource(String source) {
  final uri = Uri.tryParse(source);
  return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
}

AssetBundle bundleForSource(String source, AssetBundle? bundle) {
  if (isNetworkSource(source)) {
    return NetworkAssetBundle(Uri.parse(source));
  }
  return bundle ?? rootBundle;
}
