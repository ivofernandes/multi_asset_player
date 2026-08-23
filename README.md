# Multi Asset Player

`MultiAssetPlayer` is one Flutter widget for displaying several common bundled
asset formats. It selects a suitable viewer from the filename extension:

- PNG, JPEG, GIF, WebP, and BMP files use Flutter's image viewer.
- SVG files use `flutter_svg`.
- JSON files use an expandable structured `json_view` viewer.
- HTML and HTM files run in a WebView with JavaScript enabled.
- TXT, Markdown, CSV, and log files use a selectable, searchable text viewer.
- PDF files use an interactive document viewer.
- MP4, M4V, MOV, WebM, AVI, and MKV files use a video player.
- MP3, WAV, M4A, AAC, Ogg, Opus, and FLAC files use an audio player.

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
const MultiAssetPlayer('assets/demo.html')
const MultiAssetPlayer('assets/manual.pdf')
const MultiAssetPlayer('assets/demo.mp4')
const MultiAssetPlayer('assets/song.mp3')
```

Text files include a search box that filters the document to matching lines.
HTML assets are loaded into an embedded WebView, so their markup, CSS, and
JavaScript remain interactive.
Use `fit` to control image layout, `package` for assets supplied by another
package, or `bundle` to provide a custom `AssetBundle`.

The example application reads Flutter's generated `AssetManifest` at runtime,
so every file registered beneath its `assets/` directory automatically appears
in the gallery without another hard-coded tab or route.
