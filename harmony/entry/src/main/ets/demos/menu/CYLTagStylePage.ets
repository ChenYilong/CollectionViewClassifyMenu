import { CYLExampleLocalizedString } from '../../data/CYLExampleLocalization';
/**
 * `CYLTagStyleDemoViewController` (标签样式): a tag preview on top; each row of the table below changes one style
 * parameter at once (after CYLTabBarController's CYLFlatDesignTabBarDemoViewController), or opens another demo.
 */
import {
  CYLControlState, CYLEdgeInsets, CYLFont, CYLImage, CYLIndexPath, CYLMenuSelectionMode, CYLMenuStyle, CYLOffset,
  CYLSize, CYLTagAppearance, CYLTagListController, CYLTagListState, CYLTagListView
} from '@cyl/classifymenu';
import { CYLDemoBar, CYLDemoNav } from '../DemoNav';
import {
  CYLExampleMenuItem, CYLExampleMenuSection, CYLExampleMenuSource, CYLSystemColor, cylSectionHeader
} from './MenuSupport';

export enum CYLTagStyleDemoContent {
  iconAndTitle = 0,
  iconOnly = 1,
  titleOnly = 2
}

const ACTIONS: string[][] = [
  ['iconColor.normal', 'iconColor.selected', 'titleColor.normal', 'titleColor.selected', 'font',
    'imageTitleSpacing', 'imageSize', 'imageInsets', 'titlePositionAdjustment', 'imagePositionAdjustment',
    'content.iconAndTitle', 'content.iconOnly', 'content.titleOnly', 'layoutCentered', 'selectedImage'],
  ['backgroundColor.normal', 'backgroundColor.selected', 'borderColor', 'borderWidth', 'cornerRadius', 'margin'],
  ['animation.lottie', 'animation.pag', 'animation.rive', 'animation.gif', 'animation.off', 'animationSpeed',
    'configuration', 'tagCloud'],
  ['sample.tagCloud', 'sample.imageTag', 'sample.tagContainer'],
  ['reset']
];

const SECTION_TITLES: string[] = ['标题与图标（参照 CYLFlatDesignTabBarItem）', CYLExampleLocalizedString('背景、边框与圆角（参照 CYLBadgeView）'),
  CYLExampleLocalizedString('动效图标（CYLTabBarController 动效引擎）'), CYLExampleLocalizedString('Android 标签库示例（Swift 复刻）'), CYLExampleLocalizedString('其它')];

const ACTION_TITLES: Map<string, string> = new Map<string, string>([
  ['iconColor.normal', CYLExampleLocalizedString('设置 iconColor（normal）')],
  ['iconColor.selected', CYLExampleLocalizedString('设置 iconColor（selected）')],
  ['titleColor.normal', CYLExampleLocalizedString('设置文字颜色 titleTextAttributes（normal）')],
  ['titleColor.selected', CYLExampleLocalizedString('设置文字颜色 titleTextAttributes（selected）')],
  ['font', CYLExampleLocalizedString('设置字体 NSFontAttributeName')],
  ['imageTitleSpacing', CYLExampleLocalizedString('设置 icon 与文字间距 imageTitleSpacing')],
  ['imageSize', CYLExampleLocalizedString('设置 icon 大小 imageSize')],
  ['imageInsets', CYLExampleLocalizedString('设置 imageInsets')],
  ['titlePositionAdjustment', CYLExampleLocalizedString('设置 titlePositionAdjustment')],
  ['imagePositionAdjustment', CYLExampleLocalizedString('设置 imagePositionAdjustment')],
  ['content.iconAndTitle', CYLExampleLocalizedString('显示 icon + title')],
  ['content.iconOnly', CYLExampleLocalizedString('只显示 icon')],
  ['content.titleOnly', CYLExampleLocalizedString('只显示 title')],
  ['layoutCentered', CYLExampleLocalizedString('切换 layoutCentered（只有 icon 或 title 时居中）')],
  ['selectedImage', CYLExampleLocalizedString('切换选中图片 selectedImage')],
  ['backgroundColor.normal', CYLExampleLocalizedString('设置背景色 backgroundColor（normal）')],
  ['backgroundColor.selected', CYLExampleLocalizedString('设置背景色 backgroundColor（selected）')],
  ['borderColor', CYLExampleLocalizedString('设置边框颜色 borderColor')],
  ['borderWidth', CYLExampleLocalizedString('设置边框宽度 borderWidth')],
  ['cornerRadius', CYLExampleLocalizedString('设置圆角 cornerRadius（0 为胶囊）')],
  ['margin', CYLExampleLocalizedString('设置内边距 margin')],
  ['animation.lottie', CYLExampleLocalizedString('Lottie 动效图标')],
  ['animation.pag', CYLExampleLocalizedString('PAG 动效图标')],
  ['animation.rive', CYLExampleLocalizedString('Rive 动效图标')],
  ['animation.gif', CYLExampleLocalizedString('GIF 动效图标')],
  ['animation.off', CYLExampleLocalizedString('关闭动效（静态图标）')],
  ['animationSpeed', CYLExampleLocalizedString('设置动效速度 animationSpeed')],
  ['configuration', CYLExampleLocalizedString('配置文件 / 字典（map）初始化')],
  ['tagCloud', CYLExampleLocalizedString('标签云：android-tagview 的初始化方式')],
  ['sample.tagCloud', CYLExampleLocalizedString('android-tagview 示例（Swift 版）')],
  ['sample.imageTag', CYLExampleLocalizedString('TagViewGroup 示例：图片标签')],
  ['sample.tagContainer', CYLExampleLocalizedString('AndroidTagView 示例：标签容器')],
  ['reset', CYLExampleLocalizedString('重置 reset')]
]);

/** The rows that open another screen, by route (the iOS class name). */
const ROUTES: Map<string, string> = new Map<string, string>([
  ['configuration', 'CYLTagConfigurationDemoViewController'],
  ['tagCloud', 'CYLTagCloudDemoViewController'],
  ['sample.tagCloud', 'CYLTagCloudSampleViewController'],
  ['sample.imageTag', 'CYLImageTagSampleViewController'],
  ['sample.tagContainer', 'CYLTagContainerSampleViewController']
]);

/** A fixed palette, so that screenshots are stable. */
const PALETTE: string[] = [CYLSystemColor.orange, CYLSystemColor.purple, CYLSystemColor.teal, CYLSystemColor.pink,
  CYLSystemColor.indigo, CYLSystemColor.green];

function colorAtStep(step: number): string {
  return PALETTE[step % PALETTE.length];
}

/** The color at 15 % alpha. */
function lightColorAtStep(step: number): string {
  return `#26${colorAtStep(step).substring(1)}`;
}

/** The gray of `UIColor(white:alpha: 1)`. */
function white(value: number): string {
  const v = Math.round(value * 255).toString(16).padStart(2, '0');
  return `#${v}${v}${v}`;
}

function sizeString(s: CYLSize): string {
  return `{${s.width}, ${s.height}}`;
}

function insetsString(i: CYLEdgeInsets): string {
  return `{${i.top}, ${i.left}, ${i.bottom}, ${i.right}}`;
}

function offsetString(o: CYLOffset): string {
  return `{${o.horizontal}, ${o.vertical}}`;
}

/** Title key, icon and selected icon of the preview's tags (SF Symbols in iOS; the nearest HarmonyOS images). */
interface CYLStyleSample {
  title: string;
  image: CYLImage;
  selectedImage: CYLImage;
}

const SAMPLES: CYLStyleSample[] = [
  { title: CYLExampleLocalizedString('首页'), image: $r('app.media.b_home_normal'), selectedImage: $r('app.media.b_home_highlight') },
  { title: CYLExampleLocalizedString('同城'), image: $r('sys.media.ohos_ic_public_location'), selectedImage: $r('app.media.b_fishpond_highlight') },
  { title: CYLExampleLocalizedString('消息'), image: $r('app.media.b_message_normal'), selectedImage: $r('app.media.b_message_highlight') },
  { title: CYLExampleLocalizedString('我的'), image: $r('app.media.b_account_normal'), selectedImage: $r('app.media.b_account_highlight') },
  { title: CYLExampleLocalizedString('一个很长很长的标签标题'), image: $r('sys.media.ohos_ic_public_ok'), selectedImage: $r('sys.media.ohos_ic_public_ok_filled') },
  { title: CYLExampleLocalizedString('已禁用'), image: $r('sys.media.ohos_ic_public_cancel'), selectedImage: $r('sys.media.ohos_ic_public_cancel') }
];

/** The animated icons; the HarmonyOS core plays Lottie only (PAG, Rive and GIF show the static icons). */
const ANIMATION_FILES: Map<string, string[]> = new Map<string, string[]>([
  ['lottie', ['asset:tab_home_animate.json', 'asset:tab_me_animate.json']]
]);

export function demoStyle(): CYLMenuStyle {
  const style = new CYLMenuStyle();
  style.setIconColor(CYLSystemColor.blue, CYLControlState.NORMAL);
  style.setIconColor('#FFFFFF', CYLControlState.SELECTED);
  style.selectedAppearance.backgroundColor = CYLSystemColor.blue;
  style.selectedAppearance.borderColor = CYLSystemColor.blue;
  style.imageSize = new CYLSize(16, 16);
  style.imageTitleSpacing = 4;
  style.itemHeight = 34;
  style.sectionInsets = new CYLEdgeInsets(12, 16, 12, 16);
  return style;
}

@Component
export struct CYLTagStylePage {
  /** Root of the 样式 tab: no back button. */
  showsBack: boolean = false;
  @State version: number = 0;
  @State previewHeight: number = 0;
  private tagList: CYLTagListState = new CYLTagListState();
  private controller: CYLTagListController = new CYLTagListController();
  private style: CYLMenuStyle = demoStyle();
  private content: CYLTagStyleDemoContent = CYLTagStyleDemoContent.iconAndTitle;
  /** "lottie", "gif", "pag", "rive", or undefined for static icons. */
  private animationLibrary: string | undefined = undefined;
  private usesSelectedImage: boolean = true;
  /** How many times each action ran, to cycle through its values. */
  private steps: Map<string, number> = new Map<string, number>();

  aboutToAppear(): void {
    this.tagList.selectionMode = CYLMenuSelectionMode.multiple;
    this.tagList.showsSectionHeaders = false;
    this.tagList.isScrollEnabled = false;
    this.tagList.menuDelegate = {
      menuDidChangeContentHeight: (menu: Object, height: number) => this.previewHeight = height
    };
    this.reloadItems();
    this.applyStyle();
  }

  private nextStep(identifier: string): number {
    const step = this.steps.get(identifier) ?? 0;
    this.steps.set(identifier, step + 1);
    return step;
  }

  private appearances(): CYLTagAppearance[] {
    return [this.style.normalAppearance, this.style.selectedAppearance, this.style.disabledAppearance];
  }

  /** Performs an action as a tap on its row does. */
  performAction(identifier: string): void {
    const route = ROUTES.get(identifier);
    if (route !== undefined) {
      CYLDemoNav.push(route, new Object());
      return;
    }
    const style = this.style;
    const step = this.nextStep(identifier);
    switch (identifier) {
      case 'iconColor.normal':
        style.setIconColor(colorAtStep(step), CYLControlState.NORMAL);
        break;
      case 'iconColor.selected': {
        const colors = [CYLSystemColor.yellow, '#000000', '#FFFFFF'];
        style.setIconColor(colors[step % colors.length], CYLControlState.SELECTED);
        break;
      }
      case 'titleColor.normal':
        style.setTitleTextAttributes(undefined, colorAtStep(step), CYLControlState.NORMAL);
        break;
      case 'titleColor.selected':
        style.setTitleTextAttributes(undefined, white(1 - 0.15 * (step % 3)), CYLControlState.SELECTED);
        break;
      case 'font': {
        // iOS: semibold 16, 12, italic 15 (HarmonyOS's CYLFont has no italic: regular 15), 14.
        const fonts = [new CYLFont(16, FontWeight.Medium), CYLFont.systemFont(12), CYLFont.systemFont(15),
          CYLFont.systemFont(14)];
        this.appearances().forEach((a: CYLTagAppearance) => a.font = fonts[step % fonts.length]);
        break;
      }
      case 'imageTitleSpacing':
        style.imageTitleSpacing = [10, 0, 4][step % 3];
        break;
      case 'imageSize': {
        const side = [20, 10, 14][step % 3];
        style.imageSize = new CYLSize(side, side);
        break;
      }
      case 'imageInsets': {
        const inset = step % 2 === 0 ? 3 : 0;
        style.imageInsets = new CYLEdgeInsets(inset, inset, inset, inset);
        break;
      }
      case 'titlePositionAdjustment':
        style.titlePositionAdjustment = [new CYLOffset(0, -4), new CYLOffset(4, 0), CYLOffset.ZERO][step % 3];
        break;
      case 'imagePositionAdjustment':
        style.imagePositionAdjustment = [new CYLOffset(0, -4), new CYLOffset(-4, 0), CYLOffset.ZERO][step % 3];
        break;
      case 'content.iconAndTitle':
      case 'content.iconOnly':
      case 'content.titleOnly':
        this.content = identifier === 'content.iconOnly' ? CYLTagStyleDemoContent.iconOnly :
          identifier === 'content.titleOnly' ? CYLTagStyleDemoContent.titleOnly : CYLTagStyleDemoContent.iconAndTitle;
        this.reloadItems();
        break;
      case 'layoutCentered':
        style.layoutCentered = !style.layoutCentered;
        break;
      case 'selectedImage':
        this.usesSelectedImage = !this.usesSelectedImage;
        this.reloadItems();
        break;
      case 'backgroundColor.normal':
        style.normalAppearance.backgroundColor = lightColorAtStep(step);
        break;
      case 'backgroundColor.selected':
        style.selectedAppearance.backgroundColor = colorAtStep(step);
        style.selectedAppearance.borderColor = colorAtStep(step);
        break;
      case 'borderColor':
        style.normalAppearance.borderColor = colorAtStep(step);
        break;
      case 'borderWidth': {
        const width = [2, 0, 1, 0.5][step % 4];
        this.appearances().forEach((a: CYLTagAppearance) => a.borderWidth = width);
        break;
      }
      case 'cornerRadius': {
        const radius = [0, 8, 3][step % 3];
        this.appearances().forEach((a: CYLTagAppearance) => a.cornerRadius = radius);
        break;
      }
      case 'margin': {
        const margin = [18, 4, 10][step % 3];
        this.appearances().forEach((a: CYLTagAppearance) => a.margin = margin);
        break;
      }
      case 'animation.lottie':
      case 'animation.pag':
      case 'animation.rive':
      case 'animation.gif':
      case 'animation.off': {
        const library = identifier.substring('animation.'.length);
        this.animationLibrary = library === 'off' ? undefined : library;
        this.reloadItems();
        this.applyStyle();
        // Show the animations: play the icons.
        this.controller.playAll();
        return;
      }
      case 'animationSpeed':
        style.animationSpeed = [0.5, 2, 1][step % 3];
        break;
      case 'reset':
        this.style = demoStyle();
        this.content = CYLTagStyleDemoContent.iconAndTitle;
        this.animationLibrary = undefined;
        this.usesSelectedImage = true;
        this.steps.clear();
        this.reloadItems();
        break;
      default:
        break;
    }
    this.applyStyle();
  }

  value(identifier: string): string {
    const style = this.style;
    switch (identifier) {
      case 'imageTitleSpacing':
        return style.imageTitleSpacing.toFixed(0);
      case 'imageSize':
        return sizeString(style.imageSize);
      case 'imageInsets':
        return insetsString(style.imageInsets);
      case 'titlePositionAdjustment':
        return offsetString(style.titlePositionAdjustment);
      case 'imagePositionAdjustment':
        return offsetString(style.imagePositionAdjustment);
      case 'layoutCentered':
        return style.layoutCentered ? 'YES' : 'NO';
      case 'selectedImage':
        return this.usesSelectedImage ? 'YES' : 'NO';
      case 'font': {
        const font = style.normalAppearance.font;
        return `System${font.weight === FontWeight.Normal ? '' : '-Semibold'} ${font.size.toFixed(0)}`;
      }
      case 'borderWidth':
        return style.normalAppearance.borderWidth.toFixed(1);
      case 'cornerRadius':
        return style.normalAppearance.cornerRadius.toFixed(0);
      case 'margin':
        return style.normalAppearance.margin.toFixed(0);
      case 'animationSpeed':
        return style.animationSpeed.toFixed(1);
      default:
        break;
    }
    if (identifier.startsWith('animation.')) {
      const library = identifier.substring('animation.'.length);
      const current = library === 'off' ? this.animationLibrary === undefined : library === (this.animationLibrary ?? '');
      return current ? '✓' : '';
    }
    if (identifier.startsWith('content.')) {
      const current = ['content.iconAndTitle', 'content.iconOnly', 'content.titleOnly'][this.content];
      return identifier === current ? '✓' : '';
    }
    return '';
  }

  reloadItems(): void {
    const items: CYLExampleMenuItem[] = [];
    const iconOnly = this.content === CYLTagStyleDemoContent.iconOnly;
    const titleOnly = this.content === CYLTagStyleDemoContent.titleOnly;
    for (const sample of SAMPLES) {
      const item = new CYLExampleMenuItem(iconOnly ? '' : sample.title);
      item.image = titleOnly ? undefined : sample.image;
      item.selectedImage = (titleOnly || !this.usesSelectedImage) ? undefined : sample.selectedImage;
      item.isEnabled = sample.title !== '已禁用';
      if (this.animationLibrary !== undefined && item.isEnabled && !titleOnly) {
        item.animationURL = this.animationURL(items.length);
      }
      items.push(item);
    }
    const selection = this.tagList.selectedIndexPaths;
    this.tagList.menuDataSource = new CYLExampleMenuSource([new CYLExampleMenuSection('', items)]);
    this.tagList.reloadMenuData();
    const first: CYLIndexPath = { section: 0, item: 0 };
    this.tagList.selectedIndexPaths = selection.length === 0 ? [first] : selection;
  }

  /** The demo's animated icon for a tag (Lottie only on HarmonyOS). */
  animationURL(index: number): string | undefined {
    const names = this.animationLibrary !== undefined ? ANIMATION_FILES.get(this.animationLibrary) : undefined;
    return names !== undefined && names.length > 0 ? names[index % names.length] : undefined;
  }

  applyStyle(): void {
    this.tagList.style = this.style;
    this.previewHeight = this.tagList.contentHeight;
    this.version++;
  }

  @Builder
  actionRow(identifier: string, last: boolean) {
    Row({ space: 8 }) {
      Text(ACTION_TITLES.get(identifier) ?? identifier).fontSize(15).fontColor(CYLSystemColor.label).layoutWeight(1)
      Text(this.version >= 0 ? this.value(identifier) : '').fontSize(15).fontColor(CYLSystemColor.secondaryLabel)
    }
    .width('100%')
    .constraintSize({ minHeight: 44 })
    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
    .border({ width: { bottom: last ? 0 : 0.5 }, color: CYLSystemColor.separator })
    .id(`style-${identifier}`)
    .onClick(() => this.performAction(identifier))
  }

  build() {
    Column() {
      CYLDemoBar({ title: CYLExampleLocalizedString('标签样式'), showsBack: this.showsBack })
      CYLTagListView({ tagList: this.tagList, controller: this.controller })
        .height(this.previewHeight)
        .id('styleTagList')
      Divider().strokeWidth(0.5).color(CYLSystemColor.separator)
      Scroll() {
        Column() {
          ForEach(ACTIONS, (actions: string[], section: number) => {
            cylSectionHeader(SECTION_TITLES[section])
            Column() {
              ForEach(actions, (identifier: string, index: number) => {
                this.actionRow(identifier, index === actions.length - 1)
              }, (identifier: string) => `${identifier}-${this.version}`)
            }
            .backgroundColor(Color.White)
            .borderRadius(10)
            .margin({ left: 16, right: 16 })
          }, (actions: string[], section: number) => `${section}`)
        }
        .padding({ bottom: 24 })
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .backgroundColor(CYLSystemColor.groupedBackground)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .id('CYLTagStyleDemoViewController')
  }
}
