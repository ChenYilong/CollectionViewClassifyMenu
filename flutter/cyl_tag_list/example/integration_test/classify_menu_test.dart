import 'package:cyl_tag_list/cyl_tag_list.dart';
import 'package:cyl_tag_list_example/classify_menu_page.dart';
import 'package:cyl_tag_list_example/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cyl_tag_list_example/strings.dart';

/// The summary with nothing chosen: every place of the shared database.
final allPlaces = '${cylString('分类：%@ · 地区：%@ · 菜品：%@', [cylString('全部'), cylString('全部'), cylString('全部')])} · ${cylString('匹配 %lu 条', [83])}';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40 && finder.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('the classify menu and the multiple filter query the shared database', (tester) async {
    // The shared database: the same 83 places and 4 categories as iOS and Android (docs/cross-platform.md).
    final database = await PlacesDatabase.open();
    final categories = await database.categories();
    expect(categories.map((c) => c.key), ['吃', '喝', '玩', '逛']);
    expect((await database.places()).length, 83);
    final tag = categories.first.value[1];
    expect(tag, startsWith('川菜'));
    final tagged = await database.places(tag: tag);
    expect(tagged, isNotEmpty);
    expect(tagged.length, lessThan(83));

    // The filter ANDs regions and dishes with the tag (the iOS example's statement).
    final shanghai = await database.places(tag: tag, regions: ['上海']);
    expect(shanghai.every((p) => p['region'] == '上海'), isTrue);
    expect(shanghai.length, lessThanOrEqualTo(tagged.length));
    final tags = await database.tags();
    final dishes = await database.places(dishes: tags.take(2).toList());
    expect(dishes.length, greaterThan(0));
    expect((await database.places(regions: PlacesDatabase.regions)).length, 83, reason: 'every region is every place');

    // Selections are saved in the database.
    await database.saveSelection('test', ['1-2', '0-0']);
    expect(await database.savedSelection('test'), ['1-2', '0-0']);
    expect(await database.savedSelection('missing'), isNull);

    // Android: CYLTabBarController's native tab bar draws the tabs, and taps that integration_test synthesizes do not
    // reach a native view, so the app opens on the Menu tab (a real tap on the native bar is checked on the emulator,
    // docs/cross-platform.md). Elsewhere: a tap on Material's navigation bar.
    final android = defaultTargetPlatform == TargetPlatform.android;
    await tester.pumpWidget(ExampleApp(initialTab: android ? 1 : 0));
    await tester.pumpAndSettle();
    if (!android) await tester.tap(find.text(cylString('菜单')).last);
    await waitFor(tester, find.byKey(const Key('resetConditions')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byKey(const Key('resetConditions')));
    await waitFor(tester, find.text(allPlaces));
    expect(find.text(allPlaces), findsOneWidget);
    expect(find.byType(CylTagListView, skipOffstage: false), findsNWidgets(2), reason: 'both tabs keep their native list');

    // The filter sheet: a native multiple-choice list and 确定, which keeps the conditions when nothing changed.
    await tester.tap(find.byKey(const Key('openFilter')));
    await tester.pumpAndSettle();
    expect(find.byType(CylTagListView, skipOffstage: false), findsNWidgets(3));
    await tester.tap(find.byKey(const Key('confirmFilter')));
    await tester.pumpAndSettle();
    expect(find.text(allPlaces), findsOneWidget);
  });
}
