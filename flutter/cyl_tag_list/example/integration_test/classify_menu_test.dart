import 'package:cyl_tag_list/cyl_tag_list.dart';
import 'package:cyl_tag_list_example/classify_menu_page.dart';
import 'package:cyl_tag_list_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the classify menu tab lists the shared database places and filters them by tag', (tester) async {
    // The shared database: the same 83 places and 4 categories as iOS and Android (docs/cross-platform.md).
    final database = await PlacesDatabase.open();
    final categories = await database.categories();
    expect(categories.map((c) => c.key), ['吃', '喝', '玩', '逛']);
    expect((await database.places()).length, 83);
    final firstTag = categories.first.value.first;
    final tagged = await database.places(tag: firstTag);
    expect(tagged, isNotEmpty);
    expect(tagged.length, lessThan(83));

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Classify menu').last);
    for (var i = 0; i < 30 && find.byKey(const Key('placesSummary')).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.text('All places · 83'), findsOneWidget);
    expect(find.byType(CylTagListView, skipOffstage: false), findsNWidgets(2), reason: "both tabs keep their native list");
  });
}
