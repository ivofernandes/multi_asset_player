# Multi Asset Player

`MultiAssetPlayer` is one Flutter widget for displaying common local assets and
HTTP(S) URLs. It selects a suitable viewer from the filename extension:

- PNG, JPEG, GIF, WebP, and BMP files use Flutter's image viewer.
- SVG files use `flutter_svg`.
- JSON files use a searchable, expandable navigation tree.
- HTML and HTM files run in a WebView with JavaScript enabled.
- TXT, Markdown, log, YAML, XML, TOML, INI, config, and properties files use a
  selectable, searchable text viewer.
- CSV files use a searchable, scrollable data table with a dedicated CSV parser.
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

Or pass a URL directly—there is no separate network constructor or setup:

```dart
const MultiAssetPlayer('https://example.com/logo.png')
const MultiAssetPlayer('https://example.com/manual.pdf')
const MultiAssetPlayer('https://example.com/data.json?version=2')
```

Local assets still need to be registered in `pubspec.yaml`; URLs do not.

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

`MultiAssetPlayer` is the package's single public widget. It delegates internally
to the appropriate viewer for the selected file.

Text, CSV, and JSON searches preserve the full content and highlight every
match. Text searches scroll the first match into view, while JSON searches
automatically expand matching branches.
HTML assets are loaded into an embedded WebView, so their markup, CSS, and
JavaScript remain interactive.
JSON is validated before it is displayed; malformed documents produce a clear
error state instead of an empty viewer. Objects and arrays can be expanded and
collapsed without an external JSON-viewer dependency. Video controls include
scrubbing and a play/pause button that stays synchronized with the player's
current state. Audio and video controls show both elapsed and total playback
time.
Use `fit` to control image layout, `package` for assets supplied by another
package, or `bundle` to provide a custom `AssetBundle`.

The example application reads Flutter's generated `AssetManifest` at runtime,
so every file registered beneath its `assets/` directory automatically appears
in the gallery without another hard-coded tab or route.
