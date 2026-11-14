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
    await File(file).writeAsBytes(data.buffer.asUint8List(), flush: true);
    return PlacesDatabase._(await openDatabase(file, readOnly: true));
  }

  /// The categories (吃喝玩逛) in the order of their first place, each with its tags in order.
  Future<List<MapEntry<String, List<String>>>> categories() async {
    final rows = await _db.rawQuery('SELECT category, tag FROM places GROUP BY category, tag ORDER BY MIN(id)');
    final result = <String, List<String>>{};
    for (final row in rows) {
      result.putIfAbsent(row['category'] as String, () => []).add(row['tag'] as String);
    }
    return result.entries.toList();
  }

  /// The places of [tag], or every place when it is null, best rated first.
  Future<List<Map<String, Object?>>> places({String? tag}) => tag == null
      ? _db.rawQuery('SELECT name, region, rating, price FROM places ORDER BY rating DESC, id')
      : _db.rawQuery('SELECT name, region, rating, price FROM places WHERE tag = ? ORDER BY rating DESC, id', [tag]);
}

/// The classify menu of the iOS and Android examples' menu linkage screen: one section per category, single choice;
/// the selected tag filters the places listed below it (tap it again to show every place).
class ClassifyMenuPage extends StatefulWidget {
  const ClassifyMenuPage({super.key});

  @override
  State<ClassifyMenuPage> createState() => _ClassifyMenuPageState();
}

class _ClassifyMenuPageState extends State<ClassifyMenuPage> {
  PlacesDatabase? _database;
  List<MapEntry<String, List<String>>> _categories = [];
  List<Map<String, Object?>> _places = [];
  String? _selectedTag;
  double? _menuHeight;

  /// `--dart-define=CYL_SELECT=<section>-<item>` selects that tag at launch, for screenshots.
  static const String _launchSelection = String.fromEnvironment('CYL_SELECT');
  List<String> _selectedItems = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final database = await PlacesDatabase.open();
    final categories = await database.categories();
    String? tag;
    final parts = _launchSelection.split('-').map(int.tryParse).toList();
    if (parts.length == 2 && parts[0] != null && parts[1] != null && parts[0]! < categories.length) {
      tag = categories[parts[0]!].value.elementAtOrNull(parts[1]!);
    }
    final places = await database.places(tag: tag);
    if (!mounted) return;
    setState(() {
      _selectedTag = tag;
      if (tag != null) _selectedItems = [_launchSelection];
      _database = database;
      _categories = categories;
      _places = places;
    });
  }

  Future<void> _select(CylTagTap tap) async {
    final tag = tap.title == _selectedTag ? null : tap.title;
    final places = await _database!.places(tag: tag);
    if (!mounted) return;
    setState(() {
      _selectedTag = tag;
      _places = places;
    });
  }

  Map<String, Object?> _configuration() => {
        'selectionMode': 'single',
        'allowsEmptySelection': true,
        'selectedItems': _selectedItems,
        'defaultVisibleRows': 1,
        'foldControl': {'position': 'headerTrailing', 'content': 'iconAndTitle'},
        'style': {
          'itemHeight': 32,
          'normal': {'cornerRadius': 16, 'borderColor': '#D1D1D6', 'borderWidth': 1},
          'selected': {'cornerRadius': 16, 'backgroundColor': '#E6F8F5', 'textColor': '#2AB9A0', 'borderColor': '#2AB9A0'},
        },
        'sections': [
          for (final category in _categories)
            {
              'title': category.key,
              'items': [for (final tag in category.value) {'title': tag}],
            },
        ],
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Classify menu')),
      body: _database == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) => SizedBox(
                    // As tall as the tags (folds and unfolds included), at most half the page; beyond that the native
                    // list scrolls itself (a drag on a native view does not scroll a Flutter scroll view around it).
                    height: _menuHeight == null ? 1 : _menuHeight!.clamp(1, MediaQuery.sizeOf(context).height / 2),
                    child: CylTagListView(
                      configuration: _configuration(),
                      onTap: _select,
                      onContentHeightChanged: (height) => setState(() => _menuHeight = height),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_selectedTag ?? 'All places'} · ${_places.length}',
                      key: const Key('placesSummary'),
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
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
