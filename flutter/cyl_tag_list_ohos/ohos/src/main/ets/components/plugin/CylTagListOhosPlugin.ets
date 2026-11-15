import {
  Any,
  BinaryMessenger,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
  PlatformView,
  PlatformViewFactory,
  StandardMessageCodec
} from '@ohos/flutter_ohos';
import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { common } from '@kit.AbilityKit';
import { CYLIndexPath, CYLTagListController, CYLTagListView, CYLTagTap, parseConfiguration } from '@cyl/classifymenu';

const VIEW_TYPE = 'com.cyl.cyl_tag_list/view';

/**
 * Registers the platform view of `CylTagListView` (Dart) for HarmonyOS.
 */
export default class CylTagListOhosPlugin implements FlutterPlugin {
  getUniqueClassName(): string {
    return 'CylTagListOhosPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    binding.getPlatformViewRegistry()?.registerViewFactory(VIEW_TYPE,
      new CylTagListViewFactory(binding.getBinaryMessenger()));
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
  }
}

class CylTagListViewFactory extends PlatformViewFactory {
  private messenger: BinaryMessenger;

  constructor(messenger: BinaryMessenger) {
    super(StandardMessageCodec.INSTANCE);
    this.messenger = messenger;
  }

  public create(context: common.Context, viewId: number, args: Any): PlatformView {
    const json: string | undefined = (args as Map<string, string>).get('configurationJSON');
    return new CylTagListPlatformView(this.messenger, viewId, json ?? '{}');
  }
}

/**
 * One tag list: the ArkTS `CYLTagListView`, its events sent on `com.cyl.cyl_tag_list/view/<id>`
 * (`onTap`, `onSelectionChanged`, `onContentHeight`), the methods of `CylTagListController` answered.
 */
@Observed
export class CylTagListPlatformView extends PlatformView implements MethodCallHandler {
  configuration: string;
  contentHeight: number = 0;
  /** The playback controls of docs/example-demo-rules.md; null speed is the configuration's own. */
  speed: number | null = null;
  loops: boolean = false;
  controller: CYLTagListController = new CYLTagListController();
  private channel: MethodChannel;

  constructor(messenger: BinaryMessenger, viewId: number, configuration: string) {
    super();
    this.configuration = configuration;
    this.channel = new MethodChannel(messenger, `${VIEW_TYPE}/${viewId}`);
    this.channel.setMethodCallHandler(this);
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(cylTagListBuilder);
  }

  dispose(): void {
    this.channel.setMethodCallHandler(null);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case 'contentHeight':
        result.success(this.contentHeight);
        break;
      case 'state':
        const state = new Map<string, Object | null>();
        let tagCount = 0;
        parseConfiguration(this.configuration).sections.forEach((section) => tagCount += section.items.length);
        state.set('speed', this.speed);
        state.set('loops', this.loops);
        state.set('tagCount', tagCount);
        result.success(state);
        break;
      case 'playAll':
        this.controller.playAll();
        result.success(null);
        break;
      case 'setSpeed':
        this.speed = call.args as number;
        result.success(null);
        break;
      case 'setLoops':
        this.loops = call.args as boolean;
        result.success(null);
        break;
      default:
        result.notImplemented();
    }
  }

  sendTap(tap: CYLTagTap): void {
    const map = new Map<string, Object>();
    map.set('section', tap.section);
    map.set('item', tap.item);
    map.set('title', tap.title);
    this.channel.invokeMethod('onTap', map);
  }

  sendSelection(selected: CYLIndexPath[]): void {
    const sections = parseConfiguration(this.configuration).sections;
    const list: Map<string, Object>[] = selected.map((p: CYLIndexPath): Map<string, Object> => {
      const map = new Map<string, Object>();
      map.set('section', p.section);
      map.set('item', p.item);
      map.set('title', sections[p.section]?.items[p.item]?.title ?? '');
      return map;
    });
    this.channel.invokeMethod('onSelectionChanged', list);
  }

  sendContentHeight(height: number): void {
    if (Math.abs(height - this.contentHeight) < 0.5) {
      return;
    }
    this.contentHeight = height;
    this.channel.invokeMethod('onContentHeight', height);
  }
}

@Component
struct CylTagListHost {
  @ObjectLink view: CylTagListPlatformView;

  build() {
    // The root fills the platform view: Flutter draws the root's surface into the view's whole rectangle, so a root
    // only as tall as its content was stretched. The content scrolls inside; its own height is reported.
    Scroll() {
      Column() {
        CYLTagListView({
          configuration: this.view.configuration,
          animationSpeed: this.view.speed ?? 1,
          animationLoops: this.view.loops,
          controller: this.view.controller,
          onTagTap: (tap: CYLTagTap) => this.view.sendTap(tap),
          onSelectionChange: (selected: CYLIndexPath[]) => this.view.sendSelection(selected)
        })
      }
      .width('100%')
      .onAreaChange((_old: Area, area: Area) => this.view.sendContentHeight(Number(area.height)))
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }
}

@Builder
function cylTagListBuilder(params: Params) {
  CylTagListHost({ view: params.platformView as CylTagListPlatformView })
}
