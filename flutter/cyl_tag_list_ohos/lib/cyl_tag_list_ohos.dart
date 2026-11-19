/// HarmonyOS NEXT implementation of `cyl_tag_list`: hosts the ArkTS `CYLTagListView` (harmony/classifymenu) in an
/// `OhosView`. Only the HarmonyOS build imports this library (`dartPluginClass`), so iOS and Android never compile it.
library;

import 'dart:convert';

import 'package:cyl_tag_list/cyl_tag_list.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Registers the HarmonyOS view of [CylTagListView] at startup.
class CylTagListOhos {
  /// Called by the generated plugin registrant of a HarmonyOS build.
  static void registerWith() {
    CylTagListView.platformViewBuilder = (viewType, creationParams, onCreated) => OhosView(
          viewType: viewType,
          // The ArkTS list reads the configuration as JSON text, the format of the React Native component.
          creationParams: <String, Object?>{'configurationJSON': jsonEncode(_rawfilePaths(creationParams['configuration']))},
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onCreated,
        );
  }

  /// Flutter's assets are the rawfiles under `flutter_assets/` on HarmonyOS: `asset:<key>` becomes
  /// `asset:flutter_assets/<key>`, which the ArkTS list reads (the iOS and Android plugins map it to a file path).
  static Object? _rawfilePaths(Object? value) {
    if (value is String && value.startsWith('asset:') && !value.startsWith('asset:flutter_assets/')) {
      return 'asset:flutter_assets/${value.substring('asset:'.length)}';
    }
    if (value is Map) return value.map((key, item) => MapEntry(key, _rawfilePaths(item)));
    if (value is List) return value.map(_rawfilePaths).toList();
    return value;
  }
}
