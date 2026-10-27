import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:padher/authentication_service.dart';
import 'package:padher/main.dart';

void main() {
  testWidgets('GitHub sign-in is required before opening the parent portal', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final authenticationService = _FakeAuthenticationService();
    await tester.pumpWidget(
      MyApp(authenticationService: authenticationService),
    );

    await tester.tap(find.text('Parent or guardian'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('submit-access')));
    await tester.pumpAndSettle();

    expect(authenticationService.signInAttempts, 1);
    expect(find.text('Pickup support near you'), findsOneWidget);
  });

  testWidgets('GitHub accounts without staff approval cannot open teacher portal', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final authenticationService = _FakeAuthenticationService();
    await tester.pumpWidget(
      MyApp(authenticationService: authenticationService),
    );

    await tester.tap(find.text('Senior woman teacher'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('submit-access')));
    await tester.pumpAndSettle();

    expect(authenticationService.signInAttempts, 1);
    expect(find.text('Staff access has not been approved for this account.'), findsOneWidget);
    expect(find.text('Stock'), findsNothing);
  });

  testWidgets('PodCare supports staff stock and anonymous request workflows', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());

    final logo = find.byKey(const ValueKey('podcare-logo'));
    expect(logo, findsOneWidget);
    expect(
      find.descendant(of: logo, matching: find.byType(Image)),
      findsOneWidget,
    );

    await tester.tap(find.text('Senior woman teacher'));
    await tester.pumpAndSettle();
    expect(find.text('Teacher preview'), findsOneWidget);
    expect(find.byKey(const ValueKey('account-contact')), findsNothing);
    expect(find.byKey(const ValueKey('account-password')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('submit-access')));
    await tester.pumpAndSettle();

    expect(find.text('PodCare'), findsWidgets);
    expect(find.text('St. Mary\'s Secondary'), findsOneWidget);
    expect(find.text('Stock'), findsOneWidget);
    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('sign-out-control'))),
      const Size(48, 48),
    );

    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();
    expect(
      find.text('Review requests'),
      findsOneWidget,
    );
    expect(
      find.text('No requests are saved for this school on this device.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Stock'));
    await tester.pumpAndSettle();
    expect(find.text('Stock levels'), findsOneWidget);
    expect(find.text('42 kits on hand'), findsOneWidget);
    final disposableIncrease = find.byTooltip('Add one packs').first;
    await tester.ensureVisible(disposableIncrease);
    await tester.tap(disposableIncrease);
    await tester.pumpAndSettle();
    expect(find.text('13 packs on hand'), findsOneWidget);
  });

  testWidgets('parent request is routed to the selected area pickup school', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Parent or guardian'));
    await tester.pumpAndSettle();
    expect(find.text('Parent preview'), findsOneWidget);
    expect(find.byKey(const ValueKey('account-contact')), findsNothing);
    expect(find.byKey(const ValueKey('account-password')), findsNothing);
    await tester.tap(find.text('Set a display name'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('account-name')),
      'Amina N.',
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
    expect(find.bySemanticsLabel('Quantity: 5 packs'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const ValueKey('pickup-point-details')),
    );
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
    expect(find.text('Pending review'), findsOneWidget);
    expect(find.text('Stock'), findsNothing);
    expect(find.textContaining('not sent over the network'), findsOneWidget);
    expect(find.textContaining('Ediofe Girls School (Ediofe)'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    final savedRequests = preferences.getString('padher.localState.v1');
    expect(savedRequests, contains('Ediofe Girls School'));
    expect(savedRequests, contains('Disposable pads'));
    expect(savedRequests, isNot(contains('Amina N.')));
    expect(savedRequests, isNot(contains('+256700000000')));

    await tester.tap(find.byTooltip('Delete saved request'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Request PH-'), findsNothing);
    expect(
      preferences.getString('padher.localState.v1'),
      equals('{"requests":[],"stock":{}}'),
    );
  });

  testWidgets('expired local requests are removed after 30 days', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'padher.localRequests.v1':
          '[{"id":"old","reference":"PH-1234","school":"Oli Primary School","area":"Oli","product":"Disposable pads","quantity":4,"createdAt":"2020-01-01T00:00:00.000"}]',
    });
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Parent or guardian'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('submit-access')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString('padher.localState.v1'),
      equals('{"requests":[],"stock":{}}'),
    );
    expect(preferences.getString('padher.localRequests.v1'), isNull);
    expect(find.text('No saved requests on this device yet.'), findsOneWidget);
  });

  testWidgets('parent request is reviewed and fulfilled by its school', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Parent or guardian'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('submit-access')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New request'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('submit-home-request')),
    );
    await tester.tap(find.byKey(const ValueKey('submit-home-request')));
    await tester.pumpAndSettle();
    expect(find.text('Pending review'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    final storedData = jsonDecode(
      preferences.getString('padher.localState.v1')!,
    ) as Map<String, dynamic>;
    final request = (storedData['requests'] as List).single as Map;
    final requestId = request['id'] as String;
    expect(request['school'], 'Oli Primary School');

    await tester.tap(find.byKey(const ValueKey('sign-out-control')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Senior woman teacher'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('teacher-school-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ediofe Girls School').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('submit-access')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();
    expect(
      find.text('No requests are saved for this school on this device.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('sign-out-control')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Senior woman teacher'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('teacher-school-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oli Primary School').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('submit-access')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();

    expect(find.byKey(ValueKey('teacher-request-$requestId')), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('approve-request-$requestId')));
    await tester.pumpAndSettle();
    expect(
      find.text('8 packs available after other reservations'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(ValueKey('ready-request-$requestId')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('collect-request-$requestId')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stock'));
    await tester.pumpAndSettle();
    expect(find.text('8 packs on hand'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('sign-out-control')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Parent or guardian'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('submit-access')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    expect(find.text('Collected'), findsOneWidget);
    expect(find.byTooltip('Delete saved request'), findsNothing);
  });

  testWidgets('teacher can add a school while creating an account', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Senior woman teacher'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Set a display name'));
    await tester.tap(find.text('Set a display name'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('account-name')),
      'Grace Teacher',
    );
    await tester.ensureVisible(find.text('Add a school'));
    await tester.tap(find.text('Add a school'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('teacher-school-dropdown')), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('new-school-name')),
      'Nile View School',
    );
    await tester.tap(find.byKey(const ValueKey('save-school')));
    await tester.pumpAndSettle();
    expect(find.text('Nile View School'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('teacher-school-dropdown')),
      findsOneWidget,
    );

    await tester.ensureVisible(find.byKey(const ValueKey('submit-access')));
    await tester.tap(find.byKey(const ValueKey('submit-access')));
    await tester.pumpAndSettle();
    expect(find.text('Nile View School'), findsOneWidget);
  });
}

class _FakeAuthenticationService implements AuthenticationService {
  bool _signedIn = false;
  int signInAttempts = 0;

  @override
  AuthenticatedUser? get currentUser => _signedIn
      ? const AuthenticatedUser(
          uid: 'test-user',
          displayName: 'Test Parent',
          email: 'parent@example.com',
        )
      : null;

  @override
  Future<AuthenticatedUser> signInWithGitHub() async {
    signInAttempts++;
    _signedIn = true;
    return currentUser!;
  }

  @override
  Future<bool> hasTeacherAccess() async => false;

  @override
  Future<void> signOut() async {
    _signedIn = false;
  }
}
