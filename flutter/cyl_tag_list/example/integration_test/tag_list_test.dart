import 'package:cyl_tag_list/cyl_tag_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:cyl_tag_list_example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the native tag list is shown and the playback controls reach it', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pump(const Duration(seconds: 1));

    final listFinder = find.byType(CylTagListView);
    expect(listFinder, findsOneWidget);
    // The page's controller is the one the list attached to its native view.
    final page = tester.state<State<TagListPage>>(find.byType(TagListPage));
    final controller = (page as dynamic).controller as CylTagListController;
    expect(controller.isAttached, isTrue, reason: 'the platform view was created and its channel attached');

    var state = await controller.state();
    expect(state['tagCount'], 14, reason: 'the native list holds the configuration\'s 4 animated and 10 plain tags');
    expect(state['loops'], false);

    // Dart controls -> native list, at once.
    await tester.drag(find.byType(Slider), const Offset(120, 0));
    await tester.pump();
    state = await controller.state();
    expect(state['speed'], isA<double>());
    expect((state['speed'] as double), greaterThan(1), reason: 'the slider moved to a faster speed');
    expect(((state['speed'] as double) * 4).roundToDouble(), (state['speed'] as double) * 4, reason: 'steps of 0.25');

    await tester.tap(find.byType(Switch));
    await tester.pump();
    state = await controller.state();
    expect(state['loops'], true);

    await tester.tap(find.text('Play all'));
    await tester.pump();
    await tester.tap(find.byType(Switch));
    await tester.pump();
    state = await controller.state();
    expect(state['loops'], false);
  });
}
