import { CYLExampleLocalizedString } from '../../data/CYLExampleLocalization';
/**
 * CYLTagContainerSample.swift — whilu/AndroidTagView's sample (MainActivity and content_main.xml): five tag
 * containers, each with the attributes of the sample's XML, and "add tag". The library draws and lays out everything;
 * this screen passes the data, the attribute values, and handles the taps.
 */
import { deviceInfo } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import {
  CYLColor, CYLEdgeInsets, CYLIndexPath, CYLMenuStyle, CYLSize, CYLTag, CYLTagAppearance, CYLTagColorTheme,
  CYLTagColors, CYLTagDeleteIndicatorPlacement, CYLTagListState, CYLTagListView, CYLTagRowAlignment
} from '@cyl/classifymenu';
import { CYLDemoBar } from '../DemoNav';
import { CYLSampleButton, SYSTEM_GRAY, SYSTEM_TEAL, cylFormat, cylToast } from './SampleSupport';

/** The sample's lists and colors. */
export class CYLTagContainerSampleData {
  static readonly list1: string[] = ['Java', 'C++', 'Python', 'Swift',
    '你好，这是一个TAG。你好，这是一个TAG。你好，这是一个TAG。你好，这是一个TAG。', 'PHP', 'JavaScript', 'Html', // NOLOCALIZE: sample data: deliberately multilingual tags of AndroidTagView's sample
    CYLTagContainerSampleData.welcomeTitle()];
  static readonly list2: string[] = ['China', 'USA', 'Austria', 'Japan', 'Sudan', 'Spain', 'UK', 'Germany', 'Niger',
    'Poland', 'Norway', 'Uruguay', 'Brazil'];
  static readonly list3: string[] = ['Persian', '波斯语', 'فارسی', 'Hello', '你好', 'سلام']; // NOLOCALIZE: sample data: deliberately multilingual tags of AndroidTagView's sample
  static readonly list4: string[] = ['Adele', 'Whitney Houston'];
  static readonly list5: string[] = ['Custom Red Color', 'Custom Blue Color'];

  /**
   * The last tag of list1: the running system, as the iOS sample ("Welcome to use iOS 27.2 CollectionViewClassifyMenu"),
   * e.g. "Welcome to use HarmonyOS 6.0.0 CollectionViewClassifyMenu".
   */
  static welcomeTitle(): string {
    const name = deviceInfo.distributionOSName || 'HarmonyOS';
    const version = deviceInfo.distributionOSVersion || deviceInfo.displayVersion;
    return `Welcome to use ${name} ${version} CollectionViewClassifyMenu`;
  }

  /** {backgroundColor, tagBorderColor, tagTextColor, tagSelectedBackgroundColor} of list5. */
  static colors5(): CYLTagColors[] {
    return ['#ff0000', '#0000ff'].map((hex: string) => new CYLTagColors(CYLColor.fromHex(hex), CYLColor.BLACK,
      CYLColor.WHITE, CYLColor.fromHex('#999999')));
  }

  /** The default image (yellow_avatar): a round yellow face. */
  static avatar(): image.PixelMap | undefined {
    try {
      const canvas = new OffscreenCanvas(48, 48);
      const c = canvas.getContext('2d');
      c.fillStyle = '#FFCC00';
      c.beginPath();
      c.arc(24, 24, 24, 0, Math.PI * 2);
      c.fill();
      c.fillStyle = '#A2845E';
      c.beginPath();
      c.arc(17, 19, 3, 0, Math.PI * 2);
      c.fill();
      c.beginPath();
      c.arc(31, 19, 3, 0, Math.PI * 2);
      c.fill();
      c.strokeStyle = '#A2845E';
      c.lineWidth = 3;
      c.beginPath();
      c.arc(24, 26, 11, 0.2 * Math.PI, 0.8 * Math.PI);
      c.stroke();
      return c.getPixelMap(0, 0, 48, 48);
    } catch (e) {
      return undefined;
    }
  }
}

/**
 * A TagContainerLayout with the library's defaults: the container's #11FF0000 background, a 0.5 vp #22FF0000 border
 * with a 10 vp radius, 10 vp padding.
 */
function makeContainer(configure: (list: CYLTagListState, style: CYLMenuStyle) => void): CYLTagListState {
  const list = new CYLTagListState();
  const style = CYLMenuStyle.tagContainer();
  style.sectionInsets = new CYLEdgeInsets(10, 10, 10, 10);
  style.backgroundColor = CYLColor.rgb(1, 0, 0, 0x11 / 255);
  list.containerBorderWidth = 0.5;
  list.containerBorderColor = CYLColor.rgb(1, 0, 0, 0x22 / 255);
  list.containerCornerRadius = 10;
  list.isScrollEnabled = false;
  // tag_clickable is false by default; the sample turns it on where it wants taps.
  list.allowsTapping = false;
  list.colorTheme = CYLTagColorTheme.pureCyan;
  configure(list, style);
  list.style = style;
  return list;
}

function setAllDeletable(list: CYLTagListState): void {
  list.tagDataSource.tags.forEach((tag: CYLTag) => tag.isDeletable = true);
  list.reloadMenuData();
}

@Component
export struct CYLTagContainerSamplePage {
  @State text: string = '';
  private containers: CYLTagListState[] = [];

  aboutToAppear(): void {
    // tagcontainerLayout1: drag, clickable, cross, pure teal, 10 vp spacing, the default avatar.
    const first = makeContainer((list: CYLTagListState, style: CYLMenuStyle) => {
      style.interitemSpacing = 10;
      style.lineSpacing = 10;
      style.imageSize = new CYLSize(24, 24);
      style.imageCornerRadius = 12;
      list.allowsReordering = true;
      list.allowsTapping = true;
      list.colorTheme = CYLTagColorTheme.pureTeal;
      list.removesItemsOnDelete = false;
      list.defaultTagImage = CYLTagContainerSampleData.avatar();
    });
    first.setTagsWithTitles(CYLTagContainerSampleData.list1);
    setAllDeletable(first);
    first.tagClickHandler = (position: number, tag: CYLTag) =>
      cylToast(cylFormat(CYLExampleLocalizedString('点击位置：%ld，文字：%@'), position, tag.title));
    first.tagLongPressHandler = (position: number) => this.confirmDelete(position);
    first.longPressAccessibilityActionName = CYLExampleLocalizedString('删除');
    first.tagDeleteHandler = (position: number) => cylToast(cylFormat(CYLExampleLocalizedString('点了标签的叉！位置 = %ld'), position));

    // tagcontainerLayout2: transparent, a 4 vp #3300ff00 border, square, drag, not clickable, random colors.
    const second = makeContainer((list: CYLTagListState, style: CYLMenuStyle) => {
      style.interitemSpacing = 10;
      style.lineSpacing = 10;
      style.backgroundColor = CYLColor.CLEAR;
      list.containerBorderColor = CYLColor.rgb(0, 1, 0, 0x33 / 255);
      list.containerBorderWidth = 4;
      list.containerCornerRadius = 0;
      list.allowsReordering = true;
      list.colorTheme = CYLTagColorTheme.random;
    });
    second.setTagsWithTitles(CYLTagContainerSampleData.list2);

    // tagcontainerLayout3: right-aligned, right-to-left, white tags with a #330000ff border, selectable, cross.
    const third = makeContainer((list: CYLTagListState, style: CYLMenuStyle) => {
      style.interitemSpacing = 10;
      style.lineSpacing = 10;
      style.backgroundColor = CYLColor.CLEAR;
      style.rowAlignment = CYLTagRowAlignment.trailing;
      style.maximumTitleLength = 18;
      style.reversesTitleCharacters = true;
      style.deleteIndicatorPlacement = CYLTagDeleteIndicatorPlacement.leading;
      style.tagContentInsets = new CYLEdgeInsets(10, 15, 10, 15);
      const appearances: CYLTagAppearance[] = [style.normalAppearance, style.selectedAppearance];
      appearances.forEach((appearance: CYLTagAppearance) => {
        appearance.backgroundColor = CYLColor.WHITE;
        appearance.borderColor = CYLColor.rgb(0, 0, 1, 0x33 / 255);
        appearance.borderWidth = 1;
        appearance.cornerRadius = 1;
        appearance.textColor = CYLColor.white(0x66 / 255);
      });
      style.selectedAppearance.backgroundColor = CYLColor.rgb(1, 0x76 / 255, 0x69 / 255, 0x33 / 255);
      list.containerBorderColor = CYLColor.white(0x66 / 255, 0x33 / 255);
      list.containerCornerRadius = 0;
      list.allowsTapping = true;
      list.colorTheme = CYLTagColorTheme.none;
      list.removesItemsOnDelete = false;
    });
    third.setTagsWithTitles(CYLTagContainerSampleData.list3);
    setAllDeletable(third);
    third.tagClickHandler = (position: number, tag: CYLTag) => {
      const selected = third.selectedIndexPaths.map((p: CYLIndexPath) => p.item);
      // Deselect all when an unselected tag is tapped while others are selected; otherwise show the toast.
      if (selected.length === 0 || selected.includes(position)) {
        cylToast(cylFormat(CYLExampleLocalizedString('点击位置：%ld，文字：%@'), position, tag.title));
      } else {
        third.deselectAllItems();
      }
    };
    third.tagLongPressHandler = (position: number) => {
      third.toggleSelection({ section: 0, item: position });
      cylToast(cylFormat(CYLExampleLocalizedString('已选位置：%@'),
        third.selectedIndexPaths.map((p: CYLIndexPath) => `${p.item}`).join(', ')));
    };
    third.longPressAccessibilityActionName = CYLExampleLocalizedString('选择或取消选择');
    third.selectedTagDragHandler = (index: number, tag: CYLTag) => cylToast(cylFormat(CYLExampleLocalizedString('拖动：%@'), tag.title));

    // tagcontainerLayout4: centered, clickable, a 2 s black ripple at alpha 47, pure teal.
    const fourth = makeContainer((list: CYLTagListState, style: CYLMenuStyle) => {
      style.interitemSpacing = 10;
      style.lineSpacing = 10;
      style.rowAlignment = CYLTagRowAlignment.center;
      style.rippleColor = CYLColor.BLACK;
      style.rippleAlpha = 47 / 255;
      style.rippleDuration = 2;
      list.allowsTapping = true;
      list.colorTheme = CYLTagColorTheme.pureTeal;
    });
    fourth.setTagsWithTitles(CYLTagContainerSampleData.list4);
    fourth.tagClickHandler = (position: number, tag: CYLTag) =>
      cylToast(cylFormat(CYLExampleLocalizedString('点击位置：%ld，文字：%@'), position, tag.title));

    // tagcontainerLayout5: a 4 vp square border, not clickable, random theme, but custom colors per tag.
    const fifth = makeContainer((list: CYLTagListState, style: CYLMenuStyle) => {
      style.interitemSpacing = 10;
      style.lineSpacing = 10;
      list.containerBorderWidth = 4;
      list.containerCornerRadius = 0;
      list.colorTheme = CYLTagColorTheme.random;
    });
    fifth.setTagsWithTitles(CYLTagContainerSampleData.list5, CYLTagContainerSampleData.colors5());

    this.containers = [first, second, third, fourth, fifth];
  }

  addTag(): void {
    this.containers[0].addTagWithTitle(this.text);
  }

  /** onTagLongClick: "You will delete this tag!". */
  confirmDelete(position: number): void {
    this.getUIContext().showAlertDialog({
      title: CYLExampleLocalizedString('长按'),
      message: CYLExampleLocalizedString('将删除这个标签！'),
      primaryButton: { value: CYLExampleLocalizedString('删除'), fontColor: Color.Red, action: () => {
        const first = this.containers[0];
        if (position < first.tags.length) {
          first.removeTag(position);
        }
      } },
      secondaryButton: { value: CYLExampleLocalizedString('取消'), action: () => {
      } }
    });
  }

  build() {
    Column() {
      CYLDemoBar({ title: CYLExampleLocalizedString('标签容器示例') })
      Scroll() {
        Column() {
          CYLTagListView({ tagList: this.containers[0] })
          Row({ space: 12 }) {
            Stack({ alignContent: Alignment.Bottom }) {
              TextInput({ placeholder: CYLExampleLocalizedString('新标签'), text: this.text })
                .backgroundColor(Color.Transparent)
                .borderRadius(0)
                .padding({ left: 0, right: 0 })
                .height(44)
                .accessibilityText(CYLExampleLocalizedString('新标签'))
                .id('sample.newTag')
                .onChange((value: string) => this.text = value)
              Column().width('100%').height(1).backgroundColor(SYSTEM_TEAL)
            }
            .layoutWeight(1)
            CYLSampleButton({ title: CYLExampleLocalizedString('添加'), identifier: 'sample.add', color: SYSTEM_GRAY, action: () => this.addTag() })
              .layoutWeight(1)
          }
          .margin({ top: 12 })
          CYLTagListView({ tagList: this.containers[1] }).margin({ top: 12 })
          CYLTagListView({ tagList: this.containers[2] }).margin({ top: 20 })
          CYLTagListView({ tagList: this.containers[3] }).margin({ top: 20 })
          CYLTagListView({ tagList: this.containers[4] }).margin({ top: 20 })
        }
        .padding(16)
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CYLColor.white(0.98))
  }
}
