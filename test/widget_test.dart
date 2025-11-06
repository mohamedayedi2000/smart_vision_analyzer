import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_vision_analyzer/app/app.dart';

void main() {
  testWidgets('App builds correctly', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const App());

    // Verify the app loaded the HomeScreen (or something visible)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
