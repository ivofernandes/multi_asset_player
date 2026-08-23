import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_asset_player/multi_asset_player.dart';

void main() {
  test('selects a viewer using a case-insensitive extension', () {
    expect(MultiAssetPlayer.typeFor('assets/photo.PNG'), MultiAssetType.image);
    expect(MultiAssetPlayer.typeFor('assets/icon.svg'), MultiAssetType.svg);
    expect(
      MultiAssetPlayer.typeFor('assets/data.json?version=1'),
      MultiAssetType.json,
    );
    expect(MultiAssetPlayer.typeFor('assets/readme.txt'), MultiAssetType.text);
    expect(MultiAssetPlayer.typeFor('assets/demo.HTML'), MultiAssetType.html);
    expect(
      MultiAssetPlayer.typeFor('assets/legacy.htm#section'),
      MultiAssetType.html,
    );
    expect(MultiAssetPlayer.typeFor('assets/manual.pdf'), MultiAssetType.pdf);
    expect(MultiAssetPlayer.typeFor('assets/movie.MP4'), MultiAssetType.video);
    expect(MultiAssetPlayer.typeFor('assets/music.mp3'), MultiAssetType.audio);
    expect(MultiAssetPlayer.typeFor('assets/music.wav'), MultiAssetType.audio);
  });

  testWidgets('text assets can be searched by line', (tester) async {
    final bundle = _MemoryAssetBundle({
      'notes.txt': 'apples\nbananas\napricots',
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MultiAssetPlayer('notes.txt', bundle: bundle)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('apples\nbananas\napricots'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'ap');
    await tester.pump();
    expect(find.text('apples\napricots'), findsOneWidget);
  });

  testWidgets('unsupported assets show a useful message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MultiAssetPlayer('assets/archive.zip')),
      ),
    );
    expect(
      find.text('Unsupported asset type: assets/archive.zip'),
      findsOneWidget,
    );
  });
}

class _MemoryAssetBundle extends CachingAssetBundle {
  _MemoryAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final bytes = Uint8List.fromList(assets[key]!.codeUnits);
    return ByteData.sublistView(bytes);
  }
}
