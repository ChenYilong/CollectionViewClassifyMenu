import 'dart:io';

import 'package:cyl_tag_list/cyl_tag_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// The places of the shared database (`Example-Shared/Database/cyl_places.sqlite`, the same rows on every platform,
/// docs/cross-platform.md), copied from the app's assets on first use.
class PlacesDatabase {
  PlacesDatabase._(this._db);

  final Database _db;

  static Future<PlacesDatabase> open() async {
    final file = p.join(await getDatabasesPath(), 'cyl_places.sqlite');
    final data = await rootBundle.load('assets/cyl_places.sqlite');
    await Directory(p.dirname(file)).create(recursive: true);
    // Copied once, so the saved selections survive a relaunch.
    if (!File(file).existsSync()) await File(file).writeAsBytes(data.buffer.asUint8List(), flush: true);
    final db = await openDatabase(file);
    await db.execute('CREATE TABLE IF NOT EXISTS selections (scenario TEXT PRIMARY KEY, items TEXT NOT NULL)');
    return PlacesDatabase._(db);
  }

  /// The filter's regions (the iOS example's `CYLDemoDataSource.regions()`).
  static const List<String> regions = ['北京 🏙️ 扩展文字', '上海', '广州', '深圳'];

  /// Every tag, in database order (the filter's dishes).
  Future<List<String>> tags() async =>
      [for (final row in await _db.rawQuery('SELECT tag FROM places GROUP BY tag ORDER BY MIN(id)')) row['tag'] as String];

  /// The saved "section-item" selection of [scenario], or null when none was saved.
  Future<List<String>?> savedSelection(String scenario) async {
    final rows = await _db.rawQuery('SELECT items FROM selections WHERE scenario = ?', [scenario]);
    if (rows.isEmpty) return null;
    final items = rows.first['items'] as String;
    return items.isEmpty ? [] : items.split(',');
  }

  Future<void> saveSelection(String scenario, List<String> items) => _db.rawInsert(
      'INSERT OR REPLACE INTO selections (scenario, items) VALUES (?, ?)', [scenario, items.join(',')]);

  /// The categories (吃喝玩逛) in the order of their first place, each with its tags in order.
  Future<List<MapEntry<String, List<String>>>> categories() async {
    final rows = await _db.rawQuery('SELECT category, tag FROM places GROUP BY category, tag ORDER BY MIN(id)');
    final result = <String, List<String>>{};
    for (final row in rows) {
      result.putIfAbsent(row['category'] as String, () => []).add(row['tag'] as String);
    }
    return result.entries.toList();
  }

  /// The places of [tag] (every tag when null) in [regions] with one of [dishes] (every one when empty), best rated
  /// first: the statement of the iOS example's `CYLMenuLinkageViewController.query(forTag:regions:dishes:)`.
  Future<List<Map<String, Object?>>> places({String? tag, List<String> regions = const [], List<String> dishes = const []}) {
    final conditions = <String>[];
    final arguments = <Object?>[];
    if (tag != null) {
      conditions.add('tag = ?');
      arguments.add(tag);
    }
    for (final (column, values) in [('region', regions), ('tag', dishes)]) {
      if (values.isEmpty) continue;
      conditions.add('$column IN (${List.filled(values.length, '?').join(', ')})');
      arguments.addAll(values);
    }
    final where = conditions.isEmpty ? '' : ' WHERE ${conditions.join(' AND ')}';
    return _db.rawQuery('SELECT name, region, rating, price FROM places$where ORDER BY rating DESC, id', arguments);
  }
}

/// The classify menu of the iOS and Android examples' menu linkage screen: one section per category, single choice;
/// the selected tag filters the places listed below it (tap it again to show every place).
class ClassifyMenuPage extends StatefulWidget {
  const ClassifyMenuPage({super.key});

  @override
  State<ClassifyMenuPage> createState() => _ClassifyMenuPageState();
}

class _ClassifyMenuPageState extends State<ClassifyMenuPage> {
  /// The saved selections' scenarios, the iOS example's `CYLMenuLinkageClassifyScenario` / `…FilterScenario`.
  static const String classifyScenario = 'menu.classify';
  static const String filterScenario = 'menu.filter';

  /// `--dart-define=CYL_SELECT=<section>-<item>` selects that tag at launch, and `CYL_FILTER=<s>-<i>,…` sets the
  /// filter, for screenshots.
  static const String _launchSelection = String.fromEnvironment('CYL_SELECT');
  static const String _launchFilter = String.fromEnvironment('CYL_FILTER');

  PlacesDatabase? _database;
  List<MapEntry<String, List<String>>> _categories = [];
  List<String> _tags = [];
  List<Map<String, Object?>> _places = [];
  double? _menuHeight;

  /// The classify menu's selection ("section-item", at most one) and the filter's (exclusive 全部 first per section).
  List<String> _classifyItems = const [];
  List<String> _filterItems = const ['0-0', '1-0'];

  String? get selectedTag => _itemTitle(_classifyItems.firstOrNull, (s) => _categories[s].value);

  List<String> get selectedRegions => _filterTitles(0, PlacesDatabase.regions);

  List<String> get selectedDishes => _filterTitles(1, _tags);

  String? _itemTitle(String? item, List<String> Function(int section) titles) {
    final parts = item?.split('-').map(int.tryParse).toList();
    if (parts == null || parts.length != 2 || parts.contains(null)) return null;
    try {
      return titles(parts[0]!).elementAtOrNull(parts[1]!);
    } on RangeError {
      return null;
    }
  }

  /// The titles the filter selects in [section], without 全部 (item 0).
  List<String> _filterTitles(int section, List<String> titles) => [
        for (final item in _filterItems)
          if (item.startsWith('$section-') && item != '$section-0') ?_itemTitle(item, (_) => [' ', ...titles]),
      ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final database = await PlacesDatabase.open();
    final categories = await database.categories();
    final tags = await database.tags();
    final classify = _launchSelection.isNotEmpty ? [_launchSelection] : await database.savedSelection(classifyScenario);
    final filter = _launchFilter.isNotEmpty ? _launchFilter.split(',') : await database.savedSelection(filterScenario);
    if (!mounted) return;
    _database = database;
    _categories = categories;
    _tags = tags;
    _classifyItems = classify ?? const [];
    if (filter != null && filter.isNotEmpty) _filterItems = filter;
    await _runQuery();
  }

  Future<void> _runQuery() async {
    final places = await _database!.places(tag: selectedTag, regions: selectedRegions, dishes: selectedDishes);
    if (mounted) setState(() => _places = places);
  }

  Future<void> _select(CylTagTap tap) async {
    final item = '${tap.section}-${tap.item}';
    _classifyItems = _classifyItems.contains(item) ? const [] : [item];
    await _database!.saveSelection(classifyScenario, _classifyItems);
    await _runQuery();
  }

  /// Applies the filter sheet's selection (the iOS example's `confirmFilterSelection(_:)`).
  Future<void> confirmFilter(List<String> items) async {
    _filterItems = items;
    await _database!.saveSelection(filterScenario, items);
    await _runQuery();
  }

  /// Every tag, region and dish (重置筛选条件).
  Future<void> resetConditions() async {
    _classifyItems = const [];
    _filterItems = const ['0-0', '1-0'];
    await _database!.saveSelection(classifyScenario, _classifyItems);
    await _database!.saveSelection(filterScenario, _filterItems);
    setState(() {});
    await _runQuery();
  }

  static const Map<String, Object?> _style = {
    'itemHeight': 32,
    'normal': {'cornerRadius': 16, 'borderColor': '#D1D1D6', 'borderWidth': 1},
    'selected': {'cornerRadius': 16, 'backgroundColor': '#E6F8F5', 'textColor': '#2AB9A0', 'borderColor': '#2AB9A0'},
  };

  Map<String, Object?> _configuration() => {
        'selectionMode': 'single',
        'allowsEmptySelection': true,
        'selectedItems': _classifyItems,
        'defaultVisibleRows': 1,
        'foldControl': {'position': 'headerTrailing', 'content': 'iconAndTitle'},
        'style': _style,
        'sections': [
          for (final category in _categories)
            {
              'title': category.key,
              'items': [for (final tag in category.value) {'title': tag}],
            },
        ],
      };

  /// The multiple filter of the iOS example: regions and dishes, each section led by an exclusive 全部.
  Map<String, Object?> _filterConfiguration(List<String> selected) => {
        'selectionMode': 'multiple',
        'selectedItems': selected,
        'defaultVisibleRows': 2,
        'foldControl': {'position': 'headerTrailing', 'content': 'iconAndTitle'},
        'style': _style,
        'sections': [
          for (final (title, titles) in [('地区过滤', PlacesDatabase.regions), ('菜品过滤', _tags)])
            {
              'title': title,
              'items': [
                {'title': '全部', 'exclusive': true},
                for (final t in titles) {'title': t},
              ],
            },
        ],
      };

  Future<void> _showFilter() async {
    var pending = _filterItems;
    final confirmed = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.6,
          child: Column(
            children: [
              Expanded(
                child: CylTagListView(
                  configuration: _filterConfiguration(_filterItems),
                  onSelectionChanged: (items) => pending = [for (final i in items) '${i.section}-${i.item}'],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('confirmFilter'),
                    onPressed: () => Navigator.pop(context, pending),
                    child: const Text('确定'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != null) {
      await confirmFilter(confirmed);
      setState(() {});
    }
  }

  String get _summary {
    String names(List<String> values) => values.isEmpty ? '全部' : values.join('、');
    return '${selectedTag ?? '全部'} · ${names(selectedRegions)} · ${names(selectedDishes)} · ${_places.length}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = selectedRegions.isNotEmpty || selectedDishes.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classify menu'),
        actions: [
          IconButton(
            key: const Key('resetConditions'),
            tooltip: '重置筛选条件',
            onPressed: _database == null ? null : resetConditions,
            icon: const Icon(Icons.restart_alt),
          ),
          IconButton(
            key: const Key('openFilter'),
            tooltip: '筛选',
            onPressed: _database == null ? null : _showFilter,
            icon: Icon(filtered ? Icons.filter_alt : Icons.filter_alt_outlined),
          ),
        ],
      ),
      body: _database == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(
                  // As tall as the tags (folds and unfolds included), at most half the page; beyond that the native
                  // list scrolls itself (a drag on a native view does not scroll a Flutter scroll view around it).
                  height: _menuHeight == null ? 1 : _menuHeight!.clamp(1, MediaQuery.sizeOf(context).height / 2),
                  child: CylTagListView(
                    // A new list after a reset, so it shows the cleared selection.
                    key: ValueKey(_classifyItems.isEmpty),
                    configuration: _configuration(),
                    onTap: _select,
                    onContentHeightChanged: (height) => setState(() => _menuHeight = height),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_summary, key: const Key('placesSummary'), style: theme.textTheme.titleSmall),
                  ),
                ),
                if (_places.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('没有符合条件的地点，换个条件试试', key: Key('noPlaces')),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _places.length,
                    itemBuilder: (context, index) {
                      final place = _places[index];
                      return ListTile(
                        dense: true,
                        title: Text(place['name'] as String),
                        subtitle: Text(place['region'] as String),
                        trailing: Text('★ ${(place['rating'] as num).toStringAsFixed(1)} · ¥${place['price']}'),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
