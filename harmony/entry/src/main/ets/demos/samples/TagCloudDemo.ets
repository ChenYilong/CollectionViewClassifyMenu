import { CYLExampleLocalizedString } from '../../data/CYLExampleLocalization';
/**
 * CYLTagCloudDemoViewController.swift — 标签云：android-tagview 的初始化方式。先创建 CYLTagListState，设置行距、标签间距与
 * 内边距，再 addTagsWithTitles / addTag 添加 CYLTag；点击与删除用 tagClickHandler、tagDeleteHandler 监听。下方是同样的
 * 标签，用配置字典（CYLTagListKey.tags）创建。
 */
import { CYLColor, CYLEdgeInsets, CYLTag, CYLTagListState, CYLTagListView } from '@cyl/classifymenu';
import { CYLDemoBar } from '../DemoNav';
import { GROUPED_BACKGROUND, SECONDARY_LABEL, cylFormat } from './SampleSupport';

export class CYLTagCloudDemoData {
  /** The continents of android-tagview's sample. */
  static readonly continents: string[] = ['Asia', 'Africa', 'North America', 'South America', 'Antarctica', 'Europe',
    'Australia'];

  /** android-tagview's "add a tag in details": every look property of its Tag. */
  static detailedTag(): CYLTag {
    const tag = CYLTag.withHex(7, 'Tag Text', '#DDDDDD');
    tag.textColor = CYLColor.WHITE;
    tag.highlightedBackgroundColor = CYLColor.white(0.33);
    tag.cornerRadius = 20;
    tag.textSize = 14;
    tag.borderWidth = 1;
    tag.borderColor = CYLColor.WHITE;
    tag.isDeletable = true;
    return tag;
  }

  /** Deletable, a larger text, a background image, a delete icon. */
  static styledTags(): CYLTag[] {
    const blue = CYLTag.withHex(0, CYLExampleLocalizedString('可删除'), '#00BFFF');
    blue.textColor = CYLColor.WHITE;
    blue.borderWidth = 0;
    blue.isDeletable = true;
    blue.highlightedBackgroundColor = CYLColor.rgb(0, 0.5, 0.7);
    const large = new CYLTag(0, CYLExampleLocalizedString('大字号'), '#FFFF9500');
    large.textColor = CYLColor.WHITE;
    large.textSize = 22;
    large.borderWidth = 0;
    const picture = new CYLTag(0, CYLExampleLocalizedString('背景图'));
    picture.backgroundImage = $r('app.media.c_tag_gradient');
    picture.textColor = CYLColor.WHITE;
    picture.borderWidth = 0;
    const custom = new CYLTag(0, CYLExampleLocalizedString('自定义删除'), '#FFFF2D55');
    custom.textColor = CYLColor.WHITE;
    custom.borderWidth = 0;
    custom.isDeletable = true;
    custom.deleteIndicatorTitle = '⊗';
    custom.deleteIndicatorColor = CYLColor.white(1, 0.8);
    custom.deleteIndicatorSize = 18;
    return [blue, large, picture, custom];
  }

  /** The configuration of the lower list: the same kinds of tags, as strings and dictionaries. */
  static mapConfiguration(): string {
    return '{"style": {"lineSpacing": 5, "interitemSpacing": 3, "tagContentInsets": "{3, 10, 3, 10}"}, ' +
      '"scrollEnabled": false, "tags": ["Asia", "Europe", {"title": "Africa", "id": 3, "deletable": true, ' +
      '"style": {"normal": {"backgroundColor": "#00BFFF", "textColor": "#FFFFFF", "borderWidth": 0, ' +
      '"cornerRadius": 0}, "highlightedBackgroundColor": "#88363636"}}, ' +
      '{"title": "Australia", "image": "system:globe"}]}';
  }
}

@Component
export struct CYLTagCloudDemoPage {
  @State eventText: string = CYLExampleLocalizedString('点击标签，或点 × 删除');
  private codeList: CYLTagListState = new CYLTagListState();
  private mapList: CYLTagListState = new CYLTagListState();

  aboutToAppear(): void {
    // android-tagview: TagView tagview2 = new TagView(this); tagview2.setLineMargin(20f); …
    const list = this.codeList;
    list.lineSpacing = 5;
    list.interitemSpacing = 3;
    list.tagContentInsets = new CYLEdgeInsets(3, 10, 3, 10);
    list.isScrollEnabled = false;
    list.addTagsWithTitles(CYLTagCloudDemoData.continents);
    list.addTag(CYLTagCloudDemoData.detailedTag());
    list.addTags(CYLTagCloudDemoData.styledTags());
    list.tagClickHandler = (index: number, tag: CYLTag) => {
      this.eventText = cylFormat(CYLExampleLocalizedString('点击第 %ld 个「%@」'), index, tag.title);
    };
    list.tagDeleteHandler = (index: number, tag: CYLTag) => {
      this.eventText = cylFormat(CYLExampleLocalizedString('删除第 %ld 个「%@」'), index, tag.title);
    };
    this.mapList.tagDeleteHandler = (index: number, tag: CYLTag) => {
      this.eventText = cylFormat(CYLExampleLocalizedString('删除第 %ld 个「%@」'), index, tag.title);
    };
  }

  @Builder
  caption(text: string, id: string) {
    Text(text)
      .fontSize(13)
      .fontColor(SECONDARY_LABEL)
      .padding({ left: 16, right: 16 })
      .width('100%')
      .id(id)
  }

  build() {
    Column() {
      CYLDemoBar({ title: CYLExampleLocalizedString('标签云（android-tagview）') })
      Scroll() {
        Column({ space: 8 }) {
          this.caption(CYLExampleLocalizedString('代码初始化：addTags(withTitles:)、addTag(_:)'), 'tagCloud.codeCaption')
          CYLTagListView({ tagList: this.codeList })
          this.caption(CYLExampleLocalizedString('字典初始化：CYLTagListViewTags').replace('CYLTagListViewTags', 'CYLTagListKey.tags'), 'tagCloud.mapCaption')
          CYLTagListView({ tagList: this.mapList, configuration: CYLTagCloudDemoData.mapConfiguration() })
          this.caption(this.eventText, 'tagCloud.event')
        }
        .padding({ top: 12 })
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GROUPED_BACKGROUND)
  }
}
