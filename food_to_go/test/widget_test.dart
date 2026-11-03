// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_to_go/account_type.dart';
import 'package:food_to_go/auth_screen.dart';
import 'package:food_to_go/home_screen.dart';
import 'package:food_to_go/main.dart';

void main() {
  test('only USJ-R email addresses are allowed', () {
    expect(isUsjrEmail('student@usjr.edu.ph'), isTrue);
    expect(isUsjrEmail('STUDENT@USJR.EDU.PH'), isTrue);
    expect(isUsjrEmail('student@gmail.com'), isFalse);
    expect(isUsjrEmail('student@usjr.edu.ph.example.com'), isFalse);
  });

  testWidgets('shows login and account creation options', (tester) async {
    await tester.pumpWidget(const FoodToGoApp(supabaseConfigured: false));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('USJ-R email'), findsOneWidget);
    expect(find.text('Food stall'), findsNothing);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('New here? Create an account'), findsOneWidget);
    await tester.tap(find.text('New here? Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
    expect(find.text('Regular'), findsOneWidget);
    expect(find.text('Food stall'), findsOneWidget);
    expect(find.text('For students and professors'), findsOneWidget);

    await tester.tap(find.text('Food stall'));
    await tester.pumpAndSettle();
    expect(find.text('For food stall accounts'), findsOneWidget);
  });

  testWidgets('home screen displays the signed-in account', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(
          email: 'student@usjr.edu.ph',
          accountType: AccountType.regular,
        ),
      ),
    );

    expect(find.text('Food to Go'), findsOneWidget);
    expect(find.text('Signed in as student@usjr.edu.ph'), findsOneWidget);
    expect(find.text('Find your next meal'), findsOneWidget);
    expect(find.text('Available stalls'), findsOneWidget);
    expect(find.text('No stalls available yet'), findsOneWidget);
    expect(find.text('Your orders'), findsNothing);
    expect(find.byTooltip('Log out'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('food stall account gets its own dashboard', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(
          email: 'stall@usjr.edu.ph',
          accountType: AccountType.foodStall,
        ),
      ),
    );

    expect(find.text('Manage your food stall.'), findsOneWidget);
    expect(find.text('Incoming orders'), findsOneWidget);
    expect(find.text('No incoming orders'), findsOneWidget);
  });
}
