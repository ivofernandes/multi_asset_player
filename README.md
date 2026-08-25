# Multi Asset Player

`MultiAssetPlayer` is one Flutter widget for displaying several common bundled
asset formats. It selects a suitable viewer from the filename extension:

- PNG, JPEG, GIF, WebP, and BMP files use Flutter's image viewer.
- SVG files use `flutter_svg`.
- JSON files use a built-in expandable navigation tree.
- HTML and HTM files run in a WebView with JavaScript enabled.
- TXT, Markdown, and log files use a selectable, searchable text viewer.
- CSV files use a scrollable data table with a dedicated CSV parser.
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

`MultiAssetPlayer` delegates to a dedicated public widget for each format:
`ImageAssetPlayer`, `SvgAssetPlayer`, `TextAssetPlayer`, `CsvAssetPlayer`,
`JsonAssetPlayer`, `HtmlAssetPlayer`, `PdfAssetPlayer`, `VideoAssetPlayer`, or
`AudioAssetPlayer`. These widgets can also be used directly when the asset type
is already known. Each player has its own implementation file under `lib/src/`;
the JSON player uses a subfolder so its loader and recursive tree node remain
separate.

Text files include a search box that filters the document to matching lines.
HTML assets are loaded into an embedded WebView, so their markup, CSS, and
JavaScript remain interactive.
JSON is validated before it is displayed; malformed documents produce a clear
error state instead of an empty viewer. Objects and arrays can be expanded and
collapsed without an external JSON-viewer dependency. Video controls include
scrubbing and a play/pause button that stays synchronized with the player's
current state.
Use `fit` to control image layout, `package` for assets supplied by another
package, or `bundle` to provide a custom `AssetBundle`.

The example application reads Flutter's generated `AssetManifest` at runtime,
so every file registered beneath its `assets/` directory automatically appears
in the gallery without another hard-coded tab or route.
