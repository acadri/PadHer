import 'package:flutter_test/flutter_test.dart';

import 'package:padher/main.dart';

void main() {
  testWidgets('PadHer supports staff stock and anonymous request workflows', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

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
}
