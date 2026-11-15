/**
 * CYLImageTagSample.swift — shellljx/TagViewGroup's sample: MainActivity (a picture with two tag groups; a tap toggles
 * them), TagEditActivity (create, drag, turn and delete groups, then save) and TagListActivity (30 pictures). The
 * library's CYLImageTagView draws everything; these screens pass the data and handle the events.
 */
import {
  CYLImageTag, CYLImageTagDirection, CYLImageTagGroup, CYLImageTagView, CYLImageTagViewComponent, CYLPoint
} from '@cyl/classifymenu';
import { CYLDemoBar, CYLDemoNav } from '../DemoNav';
import { CYLSamplePicture, CYLSampleButton, SECONDARY_LABEL, SYSTEM_PINK, cylFormat, cylToast } from './SampleSupport';

/** The sample's DataRepo: the groups in memory, shared by the three screens. */
export class CYLImageTagSampleData {
  static tagGroups: CYLImageTagGroup[] = CYLImageTagSampleData.initialGroups();

  static initialGroups(): CYLImageTagGroup[] {
    const leather = new CYLImageTag('头层牛皮', CYLImageTagDirection.rightTop, 'http://www.baidu.com');
    const shoes = new CYLImageTag('英伦加绒青年棕色保暖鞋子。', CYLImageTagDirection.rightCenter,
      'http://blog.licrafter.com');
    const brand = new CYLImageTag('PLAYBOY/花花公子', CYLImageTagDirection.rightBottom, 'http://mc.licrafter.com');
    const good = new CYLImageTag('很不错的鞋子', CYLImageTagDirection.rightCenter, 'http://mc.licrafter.com');
    return [new CYLImageTagGroup([leather, shoes, brand], new CYLPoint(0.4, 0.5)),
      new CYLImageTagGroup([good], new CYLPoint(0.3, 0.2))];
  }
}

/** The parameter of CYLImageTagEditViewController: called after 保存. */
export class CYLImageTagEditParam {
  onSave: () => void;

  constructor(onSave: () => void) {
    this.onSave = onSave;
  }
}

/** MainActivity. */
@Component
export struct CYLImageTagSamplePage {
  @State tagView: CYLImageTagView = new CYLImageTagView();

  aboutToAppear(): void {
    const view = this.tagView;
    view.image = CYLSamplePicture.picture(0);
    view.imageAccessibilityLabel = CYLSamplePicture.label(0);
    view.tagGroups = CYLImageTagSampleData.tagGroups;
    view.imageTapHandler = () => view.toggleTagGroups(true);
    view.imageAccessibilityHint = '轻点两下显示或隐藏标签';
    view.circleTapHandler = () => cylToast('点击中心圆');
    view.tagTapHandler = (group: number, index: number, tag: CYLImageTag) => cylToast(cylFormat('点击标签：%@', tag.title));
    view.longPressHandler = () => cylToast('点击中心圆');
  }

  build() {
    Column() {
      CYLDemoBar({ title: '图片标签' })
      CYLImageTagViewComponent({ tagView: this.tagView }).width('100%').aspectRatio(1)
      Row({ space: 8 }) {
        CYLSampleButton({ title: '创建标签', identifier: 'sample.createTags', color: SYSTEM_PINK, action: () => {
          CYLDemoNav.push('CYLImageTagEditViewController', new CYLImageTagEditParam(() => {
            this.tagView.tagGroups = CYLImageTagSampleData.tagGroups;
          }));
        } }).layoutWeight(1)
        CYLSampleButton({ title: '标签列表', identifier: 'sample.tagList', color: SYSTEM_PINK,
          action: () => CYLDemoNav.push('CYLImageTagListViewController') }).layoutWeight(1)
      }
      .padding({ left: 16, right: 16, top: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}

/** TagEditActivity: 创建 asks for up to three tags (TagEditDialog), 保存 stores the groups and goes back. */
@Component
export struct CYLImageTagEditPage {
  param?: CYLImageTagEditParam;
  @State tagView: CYLImageTagView = new CYLImageTagView();
  @State showsCreate: boolean = false;
  @State names: string[] = ['', '', ''];
  @State deleteIndex: number = -1;

  /** TagEditDialog.createTagGroup: the non-empty names, the sample's directions, at the center. */
  static group(names: string[]): CYLImageTagGroup {
    const titles = names.filter((name: string) => name.length > 0);
    const directions = CYLImageTagGroup.defaultDirections(titles.length);
    const tags = titles.map((title: string, i: number) => new CYLImageTag(title, directions[i]));
    return new CYLImageTagGroup(tags, new CYLPoint(0.5, 0.5));
  }

  aboutToAppear(): void {
    const view = this.tagView;
    view.image = CYLSamplePicture.picture(0);
    view.imageAccessibilityLabel = CYLSamplePicture.label(0);
    view.isEditing = true;
    view.circleTapHandler = () => cylToast('点击中心圆');
    view.longPressHandler = (index: number) => this.confirmDelete(index);
    view.longPressAccessibilityActionName = '删除标签组';
  }

  createGroup(names: string[]): void {
    const group = CYLImageTagEditPage.group(names);
    if (group.tags.length > 0) {
      this.tagView.addTagGroup(group);
    }
  }

  confirmDelete(index: number): void {
    AlertDialog.show({
      title: '删除标签组',
      message: '你确定要删除该标签组吗？',
      primaryButton: { value: '取消', action: () => {
      } },
      secondaryButton: { value: '确定', fontColor: Color.Red, action: () => this.tagView.removeTagGroup(index) }
    });
  }

  save(): void {
    CYLImageTagSampleData.tagGroups = this.tagView.tagGroups;
    this.param?.onSave();
    CYLDemoNav.pop();
  }

  @Builder
  createDialog() {
    Column({ space: 12 }) {
      Text('创建标签').fontSize(17).fontWeight(FontWeight.Medium)
      ForEach([0, 1, 2], (i: number) => {
        TextInput({ placeholder: cylFormat('标签 %ld', i + 1), text: this.names[i] })
          .accessibilityText(cylFormat('标签 %ld', i + 1))
          .id(`sample.tagName${i + 1}`)
          .onChange((value: string) => {
            const copy = this.names.slice();
            copy[i] = value;
            this.names = copy;
          })
      }, (i: number) => `${i}`)
      Row() {
        Button('取消', { type: ButtonType.Normal }).backgroundColor(Color.Transparent).fontColor('#007AFF')
          .layoutWeight(1).onClick(() => this.showsCreate = false)
        Button('确定', { type: ButtonType.Normal }).backgroundColor(Color.Transparent).fontColor('#007AFF')
          .layoutWeight(1).id('sample.createOK').onClick(() => {
            this.showsCreate = false;
            this.createGroup(this.names);
          })
      }
    }
    .padding(16)
    .width(280)
    .backgroundColor(Color.White)
    .borderRadius(14)
  }

  build() {
    Stack() {
      Column() {
        CYLDemoBar({ title: '创建标签' })
        CYLImageTagViewComponent({ tagView: this.tagView }).width('100%').aspectRatio(1)
        Text('1. 点击创建按钮开始创建标签组\n2. 按住标签组滑动，调整位置\n3. 点击单个标签，调整该标签的方向\n4. 点击中心圆弹出提示\n5. 长按标签组删除')
          .fontSize(13)
          .fontColor(SECONDARY_LABEL)
          .width('100%')
          .padding({ left: 16, right: 16, top: 12 })
        Row({ space: 8 }) {
          CYLSampleButton({ title: '创建', identifier: 'sample.create', color: SYSTEM_PINK, action: () => {
            this.names = ['', '', ''];
            this.showsCreate = true;
          } }).layoutWeight(1)
          CYLSampleButton({ title: '保存', identifier: 'sample.save', color: SYSTEM_PINK,
            action: () => this.save() }).layoutWeight(1)
        }
        .padding({ left: 16, right: 16, top: 12 })
      }
      .width('100%')
      .height('100%')
      if (this.showsCreate) {
        Column() {
          this.createDialog()
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#66000000')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}

/** TagListActivity: 30 pictures, each with one group of the repository. */
@Component
export struct CYLImageTagListPage {
  private views: CYLImageTagView[] = [];

  aboutToAppear(): void {
    const groups = CYLImageTagSampleData.tagGroups;
    for (let row = 0; row < 30; row++) {
      const view = new CYLImageTagView();
      view.image = CYLSamplePicture.picture(row % 3, 400);
      view.imageAccessibilityLabel = CYLSamplePicture.label(row % 3);
      view.tagGroups = groups.length === 0 ? [] : [groups[row % groups.length].copy()];
      view.imageTapHandler = () => view.toggleTagGroups(true);
      view.imageAccessibilityHint = '轻点两下显示或隐藏标签';
      view.circleTapHandler = () => cylToast('点击中心圆');
      view.longPressHandler = () => cylToast('点击中心圆');
      view.tagTapHandler = (group: number, index: number, tag: CYLImageTag) =>
        cylToast(cylFormat('点击标签：%@', tag.title));
      this.views.push(view);
    }
  }

  build() {
    Column() {
      CYLDemoBar({ title: '标签列表' })
      List() {
        ForEach(this.views, (view: CYLImageTagView, row: number) => {
          ListItem() {
            CYLImageTagViewComponent({ tagView: view }).width('100%').aspectRatio(1)
          }.padding({ top: 4, bottom: 4 })
        }, (view: CYLImageTagView, row: number) => `${row}`)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
