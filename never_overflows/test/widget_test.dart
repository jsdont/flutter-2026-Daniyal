import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:never_overflows/contact_card.dart';
import 'package:never_overflows/contacts.dart';
import 'package:never_overflows/main.dart';

void main() {
  testWidgets('Long names fit narrow, landscape and enlarged-text screens', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    for (final size in [const Size(320, 700), const Size(800, 400)]) {
      tester.view.physicalSize = size;
      for (final scale in [1.0, 2.0]) {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(child: ContactCard(contact: contacts[4])),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final name = tester.getRect(find.text(contacts[4].name));
        final chevron = tester.getRect(find.byIcon(Icons.chevron_right));
        expect(name.right, lessThanOrEqualTo(chevron.left));
        expect(chevron.right, lessThanOrEqualTo(size.width));
      }
    }
  });

  testWidgets('All twenty contacts can be reached and scrolled back', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(contacts, hasLength(20));
    expect(find.text('20 contacts'), findsOneWidget);
    final seen = <String>{};
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    for (var step = 0; step < 50; step++) {
      seen.addAll(
        tester
            .widgetList<ContactCard>(find.byType(ContactCard))
            .map((card) => card.contact.name),
      );
      expect(tester.takeException(), isNull);
      if (scrollable.position.extentAfter == 0) break;
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();
    }
    expect(seen, contacts.map((contact) => contact.name).toSet());
    expect(find.text(contacts.last.name), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(contacts.first.name),
      -250,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text(contacts.first.name), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('System themes update the screen and unread badges', (
    tester,
  ) async {
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    for (final brightness in Brightness.values) {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(HomeScreen));
      expect(Theme.of(context).brightness, brightness);
      for (var index = 0; index < 4; index++) {
        final card = find.byWidgetPredicate(
          (widget) =>
              widget is ContactCard && widget.contact == contacts[index],
        );
        final badge = find.descendant(
          of: card,
          matching: find.byType(Positioned),
        );
        expect(badge, index == 0 ? findsNothing : findsOneWidget);
        if (index > 0) {
          final container = tester.widget<Container>(
            find.descendant(of: badge, matching: find.byType(Container)),
          );
          expect(
            (container.decoration! as BoxDecoration).color,
            Theme.of(context).colorScheme.error,
          );
        }
      }
      expect(tester.takeException(), isNull);
    }
  });
}
