import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('discovers example assets from the generated manifest', (
    tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Multi Asset Player'), findsOneWidget);
    expect(find.text('logo.png'), findsOneWidget);
    expect(find.text('logo.png.pdf'), findsOneWidget);
    expect(find.text('config.json'), findsOneWidget);
  });

  testWidgets('opens a URL entered in the app bar', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open URL'));
    await tester.pumpAndSettle();
    expect(find.text('Open URL'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField),
      'https://example.com/photo.png',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Open'));
    await tester.pumpAndSettle();

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses an asset picker on narrow screens', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('logo.png'), findsNothing);
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    expect(find.text('Choose an asset'), findsOneWidget);
    expect(find.text('config.json'), findsOneWidget);
  });
}
