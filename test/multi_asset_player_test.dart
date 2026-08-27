import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_asset_player/multi_asset_player.dart';
import 'package:multi_asset_player/src/media_time.dart';

void main() {
  testWidgets('selects viewers through the single public widget', (tester) async {
    final bundle = _MemoryAssetBundle({
      'notes.txt': 'hello',
      'table.csv': 'name,value\none,1',
      'data.json': '{"name":"one"}',
    });

    for (final entry in <String, Finder>{
      'notes.txt': find.byType(TextField),
      'table.csv': find.byType(DataTable),
      'data.json': find.textContaining('name'),
    }.entries) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiAssetPlayer(entry.key, bundle: bundle),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(entry.value, findsWidgets);
    }
  });

  testWidgets('CSV assets are rendered as tables', (tester) async {
    final bundle = _MemoryAssetBundle({
      'table.csv': 'name,description\none,"includes, comma"',
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiAssetPlayer('table.csv', bundle: bundle),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('includes, comma'), findsOneWidget);
  });

  testWidgets('CSV search highlights matching cell text', (tester) async {
    final bundle = _MemoryAssetBundle({
      'table.csv': 'name,description\none,Searchable value',
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiAssetPlayer('table.csv', bundle: bundle),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'search');
    await tester.pump();

    final matches = tester
        .widgetList<RichText>(find.byType(RichText))
        .expand((text) => text.text.children ?? const <InlineSpan>[])
        .whereType<TextSpan>()
        .where((span) => span.style?.backgroundColor != null)
        .map((span) => span.text);
    expect(matches, contains('Search'));
  });

  testWidgets('text search highlights matches without filtering lines', (
    tester,
  ) async {
    final bundle = _MemoryAssetBundle({
      'notes.txt': 'apples\nbananas\napricots',
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MultiAssetPlayer('notes.txt', bundle: bundle)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('bananas'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'ap');
    await tester.pump();
    expect(find.text('bananas'), findsOneWidget);

    final highlighted = tester
        .widgetList<SelectableText>(find.byType(SelectableText))
        .expand((text) => text.textSpan!.children ?? const <InlineSpan>[])
        .whereType<TextSpan>()
        .where((span) => span.style?.backgroundColor != null)
        .map((span) => span.text)
        .toList();
    expect(highlighted, ['ap', 'ap']);
  });

  testWidgets('structured text extensions use the text viewer', (tester) async {
    for (final extension in [
      'yaml',
      'yml',
      'xml',
      'toml',
      'ini',
      'cfg',
      'conf',
      'properties',
    ]) {
      final asset = 'settings.$extension';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiAssetPlayer(
              asset,
              bundle: _MemoryAssetBundle({asset: 'setting=value'}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget, reason: extension);
    }
  });

  testWidgets('JSON assets are rendered as structured data', (tester) async {
    final bundle = _MemoryAssetBundle({
      'config.json': '{"enabled":true,"items":[1,2]}',
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiAssetPlayer('config.json', bundle: bundle),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('enabled'), findsWidgets);
    expect(find.textContaining('items'), findsWidgets);
    expect(find.textContaining('Unable to parse'), findsNothing);
  });

  testWidgets('JSON search expands and highlights nested matches', (
    tester,
  ) async {
    final bundle = _MemoryAssetBundle({
      'config.json': '{"nested":{"label":"Searchable value"}}',
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiAssetPlayer('config.json', bundle: bundle),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'search');
    await tester.pumpAndSettle();

    final highlighted = tester
        .widgetList<RichText>(find.byType(RichText))
        .expand((text) => text.text.children ?? const <InlineSpan>[])
        .whereType<TextSpan>()
        .where((span) => span.style?.backgroundColor != null)
        .map((span) => span.text);
    expect(highlighted, contains('Search'));
  });

  test('media timer labels elapsed and total time', () {
    expect(
      mediaTimerLabel(
        const Duration(minutes: 2, seconds: 3),
        const Duration(hours: 1, minutes: 4, seconds: 5),
      ),
      '02:03 / 1:04:05',
    );
  });

  testWidgets('invalid JSON assets show a useful error', (tester) async {
    final bundle = _MemoryAssetBundle({'broken.json': '{not json'});
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiAssetPlayer('broken.json', bundle: bundle),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Unable to parse broken.json as JSON'),
      findsOneWidget,
    );
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
