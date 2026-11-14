/// Flutter wrapper of the native `CYLTagListView` (iOS, Swift) and its Kotlin port (Android): the same tag list, the
/// same configuration map (`CYLTagListKey`, `CYLTagSectionKey`, `CYLTagItemKey`…), the same animated icons.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const String _viewType = 'com.cyl.cyl_tag_list/view';

/// Drives the animated icons of a [CylTagListView]: Play all, the speed and the loop switch of
/// docs/example-demo-rules.md. Every call acts at once, also on animations that are playing.
class CylTagListController {
  MethodChannel? _channel;

  /// Whether a [CylTagListView] uses this controller now.
  bool get isAttached => _channel != null;

  void _attach(MethodChannel channel) => _channel = channel;

  void _detach() => _channel = null;

  /// Plays every animated icon on screen from progress 0.
  Future<void> playAll() => _invoke('playAll');

  /// Sets the playback speed of every animated icon (1 is the file's own speed).
  Future<void> setSpeed(double speed) => _invoke('setSpeed', speed);

  /// Repeats the animated icons after they start playing; false plays them once.
  Future<void> setLoops(bool loops) => _invoke('setLoops', loops);

  /// Applies a configuration map to the existing list; keys that are missing keep their values.
  Future<void> applyConfiguration(Map<String, Object?> configuration) => _invoke('applyConfiguration', configuration);

  /// What the native list holds now: `speed` (null while the style's own speed is used), `loops` and `tagCount`.
  Future<Map<String, Object?>> state() async {
    final result = await _channel?.invokeMapMethod<String, Object?>('state');
    return result ?? const <String, Object?>{};
  }

  Future<void> _invoke(String method, [Object? arguments]) async {
    await _channel?.invokeMethod<void>(method, arguments);
  }
}

/// A tag the user tapped.
class CylTagTap {
  const CylTagTap({required this.section, required this.item, required this.title});

  final int section;
  final int item;
  final String title;
}

/// The native tag list. [configuration] is the dictionary of `CYLTagListView(configuration:)`: strings for every key
/// ("multiple", "#07C160", "system:house"); a string "asset:" followed by a Flutter asset key is replaced by the asset's file path
/// on the device (animations, images).
class CylTagListView extends StatefulWidget {
  const CylTagListView({super.key, required this.configuration, this.controller, this.onTap});

  final Map<String, Object?> configuration;
  final CylTagListController? controller;
  final ValueChanged<CylTagTap>? onTap;

  @override
  State<CylTagListView> createState() => _CylTagListViewState();
}

class _CylTagListViewState extends State<CylTagListView> {
  MethodChannel? _channel;

  @override
  void dispose() {
    widget.controller?._detach();
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  void _onCreated(int id) {
    final channel = MethodChannel('$_viewType/$id');
    channel.setMethodCallHandler(_onCall);
    _channel = channel;
    widget.controller?._attach(channel);
  }

  Future<void> _onCall(MethodCall call) async {
    if (call.method == 'onTap' && call.arguments is Map) {
      final arguments = call.arguments as Map;
      widget.onTap?.call(CylTagTap(
        section: arguments['section'] as int,
        item: arguments['item'] as int,
        title: arguments['title'] as String,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final creationParams = <String, Object?>{'configuration': widget.configuration};
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: _viewType,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onCreated,
        );
      case TargetPlatform.android:
        return AndroidView(
          viewType: _viewType,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onCreated,
        );
      default:
        return const Center(child: Text('CylTagListView supports iOS and Android'));
    }
  }
}
