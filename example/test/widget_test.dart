import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('discovers example assets from the generated manifest', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Asset manifest gallery'), findsOneWidget);
    expect(find.text('logo.png'), findsOneWidget);
    expect(find.text('logo.png.pdf'), findsOneWidget);
    expect(find.text('config.json'), findsOneWidget);
  });
}
