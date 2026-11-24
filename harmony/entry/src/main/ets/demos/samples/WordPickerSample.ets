/**
 * 选词填入, 1:1 with the iOS example's `CYLWordPickerDemoViewController`: a remark field, the sender's message and a
 * "选词填入" link that opens a sheet where the message is one cell per character (`CYLMenuStyle.wordPicker()`, smear
 * selection); "填入" (off until something is selected) puts the selected characters, in text order, into the field.
 * The message is localized (a greeting with a name to pick, an emoji and a space).
 */
import { CYLExampleLocalizedString } from '../../data/CYLExampleLocalization';
import { CYLIndexPath, CYLMenuDelegate, CYLMenuSelectionMode, CYLMenuStyle, CYLTagBackgroundStyle, CYLTagListState, CYLTagListView } from '@cyl/classifymenu';
import { CYLDemoBar } from '../DemoNav';

/** The sender, and the name the message lets you pick (the same in every language). */
const SENDER: string = 'Alex';
const MESSAGE_KEY: string = '你好，我是设计部的 Alex 👋';

/** The word picker sheet's list: its selection turns "填入" on. */
class CYLWordPickerDelegate implements CYLMenuDelegate {
  onChange: () => void = () => {
  };
  menuDidChangeSelectedItems = (menu: Object, indexPaths: CYLIndexPath[]): void => this.onChange();
  menuDidSelectItem = (menu: Object, indexPath: CYLIndexPath): void => this.onChange();
  menuDidDeselectItem = (menu: Object, indexPath: CYLIndexPath): void => this.onChange();
}

@Component
export struct CYLWordPickerSamplePage {
  @State remark: string = '';
  @State sheetShown: boolean = false;
  @State canFill: boolean = false;
  private message: string = CYLExampleLocalizedString(MESSAGE_KEY);
  private list: CYLTagListState = new CYLTagListState();
  private delegate: CYLWordPickerDelegate = new CYLWordPickerDelegate();

  aboutToAppear(): void {
    this.list.style = CYLMenuStyle.wordPicker();
    this.list.style.backgroundStyle = CYLTagBackgroundStyle.liquidGlass;
    this.list.selectionMode = CYLMenuSelectionMode.multiple;
    this.list.allowsSmearSelection = true;
    this.delegate.onChange = () => {
      this.canFill = this.list.selectedIndexPaths.length > 0;
    };
    this.list.menuDelegate = this.delegate;
  }

  /** Opens the sheet with the message as cells. */
  private showPicker(): void {
    this.list.setTagsWithCharactersOfText(this.message);
    this.canFill = false;
    this.sheetShown = true;
  }

  /** Puts the picked characters, in text order, into the field and closes the sheet. */
  private fill(): void {
    const picked = this.list.selectedText;
    if (picked.length === 0) {
      return;
    }
    this.remark = picked;
    this.sheetShown = false;
  }

  @Builder
  sheet() {
    Column({ space: 20 }) {
      Row() {
        Text(CYLExampleLocalizedString('取消'))
          .fontSize(20)
          .id('wordPicker.cancel')
          .onClick(() => {
            this.sheetShown = false;
          })
        Blank()
        Button(CYLExampleLocalizedString('填入'))
          .id('wordPicker.fill')
          .backgroundColor('#34C759')
          .borderRadius(8)
          .width(88)
          .height(40)
          .enabled(this.canFill)
          .opacity(this.canFill ? 1 : 0.4)
          .onClick(() => this.fill())
      }
      .width('100%')

      Text(CYLExampleLocalizedString('涂抹选择填入词'))
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .width('100%')
      CYLTagListView({ tagList: this.list })
        .width('100%')
        .height(200)
        .id('wordPicker.list')
    }
    .padding({ left: 16, right: 16, top: 16, bottom: 32 })
  }

  build() {
    Column() {
      CYLDemoBar({ title: CYLExampleLocalizedString('选词填入') })
      Column({ space: 10 }) {
        Text(CYLExampleLocalizedString('备注'))
          .fontSize(15)
          .fontColor('#6C6C70')
        TextInput({ text: this.remark, placeholder: CYLExampleLocalizedString('添加备注') })
          .id('wordPicker.field')
          .accessibilityText(CYLExampleLocalizedString('添加备注'))
          .height(52)
          .fontSize(20)
          .borderRadius(10)
          .backgroundColor('#F2F2F7')
          .onChange((value: string) => {
            this.remark = value;
          })
        Text(SENDER)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5856D6')
          .margin({ top: 6 })
        Text(`"${this.message}"`)
          .fontSize(17)
          .fontColor('#6C6C70')
        Text(CYLExampleLocalizedString('选词填入'))
          .id('wordPicker.pick')
          .fontSize(17)
          .fontColor('#007AFF')
          .padding({ top: 10, bottom: 10 })
          .onClick(() => this.showPicker())
      }
      .alignItems(HorizontalAlign.Start)
      .padding(20)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .bindSheet($$this.sheetShown, this.sheet(), { height: SheetSize.FIT_CONTENT, showClose: false, dragBar: false })
  }
}
