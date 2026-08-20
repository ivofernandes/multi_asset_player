# Multi Asset Player

`MultiAssetPlayer` is one Flutter widget for displaying several common bundled
asset formats. It selects a suitable viewer from the filename extension:

- PNG, JPEG, GIF, WebP, and BMP files use Flutter's image viewer.
- SVG files use `flutter_svg`.
- JSON files use an expandable structured `json_view` viewer.
- TXT, Markdown, CSV, and log files use a selectable, searchable text viewer.

## Getting started

Register assets in the consuming application's `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/
```

Then place a viewer anywhere in the widget tree:

```dart
import 'package:multi_asset_player/multi_asset_player.dart';

const MultiAssetPlayer('assets/logo.png')
```

The same API works for every supported format:

```dart
const MultiAssetPlayer('assets/logo.svg')
const MultiAssetPlayer('assets/readme.txt')
const MultiAssetPlayer('assets/config.json')
```

Text files include a search box that filters the document to matching lines.
Use `fit` to control image layout, `package` for assets supplied by another
package, or `bundle` to provide a custom `AssetBundle`.
