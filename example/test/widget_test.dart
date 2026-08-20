import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a tab for every example asset type', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.byType(Tab), findsNWidgets(4));
    expect(find.text('Image'), findsOneWidget);
    expect(find.text('SVG'), findsOneWidget);
    expect(find.text('Text'), findsOneWidget);
    expect(find.text('JSON'), findsOneWidget);
  });
}
