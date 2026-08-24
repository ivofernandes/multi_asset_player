import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('discovers example assets from the generated manifest', (
    tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Asset manifest gallery'), findsOneWidget);
    expect(find.text('logo.png'), findsOneWidget);
    expect(find.text('logo.png.pdf'), findsOneWidget);
    expect(find.text('config.json'), findsOneWidget);
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
