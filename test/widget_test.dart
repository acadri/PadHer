import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:padher/main.dart';

void main() {
  testWidgets('PadHer supports staff stock and anonymous request workflows', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final logo = find.byKey(const ValueKey('padher-logo'));
    expect(logo, findsOneWidget);
    expect(
      find.descendant(of: logo, matching: find.byType(CustomPaint)),
      findsOneWidget,
    );

    await tester.tap(find.text('Senior woman teacher'));
    await tester.pumpAndSettle();
    expect(find.text('Teacher sign in'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('account-contact')),
      'teacher@school.ug',
    );
    await tester.enterText(
      find.byKey(const ValueKey('account-password')),
      'demo-password',
    );
    await tester.tap(find.byKey(const ValueKey('submit-access')));
    await tester.pumpAndSettle();

    expect(find.text('PadHer'), findsWidgets);
    expect(find.text('St. Mary\'s Secondary'), findsOneWidget);
    expect(find.text('Stock'), findsOneWidget);
    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);

    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();
    expect(find.text('Log a request'), findsOneWidget);
    expect(
      find.text('No names or personal details are collected.'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Submit request'));
    await tester.tap(find.text('Submit request'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Just now'), findsOneWidget);

    await tester.tap(find.text('Stock'));
    await tester.pumpAndSettle();
    expect(find.text('Stock levels'), findsOneWidget);
    final disposableIncrease = find.byTooltip('Add one packs').first;
    await tester.ensureVisible(disposableIncrease);
    await tester.tap(disposableIncrease);
    await tester.pumpAndSettle();
    expect(find.text('13 packs on hand'), findsOneWidget);
  });

  testWidgets('parent request is routed to the selected area pickup school', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Parent or guardian'));
    await tester.pumpAndSettle();
    expect(find.text('Parent sign in'), findsOneWidget);
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('account-name')),
      'Amina N.',
    );
    await tester.enterText(
      find.byKey(const ValueKey('account-contact')),
      '+256700000000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('account-password')),
      'demo-password',
    );
    await tester.tap(find.byKey(const ValueKey('submit-access')));
    await tester.pumpAndSettle();

    expect(find.text('Pickup support near you'), findsOneWidget);
    await tester.tap(find.text('New request'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('pickup-area-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ediofe').last);
    await tester.pumpAndSettle();
    expect(find.text('Ediofe Girls School'), findsOneWidget);
    final increaseQuantity = find.byTooltip('Increase quantity');
    await tester.ensureVisible(increaseQuantity);
    await tester.tap(increaseQuantity);
    await tester.pumpAndSettle();
    expect(find.text('5'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('pickup-point-details')));
    await tester.pumpAndSettle();
    expect(find.text('Area-based pickup match'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('No names or personal details are needed'),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('submit-home-request')),
    );
    await tester.tap(find.byKey(const ValueKey('submit-home-request')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Request sent to Ediofe Girls School'),
      findsOneWidget,
    );
  });

  testWidgets('teacher can add a school while creating an account', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Senior woman teacher'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('account-name')),
      'Grace Teacher',
    );
    await tester.enterText(
      find.byKey(const ValueKey('account-contact')),
      'grace@school.ug',
    );
    await tester.enterText(
      find.byKey(const ValueKey('account-password')),
      'demo-password',
    );
    await tester.ensureVisible(find.text('Add a school'));
    await tester.tap(find.text('Add a school'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('new-school-name')),
      'Nile View School',
    );
    await tester.tap(find.byKey(const ValueKey('save-school')));
    await tester.pumpAndSettle();
    expect(find.text('Nile View School'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('submit-access')));
    await tester.tap(find.byKey(const ValueKey('submit-access')));
    await tester.pumpAndSettle();
    expect(find.text('Nile View School'), findsOneWidget);
  });
}
