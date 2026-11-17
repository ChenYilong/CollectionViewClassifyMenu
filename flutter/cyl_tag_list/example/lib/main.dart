import 'package:cyl_tag_list/cyl_tag_list.dart';
import 'package:flutter/material.dart';

import 'strings.dart';

import 'classify_menu_page.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CYLTagListView',
      // Screenshots show the app, not the debug ribbon.
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF2AB9A0), useMaterial3: true),
      home: const HomePage(),
    );
  }
}

/// The example's screens, one bottom tab each (tab bars stay at the bottom, AGENTS.md).
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// `--dart-define=CYL_TAB=1` opens the second tab at launch, for screenshots.
  int _index = const int.fromEnvironment('CYL_TAB');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: const [TagListPage(), ClassifyMenuPage()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.animation), label: cylString('动效图标')),
          NavigationDestination(icon: const Icon(Icons.category_outlined), label: cylString('菜单')),
        ],
      ),
    );
  }
}

/// A tag list from one configuration map, and the playback controls of docs/example-demo-rules.md: Play all, a speed
/// slider (0.25x to 4x) and a loop switch, which combine and act at once.
class TagListPage extends StatefulWidget {
  const TagListPage({super.key});

  @override
  State<TagListPage> createState() => _TagListPageState();
}

class _TagListPageState extends State<TagListPage> {
  static const double _minSpeed = 0.25;
  static const double _maxSpeed = 4;

  final CylTagListController _controller = CylTagListController();

  /// The controller of the list, for tests.
  CylTagListController get controller => _controller;
  double _speed = 1;
  bool _loops = false;
  String _lastTap = '';

  /// `--dart-define=CYL_AUTOPLAY=true` applies 2x, loop and Play all after the first frame, for screenshots.
  static const bool _autoPlay = bool.fromEnvironment('CYL_AUTOPLAY');

  @override
  void initState() {
    super.initState();
    if (_autoPlay) {
      Future<void>.delayed(const Duration(seconds: 1), () async {
        if (!mounted) return;
        setState(() {
          _speed = 2;
          _loops = true;
        });
        await _controller.setSpeed(2);
        await _controller.setLoops(true);
        await _controller.playAll();
      });
    }
  }

  static Map<String, Object?> _configuration() {
    Map<String, Object?> item(String title, [String? image]) => {'title': title, 'image': ?image};
    // Lottie files of the example's assets (CYLTabBarController's tab icons): the engine plays them.
    Map<String, Object?> animated(String title, String file) => {'title': title, 'animation': 'asset:assets/$file'};
    return {
      'selectionMode': 'multiple',
      'defaultVisibleRows': 3,
      'foldControl': {'position': 'tail', 'content': 'icon'},
      'style': {
        'itemHeight': 36,
        'imageSize': '{18, 18}',
        'normal': {'cornerRadius': 0, 'borderColor': '#D1D1D6', 'borderWidth': 1},
        'selected': {'cornerRadius': 0, 'backgroundColor': '#E6F8F5', 'textColor': '#2AB9A0', 'borderColor': '#2AB9A0'},
      },
      'sections': [
        {
          'title': 'Lottie · pod CYLTabBarController/Lottie',
          'items': [
            animated('Home', 'tab_home_animate.json'),
            animated('Messages', 'tab_message_animate.json'),
            animated('Search', 'tab_search_animate.json'),
            animated('Me', 'tab_me_animate.json'),
          ],
        },
        {
          'title': 'Rive · pod CYLTabBarController/Rive',
          'items': [
            // Rive state machines and inputs, as on the other platforms: without them the player drives the default
            // input "active", which these files do not have, so nothing plays.
            {...animated('Home', 'rive/house.riv'), 'animationOptions': {'stateMachine': 'State Machine 1'}},
            {...animated('Done', 'rive/check.riv'), 'animationOptions': {'stateMachine': 'State Machine 1', 'triggerInput': 'Check'}},
            {
              ...animated('Menu', 'rive/menu_button.riv'),
              'animationOptions': {'stateMachine': 'State Machine', 'input': 'isOpen', 'duration': '0'},
            },
          ],
        },
        {
          'title': 'Tags',
          'items': [
            item('Home', 'system:house'),
            item('Search', 'system:magnifyingglass'),
            item('Messages', 'system:message'),
            item('Profile', 'system:person'),
            item('Favorites', 'system:star'),
            item('Settings', 'system:gearshape'),
            item('Camera', 'system:camera'),
            item('Music', 'system:music.note'),
            item('Maps', 'system:map'),
            item('Calendar', 'system:calendar'),
          ],
        },
      ],
    };
  }

  String get _speedText => '${_speed == _speed.roundToDouble() ? _speed.toInt() : _speed}×';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cylString('动效图标'))),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(cylString('倍速')),
                      Expanded(
                        child: Semantics(
                          label: cylString('倍速'),
                          value: _speedText,
                          child: Slider(
                            value: _speed,
                            min: _minSpeed,
                            max: _maxSpeed,
                            divisions: ((_maxSpeed - _minSpeed) / 0.25).round(),
                            onChanged: (value) {
                              setState(() => _speed = value);
                              _controller.setSpeed(value);
                            },
                          ),
                        ),
                      ),
                      ExcludeSemantics(child: Text(_speedText)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Text(cylString('循环播放'))),
                      Switch(
                        value: _loops,
                        onChanged: (value) {
                          setState(() => _loops = value);
                          _controller.setLoops(value);
                          if (value) _controller.playAll();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _controller.playAll,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(cylString('全部播放')),
                      ),
                    ],
                  ),
                  if (_lastTap.isNotEmpty) Align(alignment: Alignment.centerLeft, child: Text(_lastTap)),
                ],
              ),
            ),
            Expanded(
              child: CylTagListView(
                configuration: _configuration(),
                controller: _controller,
                onTap: (tap) => setState(() => _lastTap = cylString('点击「%@」', [tap.title])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
