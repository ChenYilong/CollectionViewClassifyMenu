import { CYLMenuLocalizedString } from './CYLMenuResources';
import { CYLLottieIcon } from './CYLLottieIcon';
import { CYLIndexPath, CYLTagListController, CYLTagTap } from './CYLTagListModel';
import {
  CYLTagButtonMetrics, CYLTagFoldMetrics, CYLTagListItemFrame, CYLTagListSectionFrame, CYLTagListState
} from './CYLTagListState';
import { CYLMenuFoldControl, CYLMenuFoldControlPosition } from '../core/CYLMenuFoldControl';
import { CYLMenuLocalizedString, CYLMenuResources } from '../core/CYLMenuResources';
import { CYLMenuStyle, CYLTagContentAlignment, CYLTagDeleteIndicatorPlacement, CYLTagImagePlacement } from '../core/CYLMenuStyle';
import { CYLConfiguration, CYLConfigurationValue } from '../core/CYLTagListConfiguration';
import { CYLColor, CYLControlState, CYLImage, CYLSize } from '../core/CYLTypes';

/** What a tag (or a fold control, or the title) shows, resolved from the list's state for one render. */
class CYLTagRenderItem {
  key: string = '';
  section: number = 0;
  item: number = 0;
  x: number = 0;
  y: number = 0;
  width: number = 0;
  height: number = 0;
  isFoldCell: boolean = false;
  title: string = '';
  fontSize: number = 14;
  fontWeight: FontWeight = FontWeight.Normal;
  textColor: string = CYLColor.BLACK;
  backgroundColor: string = CYLColor.CLEAR;
  highlightedBackgroundColor?: string;
  backgroundImage?: ResourceStr;
  borderColor: string = CYLColor.CLEAR;
  borderWidth: number = 0;
  cornerRadius: number = 0;
  paddingLeft: number = 0;
  paddingRight: number = 0;
  image?: CYLImage;
  animation?: string;
  iconWidth: number = 0;
  iconHeight: number = 0;
  iconColor: string = CYLColor.BLACK;
  iconRotation: number = 0;
  imageTrailing: boolean = false;
  alignLeading: boolean = false;
  spacing: number = 0;
  selected: boolean = false;
  enabled: boolean = true;
  deletable: boolean = false;
  deleteTitle: string = '×';
  deleteColor: string = CYLColor.BLACK;
  deleteFontSize: number = 14;
  deleteLeading: boolean = false;
  speed: number = 1;
  accessibilityText: string = '';
  accessibilityHint: string = '';
}

/** A section header or footer, resolved for one render. */
class CYLSectionRender {
  key: string = '';
  section: number = 0;
  y: number = 0;
  height: number = 0;
  showsTitle: boolean = true;
  title: string = '';
  fontSize: number = 14;
  fontWeight: FontWeight = FontWeight.Normal;
  textColor: string = CYLColor.GRAY;
  inset: number = 16;
  indicatorColor?: string;
  indicatorWidth: number = 3;
  indicatorHeight: number = 16;
  icon?: CYLImage;
  showsFold: boolean = false;
  foldLeading: boolean = false;
  fold: CYLTagRenderItem = new CYLTagRenderItem();
  showsMore: boolean = false;
  moreImage?: ResourceStr;
  moreColor: string = CYLColor.GRAY;
  moreLabel: string = '';
  accessory?: WrappedBuilder<[number]>;
}

function imageKey(image: CYLImage | undefined): string {
  if (image === undefined) {
    return '-';
  }
  if (typeof image === 'string') {
    return image as string;
  }
  return `r${(image as Resource).id}`;
}

function pathKey(p: CYLIndexPath): string {
  return `${p.section}-${p.item}`;
}

/** Copies a parsed JSON value into a configuration, reading the cross-platform JSON's older keys. */
function legacyConfiguration(raw: CYLConfiguration): CYLConfiguration {
  const configuration: CYLConfiguration = {};
  Object.keys(raw).forEach((k: string) => configuration[k] = raw[k]);
  // `selected`: the selected items ([{section, item}]).
  if (configuration['selectedItems'] === undefined && configuration['selected'] !== undefined) {
    configuration['selectedItems'] = configuration['selected'];
  }
  // `defaultVisibleRows` alone folds behind the header's "更多" button.
  if (configuration['foldStyle'] === undefined && configuration['foldControl'] === undefined &&
    (CYLConfigurationValue.number(configuration['defaultVisibleRows']) ?? 0) > 0) {
    configuration['foldStyle'] = 'headerButton';
  }
  const style = CYLConfigurationValue.dictionary(configuration['style']);
  if (style !== undefined) {
    const copy: CYLConfiguration = {};
    Object.keys(style).forEach((k: string) => copy[k] = style[k]);
    // `fontSize`: the title size of every state; `spacing`: the space between tags and rows.
    const fontSize = CYLConfigurationValue.number(copy['fontSize']);
    if (fontSize !== undefined) {
      ['normal', 'selected', 'disabled'].forEach((state: string) => {
        const appearance: CYLConfiguration = {};
        const old = CYLConfigurationValue.dictionary(copy[state]);
        if (old !== undefined) {
          Object.keys(old).forEach((k: string) => appearance[k] = old[k]);
        }
        if (appearance['font'] === undefined) {
          appearance['font'] = fontSize;
        }
        copy[state] = appearance;
      });
    }
    const spacing = CYLConfigurationValue.number(copy['spacing']);
    if (spacing !== undefined) {
      if (copy['interitemSpacing'] === undefined) {
        copy['interitemSpacing'] = spacing;
      }
      if (copy['lineSpacing'] === undefined) {
        copy['lineSpacing'] = spacing;
      }
    }
    configuration['style'] = copy;
  }
  return configuration;
}

/**
 * A tag list: sections of tags in left-aligned rows, with single or multiple selection, folding, a title, deletion,
 * long presses and reordering, as iOS `CYLTagListView`. Its state and API are a `CYLTagListState` (`tagList`, made
 * by the view when not given); `configuration` is the JSON of the Flutter and React Native components and of iOS
 * `init(configuration:)`, applied over that state whenever it changes.
 */
@Component
export struct CYLTagListView {
  /** The configuration, as JSON text; a new value is applied over the state. */
  @Prop @Watch('reload') configuration: string = '';
  /** The playback speed of the animated icons; 0 (the default) uses each item's `style.animationSpeed`. */
  @Prop @Watch('applyAnimation') animationSpeed: number = 0;
  /** Repeats the animated icons; false plays them once. */
  @Prop @Watch('applyAnimation') animationLoops: boolean = false;
  /** Plays the animated icons again (`playAll()`). */
  controller?: CYLTagListController;
  /** The list's state and API; made by the view when not given. */
  tagList?: CYLTagListState;
  onTagTap?: (tap: CYLTagTap) => void;
  onSelectionChange?: (selected: CYLIndexPath[]) => void;
  @State private items: CYLTagRenderItem[] = [];
  @State private headers: CYLSectionRender[] = [];
  @State private footers: CYLSectionRender[] = [];
  @State private titleItem?: CYLTagRenderItem = undefined;
  @State private contentHeight: number = 0;
  @State private backgroundColorValue: string = CYLColor.WHITE;
  @State private borderWidthValue: number = 0;
  @State private borderColorValue: string = CYLColor.CLEAR;
  @State private cornerRadiusValue: number = 0;
  @State private scrollEnabled: boolean = true;
  @State private playToken: number = 0;
  @State private loops: boolean = false;
  @State private pressedKey: string = '';
  @State private draggedKey: string = '';
  @State private dragX: number = 0;
  @State private dragY: number = 0;
  @State private longPressDuration: number = 500;
  private model: CYLTagListState = new CYLTagListState();
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    if (this.tagList !== undefined) {
      this.model = this.tagList;
    }
    this.model.attach(() => this.refresh(), (offset: number, animated: boolean) => {
      this.scroller.scrollTo({ xOffset: 0, yOffset: offset, animation: animated });
    });
    this.controller?.attach(() => this.model.playAllAnimations());
    this.applyAnimation();
    this.reload();
    this.refresh();
  }

  aboutToDisappear(): void {
    this.model.detach();
  }

  private reload(): void {
    if (this.configuration.trim().length === 0) {
      return;
    }
    try {
      const raw = CYLConfigurationValue.dictionary(JSON.parse(this.configuration) as Object);
      if (raw !== undefined) {
        this.model.applyConfiguration(legacyConfiguration(raw));
      }
    } catch (e) {
      // An invalid configuration (JSON or selection) leaves the list as it was.
    }
  }

  private applyAnimation(): void {
    this.model.animationSpeed = this.animationSpeed > 0 ? this.animationSpeed : undefined;
    this.model.animationLoops = this.animationLoops;
  }

  /** Resolves everything the list shows from its state. */
  private refresh(): void {
    const m = this.model;
    const style = m.style;
    const titleHeight = m.titleHeight();
    const sections = m.layoutSections();
    const items: CYLTagRenderItem[] = [];
    const headers: CYLSectionRender[] = [];
    const footers: CYLSectionRender[] = [];
    sections.forEach((frame: CYLTagListSectionFrame) => {
      frame.items.forEach((cell: CYLTagListItemFrame) => {
        items.push(cell.isFoldCell ? this.foldCell(cell, frame, titleHeight) : this.tagItem(cell, titleHeight));
      });
      if (frame.headerHeight > 0) {
        headers.push(this.header(frame, titleHeight));
      }
      if (frame.footerHeight > 0) {
        footers.push(this.footer(frame, titleHeight));
      }
    });
    this.items = items;
    this.headers = headers;
    this.footers = footers;
    this.titleItem = m.hasTitle ? this.title() : undefined;
    this.contentHeight = m.contentHeight;
    this.backgroundColorValue = style.backgroundColor;
    this.borderWidthValue = m.containerBorderWidth;
    this.borderColorValue = m.containerBorderColor ?? CYLColor.CLEAR;
    this.cornerRadiusValue = m.containerCornerRadius;
    this.scrollEnabled = m.isScrollEnabled;
    this.playToken = m.playToken;
    this.loops = m.animationLoops;
    this.longPressDuration = m.longPressDuration;
  }

  /** The look of `style` in `state` on a render item. */
  private applyStyle(r: CYLTagRenderItem, style: CYLMenuStyle, state: number): void {
    const appearance = style.appearance(state);
    const font = style.titleFont(state, this.model.fontScale);
    r.fontSize = font.size;
    r.fontWeight = font.weight;
    r.textColor = appearance.textColor;
    r.backgroundColor = appearance.backgroundColor;
    r.backgroundImage = appearance.backgroundImage;
    r.highlightedBackgroundColor = style.highlightedBackgroundColor;
    r.borderColor = appearance.borderColor ?? CYLColor.CLEAR;
    r.borderWidth = appearance.borderWidth;
    r.cornerRadius = appearance.cornerRadius;
    r.paddingLeft = appearance.contentInsets.left;
    r.paddingRight = appearance.contentInsets.right;
    r.iconColor = style.iconColor(state);
    r.imageTrailing = style.imagePlacement === CYLTagImagePlacement.trailing;
    r.alignLeading = style.contentAlignment === CYLTagContentAlignment.leading;
    r.spacing = style.imageTitleSpacing;
  }

  private finishKey(r: CYLTagRenderItem, extra: string): void {
    r.key = [extra, r.section, r.item, r.x, r.y, r.width, r.height, r.title, r.fontSize, r.fontWeight, r.textColor,
      r.backgroundColor, r.highlightedBackgroundColor ?? '', r.borderColor, r.borderWidth, r.cornerRadius,
      r.paddingLeft, r.paddingRight, imageKey(r.image), r.animation ?? '', r.iconWidth, r.iconHeight, r.iconColor,
      r.iconRotation, r.imageTrailing, r.alignLeading, r.spacing, r.selected, r.enabled, r.deletable, r.deleteTitle,
      r.deleteColor, r.deleteLeading, r.speed, r.accessibilityText, r.accessibilityHint].join('|');
  }

  private tagItem(cell: CYLTagListItemFrame, titleHeight: number): CYLTagRenderItem {
    const m = this.model;
    const p: CYLIndexPath = { section: cell.section, item: cell.item };
    const style = m.styleForItem(p);
    const selected = m.isSelected(p);
    const enabled = m.isEnabled(p);
    let state = CYLControlState.NORMAL;
    if (!enabled) {
      state |= CYLControlState.DISABLED;
    }
    if (selected) {
      state |= CYLControlState.SELECTED;
    }
    const r = new CYLTagRenderItem();
    r.section = cell.section;
    r.item = cell.item;
    r.x = cell.x;
    r.y = cell.y + titleHeight;
    r.width = cell.width;
    r.height = cell.height;
    this.applyStyle(r, style, state);
    r.title = style.displayedTitle(m.titleForItem(p));
    r.animation = m.animationURLForItem(p);
    const image = selected ? (m.selectedImageForItem(p) ?? m.imageForItem(p)) : m.imageForItem(p);
    r.image = r.animation === undefined ? image : undefined;
    const icon = CYLTagButtonMetrics.iconSize(image, r.animation !== undefined, style);
    r.iconWidth = icon.width;
    r.iconHeight = icon.height;
    r.selected = selected;
    r.enabled = enabled;
    r.deletable = m.isDeletable(p) && enabled;
    r.deleteTitle = style.deleteIndicatorTitle;
    r.deleteColor = style.deleteIndicatorColor ?? r.textColor;
    r.deleteFontSize = style.deleteIndicatorFontFor(state, m.fontScale).size;
    r.deleteLeading = style.deleteIndicatorPlacement === CYLTagDeleteIndicatorPlacement.leading;
    r.speed = m.animationSpeedForItem(p);
    r.accessibilityText = m.titleForItem(p);
    r.accessibilityHint = m.accessibilityHintForItem(p) ?? '';
    this.finishKey(r, `t${m.playTokenForItem(p) - m.playToken}`);
    return r;
  }

  /** A fold control drawn as a borderless tag (`CYLTagFoldButton`). */
  private foldItem(control: CYLMenuFoldControl, style: CYLMenuStyle, expanded: boolean, size: CYLSize,
    section: number): CYLTagRenderItem {
    const r = new CYLTagRenderItem();
    r.section = section;
    this.applyStyle(r, style, CYLControlState.NORMAL);
    r.title = control.titleWhenExpanded(expanded) ?? '';
    r.image = control.showsImage(expanded) ? control.image : undefined;
    r.iconWidth = r.image !== undefined ? style.imageSize.width : 0;
    r.iconHeight = r.image !== undefined ? style.imageSize.height : 0;
    r.iconRotation = expanded && control.rotatesImageWhenExpanded && r.image !== undefined ? 180 : 0;
    r.width = size.width;
    r.height = size.height;
    r.accessibilityText = this.model.foldAccessibilityLabel(section);
    r.accessibilityHint = expanded ? '' : CYLMenuLocalizedString('CYLMenuExpandHint');
    return r;
  }

  private foldCell(cell: CYLTagListItemFrame, frame: CYLTagListSectionFrame, titleHeight: number): CYLTagRenderItem {
    const m = this.model;
    const control = m.displayedFoldControl;
    const style = CYLTagFoldMetrics.inlineStyle(control, m.styleForSection(cell.section));
    const r = this.foldItem(control, style, frame.expanded, new CYLSize(cell.width, cell.height), cell.section);
    r.item = cell.item;
    r.isFoldCell = true;
    r.x = cell.x;
    r.y = cell.y + titleHeight;
    this.finishKey(r, 'f');
    return r;
  }

  private sectionFold(frame: CYLTagListSectionFrame): CYLTagRenderItem {
    const m = this.model;
    const control = m.displayedFoldControl;
    const style = CYLTagFoldMetrics.style(control, m.style.foldControlColor);
    const r = this.foldItem(control, style, frame.expanded, m.foldSize(frame.expanded), frame.section);
    this.finishKey(r, 's');
    return r;
  }

  private header(frame: CYLTagListSectionFrame, titleHeight: number): CYLSectionRender {
    const m = this.model;
    const style = m.style;
    const h = new CYLSectionRender();
    h.section = frame.section;
    h.y = frame.y + titleHeight;
    h.height = frame.headerHeight;
    h.showsTitle = m.showsSectionHeaders;
    h.title = m.menuDataSource?.menuTitleForSection(frame.section) ?? '';
    const font = style.headerFontFor(m.fontScale);
    h.fontSize = font.size;
    h.fontWeight = font.weight;
    h.textColor = style.headerTextColor;
    h.inset = style.headerHorizontalInset;
    h.indicatorColor = style.headerIndicatorColor;
    h.indicatorWidth = style.headerIndicatorSize.width;
    h.indicatorHeight = style.headerIndicatorSize.height;
    h.icon = m.menuDataSource?.menuImageForSection?.(frame.section);
    h.showsFold = m.showsHeaderFoldControl(frame.section);
    h.foldLeading = m.foldControl.position === CYLMenuFoldControlPosition.headerLeading;
    if (h.showsFold) {
      h.fold = this.sectionFold(frame);
    }
    h.showsMore = m.showsMoreButton(frame.section);
    h.moreImage = style.moreButtonImage ?? CYLMenuResources.image('cyl_more');
    h.moreColor = style.moreButtonColor;
    h.moreLabel = m.moreButtonAccessibilityLabel(frame.section);
    h.accessory = m.menuDataSource?.menuAccessoryViewForSection?.(frame.section);
    h.key = ['h', h.section, h.y, h.height, h.showsTitle, h.title, h.fontSize, h.fontWeight, h.textColor, h.inset,
      h.indicatorColor ?? '', h.indicatorWidth, h.indicatorHeight, imageKey(h.icon), h.showsFold, h.foldLeading,
      h.fold.key, h.showsMore, h.moreColor, h.moreLabel, h.accessory !== undefined].join('|');
    return h;
  }

  private footer(frame: CYLTagListSectionFrame, titleHeight: number): CYLSectionRender {
    const f = new CYLSectionRender();
    f.section = frame.section;
    f.y = frame.y + frame.height - frame.footerHeight + titleHeight;
    f.height = frame.footerHeight;
    f.showsFold = true;
    f.fold = this.sectionFold(frame);
    f.key = ['f', f.section, f.y, f.height, f.fold.key].join('|');
    return f;
  }

  private title(): CYLTagRenderItem {
    const m = this.model;
    const frame = m.titleFrame();
    const r = new CYLTagRenderItem();
    this.applyStyle(r, m.titleStyle, CYLControlState.NORMAL);
    r.title = m.titleStyle.displayedTitle(m.title);
    r.image = m.titleImage;
    const icon = CYLTagButtonMetrics.iconSize(m.titleImage, false, m.titleStyle);
    r.iconWidth = icon.width;
    r.iconHeight = icon.height;
    r.x = frame.x;
    r.y = frame.y;
    r.width = frame.width;
    r.height = frame.height;
    r.accessibilityText = (m.title ?? '').length > 0 ? (m.title ?? '') : '';
    this.finishKey(r, 'title');
    return r;
  }

  private tap(r: CYLTagRenderItem): void {
    const m = this.model;
    const p: CYLIndexPath = { section: r.section, item: r.item };
    if (r.isFoldCell) {
      m.tapItem(p);
      return;
    }
    const before = m.selectedIndexPaths.map(pathKey).join(',');
    const title = m.menuDataSource?.menuTitleForItem(p) ?? r.accessibilityText;
    m.tapItem(p);
    if (m.allowsTapping) {
      const tap: CYLTagTap = { section: r.section, item: r.item, title: title };
      this.onTagTap?.(tap);
    }
    const after = m.selectedIndexPaths;
    if (after.map(pathKey).join(',') !== before) {
      this.onSelectionChange?.(after);
    }
  }

  private endDrag(r: CYLTagRenderItem, offsetX: number, offsetY: number, moved: boolean): void {
    const target = this.model.indexPathAtPoint(r.x + r.width / 2 + offsetX,
      r.y - this.model.titleHeight() + r.height / 2 + offsetY);
    this.draggedKey = '';
    this.dragX = 0;
    this.dragY = 0;
    const before = this.model.selectedIndexPaths.map(pathKey).join(',');
    this.model.endLongPress(target, moved);
    const after = this.model.selectedIndexPaths;
    if (after.map(pathKey).join(',') !== before) {
      this.onSelectionChange?.(after);
    }
  }

  @Builder
  icon(r: CYLTagRenderItem) {
    if (r.animation !== undefined) {
      CYLLottieIcon({
        source: r.animation,
        iconSize: r.iconWidth,
        speed: r.speed,
        loops: this.loops,
        playToken: this.playToken
      })
    } else if (r.image !== undefined) {
      Image(r.image)
        .width(r.iconWidth > 0 ? r.iconWidth : undefined)
        .height(r.iconHeight > 0 ? r.iconHeight : undefined)
        .fillColor(r.iconColor)
        .objectFit(ImageFit.Contain)
        .rotate({ angle: r.iconRotation })
        .animation({ duration: 250 })
        .accessibilityLevel('no')
    }
  }

  @Builder
  deleteIndicator(r: CYLTagRenderItem) {
    Text(r.deleteTitle)
      .fontSize(r.deleteFontSize)
      .fontColor(r.deleteColor)
      .accessibilityText(CYLMenuLocalizedString('CYLMenuDeleteTag'))
      .id(`CYLTagListDelete-${r.section}-${r.item}`)
      .onClick(() => this.model.deleteItem({ section: r.section, item: r.item }))
  }

  /** The content of a tag: the delete indicator, the icon and the title, in their placements. */
  @Builder
  content(r: CYLTagRenderItem) {
    if (r.deletable && r.deleteLeading) {
      this.deleteIndicator(r)
    }
    if (!r.imageTrailing) {
      this.icon(r)
    }
    if (r.title.length > 0) {
      Text(r.title)
        .fontSize(r.fontSize)
        .fontWeight(r.fontWeight)
        .fontColor(r.textColor)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .flexShrink(1)
    }
<<<<<<< HEAD
    .backgroundColor(this.stateOf(section, item).backgroundColor)
    .borderColor(this.stateOf(section, item).borderColor)
    .borderWidth(this.stateOf(section, item).borderWidth)
    .borderRadius(this.stateOf(section, item).cornerRadius)
    .height(this.config.style.itemHeight)
    .padding({ left: 12, right: 12 })
    .constraintSize({ maxWidth: '100%' })
    .margin({ right: this.config.style.spacing, bottom: this.config.style.spacing })
    .id(`CYLTagListItem-${section}-${item}`)
    .accessibilityGroup(true)
    .accessibilityText(tag.title)
    .accessibilitySelected(this.selectedKeys.includes(`${section}-${item}`))
    .accessibilityDescription(this.config.selectionMode === 'none' ? '' : this.text('cyl_menu_tag_hint'))
      .onClick(() => this.tap(section, item, tag))
  }

  /** A string of the core's resources (CYLMenuLocalizedString). */
  private text(key: string): string {
    return CYLMenuLocalizedString(getContext(this), key);
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
                  .constraintSize({ minWidth: 44, minHeight: 44 })
                  .textAlign(TextAlign.Center)
                  .id(`CYLTagListFold-${index}`)
                  // "<section> More / Less", as the iOS fold control ("<section> 更多/收起"); localized, never literal.
                  .accessibilityText(`${section.title} ${this.text(this.expanded[index] ? 'cyl_menu_collapse' : 'cyl_menu_expand')}`)
                  .accessibilityDescription(this.text(this.expanded[index] ? 'cyl_menu_collapse_hint' : 'cyl_menu_expand_hint'))
                  .onClick(() => this.toggleFold(index))
              }
            }.width('100%').margin({ top: 12, bottom: 8 })
          }
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(section.items, (tag: CYLTagItem, item: number) => {
              this.tagButton(index, item, tag)
            }, (tag: CYLTagItem, item: number) => `${index}-${item}-${tag.title}`)
=======
    if (r.imageTrailing) {
      this.icon(r)
    }
    if (r.deletable && !r.deleteLeading) {
      this.deleteIndicator(r)
    }
  }

  private itemBackground(r: CYLTagRenderItem): string {
    return this.pressedKey === r.key && r.highlightedBackgroundColor !== undefined ? r.highlightedBackgroundColor :
    r.backgroundColor;
  }

  /** A fold control in a header or footer. */
  @Builder
  foldButton(r: CYLTagRenderItem) {
    Row({ space: r.spacing }) {
      this.content(r)
    }
    .width(r.width)
    .height(r.height)
    .padding({ left: r.paddingLeft, right: r.paddingRight })
    .justifyContent(FlexAlign.Center)
    .id(`CYLTagListFold-${r.section}`)
    .accessibilityGroup(true)
    .accessibilityText(r.accessibilityText)
    .accessibilityDescription(r.accessibilityHint)
    .onClick(() => this.model.toggleSection(r.section))
  }

  /** The inline fold control, the last item of a section. */
  @Builder
  foldCellButton(r: CYLTagRenderItem) {
    Row({ space: r.spacing }) {
      this.content(r)
    }
    .width(r.width)
    .height(r.height)
    .padding({ left: r.paddingLeft, right: r.paddingRight })
    .justifyContent(FlexAlign.Center)
    .backgroundColor(r.backgroundColor)
    .border({ width: r.borderWidth, color: r.borderColor, radius: r.cornerRadius })
    .position({ x: r.x, y: r.y })
    .id(`CYLTagListFold-${r.section}`)
    .accessibilityGroup(true)
    .accessibilityText(r.accessibilityText)
    .accessibilityDescription(r.accessibilityHint)
    .onClick(() => this.tap(r))
  }

  @Builder
  titleView(r: CYLTagRenderItem) {
    Row({ space: r.spacing }) {
      this.content(r)
    }
    .width(r.width)
    .height(r.height)
    .padding({ left: r.paddingLeft, right: r.paddingRight })
    .justifyContent(FlexAlign.Center)
    .position({ x: r.x, y: r.y })
    .id('CYLTagListTitle')
    .accessibilityGroup(true)
    .accessibilityText(r.accessibilityText)
  }

  @Builder
  tagButton(r: CYLTagRenderItem) {
    Row({ space: r.spacing }) {
      this.content(r)
    }
    .width(r.width)
    .height(r.height)
    .padding({ left: r.paddingLeft, right: r.paddingRight })
    .justifyContent(r.alignLeading ? FlexAlign.Start : FlexAlign.Center)
    .backgroundColor(this.itemBackground(r))
    .backgroundImage(r.backgroundImage)
    .backgroundImageSize(ImageSize.Cover)
    .border({ width: r.borderWidth, color: r.borderColor, radius: r.cornerRadius })
    .position({ x: r.x, y: r.y })
    .opacity(r.enabled ? 1 : 0.6)
    .translate({ x: this.draggedKey === r.key ? this.dragX : 0, y: this.draggedKey === r.key ? this.dragY : 0 })
    .zIndex(this.draggedKey === r.key ? 1 : 0)
    .id(`CYLTagListItem-${r.section}-${r.item}`)
    .accessibilityGroup(true)
    .accessibilityText(r.accessibilityText)
    .accessibilityDescription(r.accessibilityHint)
    .accessibilitySelected(r.selected)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down && this.model.shouldHighlightItem({ section: r.section, item: r.item })) {
        this.pressedKey = r.key;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressedKey = '';
      }
    })
    .onClick(() => this.tap(r))
    .gesture(GestureGroup(GestureMode.Sequence,
      LongPressGesture({ duration: this.longPressDuration })
        .onAction(() => {
          if (this.model.beginLongPress({ section: r.section, item: r.item })) {
            this.draggedKey = r.key;
          }
        }),
      PanGesture({ distance: 8 })
        .onActionUpdate((event: GestureEvent) => {
          if (this.draggedKey === r.key) {
            this.dragX = event.offsetX;
            this.dragY = event.offsetY;
          }
        })
        .onActionEnd((event: GestureEvent) => {
          if (this.draggedKey === r.key) {
            this.endDrag(r, event.offsetX, event.offsetY, true);
          }
        })
    ).onCancel(() => {
      if (this.draggedKey === r.key) {
        this.endDrag(r, 0, 0, false);
      }
    }))
  }

  build() {
    Scroll(this.scroller) {
      Stack({ alignContent: Alignment.TopStart }) {
        if (this.titleItem !== undefined) {
          this.titleView(this.titleItem)
        }
        ForEach(this.headers, (h: CYLSectionRender) => {
          Row({ space: 6 }) {
            if (h.showsFold && h.foldLeading) {
              this.foldButton(h.fold)
            }
            if (h.showsTitle && h.indicatorColor !== undefined) {
              Column().width(h.indicatorWidth).height(h.indicatorHeight).backgroundColor(h.indicatorColor)
            }
            if (h.showsTitle && h.icon !== undefined) {
              Image(h.icon).width(h.indicatorHeight).height(h.indicatorHeight).accessibilityLevel('no')
            }
            Text(h.showsTitle ? h.title : '')
              .fontSize(h.fontSize)
              .fontWeight(h.fontWeight)
              .fontColor(h.textColor)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
            if (h.showsMore && h.moreImage !== undefined) {
              Image(h.moreImage)
                .width(24)
                .height(24)
                .fillColor(h.moreColor)
                .id(`CYLTagListMore-${h.section}`)
                .accessibilityText(h.moreLabel)
                .onClick(() => this.model.tapMoreButton(h.section))
            }
            if (h.accessory !== undefined) {
              Row() {
                h.accessory.builder(h.section)
              }
              .constraintSize({ maxWidth: '50%' })
              .height('100%')
              .alignItems(VerticalAlign.Center)
            }
            if (h.showsFold && !h.foldLeading) {
              this.foldButton(h.fold)
            }
>>>>>>> 9be3571 (feat(harmony): CYLTagListView with configuration, and the image tag views (score 74.8))
          }
          .width('100%')
          .height(h.height)
          .padding({ left: h.inset, right: h.inset })
          .position({ x: 0, y: h.y })
        }, (h: CYLSectionRender) => h.key)
        ForEach(this.footers, (f: CYLSectionRender) => {
          Row() {
            this.foldButton(f.fold)
          }
          .width('100%')
          .height(f.height)
          .justifyContent(FlexAlign.Center)
          .position({ x: 0, y: f.y })
        }, (f: CYLSectionRender) => f.key)
        ForEach(this.items, (r: CYLTagRenderItem) => {
          if (r.isFoldCell) {
            this.foldCellButton(r)
          } else {
            this.tagButton(r)
          }
        }, (r: CYLTagRenderItem) => r.key)
      }
      .width('100%')
      .height(this.contentHeight)
    }
    .width('100%')
    .scrollable(this.scrollEnabled ? ScrollDirection.Vertical : ScrollDirection.None)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
    .nestedScroll({ scrollForward: NestedScrollMode.SELF_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
    .align(Alignment.Top)
    .backgroundColor(this.backgroundColorValue)
    .border({ width: this.borderWidthValue, color: this.borderColorValue, radius: this.cornerRadiusValue })
    .clip(this.cornerRadiusValue > 0)
    .onAreaChange((oldArea: Area, newArea: Area) => {
      this.model.setViewportHeight(Number(newArea.height));
      this.model.setLayoutWidth(Number(newArea.width));
    })
  }
}
