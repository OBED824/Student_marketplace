import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_marketplace_simple/app_state.dart';
import 'package:student_marketplace_simple/main.dart';

void main() {
  testWidgets('app starts, demo login works, tabs open, logout works', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState(await SharedPreferences.getInstance());
    state.load();
    await state.seedIfEmpty();
    await tester.pumpWidget(ChangeNotifierProvider.value(value: state, child: const MarketplaceApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fill demo account'));
    await tester.pump();
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Hi, Aisha'), findsOneWidget);

    for (final tab in ['Favorites', 'My Listings', 'Profile', 'Home']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
  });
}
