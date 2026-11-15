import { CYLIndexPath, CYLTagItem, CYLTagListConfiguration, CYLTagSelection, CYLTagStateStyle, CYLTagTap,
  foldedHeight, parseConfiguration } from './CYLTagListModel';

/**
 * A tag list: sections of left-aligned tags that wrap to new lines, with single or multiple selection and a fold
 * control. Configured by the JSON of the Flutter and React Native components.
 */
@Component
export struct CYLTagListView {
  /** The configuration, as JSON text; a new value reloads the list. */
  @Prop @Watch('reload') configuration: string = '{}';
  onTagTap?: (tap: CYLTagTap) => void;
  onSelectionChange?: (selected: CYLIndexPath[]) => void;
  @State private config: CYLTagListConfiguration = parseConfiguration('{}');
  @State private selectedKeys: string[] = [];
  @State private expanded: boolean[] = [];
  private selection: CYLTagSelection = new CYLTagSelection('none', []);

  aboutToAppear(): void {
    this.reload();
  }

  private reload(): void {
    this.config = parseConfiguration(this.configuration);
    this.selection = new CYLTagSelection(this.config.selectionMode, this.config.sections, this.config.selected);
    this.expanded = this.config.sections.map(() => false);
    this.syncKeys();
  }

  private syncKeys(): void {
    this.selectedKeys = this.selection.selected.map((p) => `${p.section}-${p.item}`);
  }

  private tap(section: number, item: number, tag: CYLTagItem): void {
    this.onTagTap?.({ section: section, item: item, title: tag.title });
    if (this.selection.toggle({ section: section, item: item })) {
      this.syncKeys();
      this.onSelectionChange?.(this.selection.selected);
    }
  }

  private toggleFold(section: number): void {
    const next = this.expanded.slice();
    next[section] = !next[section];
    this.expanded = next;
  }

  @Builder
  tagButton(section: number, item: number, tag: CYLTagItem) {
    Text(tag.title)
      .fontSize(this.config.style.fontSize)
      .fontColor(this.stateOf(section, item).textColor)
      .backgroundColor(this.stateOf(section, item).backgroundColor)
      .borderColor(this.stateOf(section, item).borderColor)
      .borderWidth(this.stateOf(section, item).borderWidth)
      .borderRadius(this.stateOf(section, item).cornerRadius)
      .height(this.config.style.itemHeight)
      .padding({ left: 12, right: 12 })
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .constraintSize({ maxWidth: '100%' })
      .margin({ right: this.config.style.spacing, bottom: this.config.style.spacing })
      .id(`CYLTagListItem-${section}-${item}`)
      .accessibilityText(tag.title)
      .accessibilitySelected(this.selectedKeys.includes(`${section}-${item}`))
      .onClick(() => this.tap(section, item, tag))
  }

  private stateOf(section: number, item: number): CYLTagStateStyle {
    return this.selectedKeys.includes(`${section}-${item}`) ? this.config.style.selected : this.config.style.normal;
  }

  build() {
    Column() {
      ForEach(this.config.sections, (section: CYLTagListSectionView, index: number) => {
        Column() {
          if (section.title !== undefined) {
            Row() {
              Text(section.title).fontSize(15).fontWeight(FontWeight.Medium).layoutWeight(1)
              if (this.config.defaultVisibleRows > 0) {
                Text(this.expanded[index] ? '▲' : '▼')
                  .fontSize(14)
                  .padding(8)
                  .id(`CYLTagListFold-${index}`)
                  .accessibilityText(this.expanded[index] ? 'Fold' : 'Unfold')
                  .onClick(() => this.toggleFold(index))
              }
            }.width('100%').margin({ top: 12, bottom: 8 })
          }
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(section.items, (tag: CYLTagItem, item: number) => {
              this.tagButton(index, item, tag)
            }, (tag: CYLTagItem, item: number) => `${index}-${item}-${tag.title}`)
          }
          .width('100%')
          .constraintSize({ maxHeight: this.maxHeight(index) })
          .clip(true)
        }.alignItems(HorizontalAlign.Start)
      }, (section: CYLTagListSectionView, index: number) => `${index}-${section.title ?? ''}-${section.items.length}`)
    }
    .width('100%')
    .padding({ left: 16, right: 16 - this.config.style.spacing })
    .alignItems(HorizontalAlign.Start)
  }

  private maxHeight(section: number): number | string {
    const s = this.config.style;
    const height = foldedHeight(this.config.defaultVisibleRows, s.itemHeight, s.spacing);
    return height < 0 || this.expanded[section] ? '100000vp' : height + s.spacing;
  }
}

interface CYLTagListSectionView {
  title?: string;
  items: CYLTagItem[];
}
