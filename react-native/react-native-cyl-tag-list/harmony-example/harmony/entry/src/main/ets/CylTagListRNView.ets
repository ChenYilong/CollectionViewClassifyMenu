/*
 * CylTagListRNView.ets
 * React Native for OpenHarmony: the native component `CylTagListView` (react-native-cyl-tag-list) as the ArkTS
 * CYLTagListView of harmony/classifymenu. Props come from the descriptor; events and the playAll command go through
 * the classes codegen-harmony generated from the component's spec.
 */
import { RNComponentContext, RNViewBase } from '@rnoh/react-native-openharmony';
import { CylTagListView } from './generated/components/CylTagListView';
import { CYLIndexPath, CYLTagListController, CYLTagListView as CYLList, CYLTagTap,
  parseConfiguration } from '@cyl/classifymenu';

interface SelectionItem {
  section: number;
  item: number;
  title: string;
}

@Component
export struct CylTagListRNView {
  public static readonly NAME = CylTagListView.NAME;
  ctx!: RNComponentContext;
  tag: number = 0;
  @State private ready: boolean = false;
  @State private configuration: string = '{}';
  @State private speed: number = 1;
  @State private loops: boolean = false;
  private controller: CYLTagListController = new CYLTagListController();
  private eventEmitter: CylTagListView.EventEmitter | undefined = undefined;
  private cleanUps: (() => void)[] = [];

  aboutToAppear() {
    this.eventEmitter = new CylTagListView.EventEmitter(this.ctx.rnInstance, this.tag);
    this.onDescriptorChange(this.ctx.descriptorRegistry.getDescriptor<CylTagListView.Descriptor>(this.tag));
    this.cleanUps.push(this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag, (descriptor) => {
      this.onDescriptorChange(descriptor as CylTagListView.Descriptor);
    }));
    const commands = new CylTagListView.CommandReceiver(this.ctx.componentCommandReceiver, this.tag);
    this.cleanUps.push(commands.subscribe('playAll', () => this.controller.playAll()));
  }

  aboutToDisappear() {
    this.cleanUps.forEach((cleanUp) => cleanUp());
  }

  // The descriptor's raw props (the generated props selector returned them empty on RNOH 0.86.1).
  private onDescriptorChange(descriptor: CylTagListView.Descriptor | undefined) {
    const raw = descriptor?.rawProps;
    if (raw === undefined) {
      return;
    }
    this.configuration = raw.configuration ?? '{}';
    // 0 keeps each animation's own speed (the spec's default).
    this.speed = (raw.animationSpeed ?? 0) > 0 ? raw.animationSpeed! : 1;
    this.loops = raw.animationLoops ?? false;
    this.ready = true;
  }

  private sendSelection(selected: CYLIndexPath[]) {
    const sections = parseConfiguration(this.configuration).sections;
    const items: SelectionItem[] = selected.map((p: CYLIndexPath): SelectionItem => ({
      section: p.section,
      item: p.item,
      title: sections[p.section]?.items[p.item]?.title ?? ''
    }));
    this.eventEmitter?.emit('selectionChange', { itemsJSON: JSON.stringify(items) });
  }

  build() {
    RNViewBase({ ctx: this.ctx, tag: this.tag }) {
      if (this.ready) {
        Scroll() {
          Column() {
            CYLList({
              configuration: this.configuration,
              animationSpeed: this.speed,
              animationLoops: this.loops,
              controller: this.controller,
              onTagTap: (tap: CYLTagTap): void => {
                this.eventEmitter?.emit('tagTap', { section: tap.section, item: tap.item, title: tap.title });
              },
              onSelectionChange: (selected: CYLIndexPath[]): void => {
                this.sendSelection(selected);
              }
            })
          }
          .width('100%')
          .onAreaChange((_old: Area, area: Area): void => {
            this.eventEmitter?.emit('contentHeightChange', { height: Number(area.height) });
          })
        }
        .width('100%')
        .height('100%')
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
      }
    }
  }
}
