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
          creationParams: <String, Object?>{'configurationJSON': jsonEncode(creationParams['configuration'])},
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onCreated,
        );
  }
}
