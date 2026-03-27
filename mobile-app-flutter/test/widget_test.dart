import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:searchanycars/main.dart';

void main() {
  testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SearchAnyCarsApp()),
    );

    // Verify app renders
    expect(find.byType(MaterialApp), findsOneWidget);

    // Advance past splash screen animations and timer
    for (int i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // App should have navigated to onboarding
    expect(find.byType(Scaffold), findsWidgets);
  });
}
