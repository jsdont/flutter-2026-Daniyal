import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screens_lead/main.dart';

Future<void> openEdit(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Edit'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Dirty Back keeps the draft or discards it without saving', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aida Akhmetova'));
    await tester.pumpAndSettle();
    await openEdit(tester);
    await tester.enterText(find.byType(TextField), 'Draft name');
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Draft name'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Aida Akhmetova'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Save returns a name and clean Back returns no change', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsNothing);
    await tester.tap(find.text('Aida Akhmetova'));
    await tester.pumpAndSettle();
    expect(find.text('aida@kbtu.kz'), findsOneWidget);
    await openEdit(tester);
    await tester.enterText(find.byType(TextField), 'Aida Updated');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Aida Updated'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    await openEdit(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Aida Updated'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Returning from detail preserves the list scroll position', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
    final offset = scroll.position.pixels;
    expect(offset, greaterThan(0));
    await tester.tap(find.text('Yerlan Sadyk'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(scroll.position.pixels, offset);
    expect(find.text('Yerlan Sadyk'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
