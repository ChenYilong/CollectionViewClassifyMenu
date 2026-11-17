import { display } from '@kit.ArkUI';
import { CYLUIContext } from '../core/CYLUIContext';
/**
 * iOS `CYLFilterBaseController.swift` (and its XIB), migrated from Android `CYLMultipleFilter.kt`: the base of the
 * filter panels: a list that slides in from the leading edge over a blurred, dimmed host, leaving 50 vp of it visible,
 * with Reset and Apply buttons at the bottom; a tap on the dimmed area closes it. Subclasses fill the list
 * (`CYLMultipleFilterController`). `CYLFilterPanelView` renders it; the blurred capture is ArkUI's `backdropBlur`.
 */
import { CYLMenuLocalizedString } from '../core/CYLMenuResources';
import { CYLColor, CYLControlState, CYLEdgeInsets, CYLSize } from '../core/CYLTypes';
import { CYLCollectionViewLeftAlignedLayout } from './CYLCollectionViewLeftAlignedLayout';
import { CYLIndexPathButton, CYLIndexPathButtonView } from './CYLIndexPathButton';

/** Told when a filter panel closes. */
export interface CYLFilterControllerDelegate {
  /** The panel closed after Apply or Reset (not after a tap outside it). */
  filterControllerDidComplete(controller: CYLFilterBaseController): void;
}

/** The panel's list (iOS: the collection view). */
export class CYLFilterCollectionView {
  readonly collectionViewLayout: CYLCollectionViewLeftAlignedLayout = new CYLCollectionViewLeftAlignedLayout();
  contentInsetTop: number = 15;
  showsVerticalScrollIndicator: boolean = false;
  /** The panel's width: the host's width less the 50 vp left visible. */
  width: number = 0;
}

/** The dimmed area outside the panel. */
export class CYLFilterContentView {
  backgroundColor: string = CYLColor.BLACK;
  alpha: number = 0;
}

const BOTTOM_BUTTON_HEIGHT: number = 44;
const HOST_VISIBLE_WIDTH: number = 50;
const ANIMATION_DURATION: number = 300;
const DIMMED_ALPHA: number = 0.35;
const BLUR_RADIUS: number = 25;
/** The XIB's button title color and the lines' `UIColor.lightGray`. */
const BUTTON_TITLE_COLOR: string = CYLColor.white(1 / 3);
const LINE_COLOR: string = CYLColor.white(2 / 3);

/** Slides the panel in or out and calls the completion when done. */
export type CYLFilterPanelAnimator = (visible: boolean, completion: () => void) => void;

export class CYLFilterBaseController {
  /** The insets of the list's sections: the panel leaves 50 vp of the host view visible on the left. */
  static readonly sectionInset: CYLEdgeInsets = new CYLEdgeInsets(12, 50, 15, 5);

  /** The list. */
  readonly collectionView: CYLFilterCollectionView = new CYLFilterCollectionView();
  /** The dimmed area outside the panel; a tap on it closes the panel. */
  readonly contentView: CYLFilterContentView = new CYLFilterContentView();
  /** Reset. */
  readonly restoreButton: CYLIndexPathButton = new CYLIndexPathButton();
  /** Apply. */
  readonly okButton: CYLIndexPathButton = new CYLIndexPathButton();
  /** Told when the panel closes after Apply or Reset. */
  delegate: CYLFilterControllerDelegate | undefined = undefined;

  /** Whether the panel is on screen (added to the host). */
  isShowing: boolean = false;
  /** `settingArray`: free-form settings of the filter, kept for the caller (empty by default). */
  settingArray: Object[] = [];
  /** True while the side panel is slid in. */
  isPanelVisible: boolean = false;

  protected listeners: (() => void)[] = [];
  private animator: CYLFilterPanelAnimator | undefined = undefined;

  /** `init()`: a panel with localized Reset and Apply buttons. */
  constructor() {
    this.restoreButton.setTitle(CYLMenuLocalizedString('CYLFilterReset'), CYLControlState.NORMAL);
    this.okButton.setTitle(CYLMenuLocalizedString('CYLFilterConfirm'), CYLControlState.NORMAL);
    const buttons: CYLIndexPathButton[] = [this.restoreButton, this.okButton];
    for (const button of buttons) {
      button.setTitleColor(BUTTON_TITLE_COLOR, CYLControlState.NORMAL);
    }
  }

  /**
   * `show(in:)`: shows the panel over its host (the `CYLFilterPanelView` placed over it), blurs the host behind the
   * panel and slides the panel in.
   */
  show(): void {
    this.isShowing = true;
    this.isPanelVisible = false;
    this.contentView.alpha = 0;
    this.notify();
    this.animate(true, () => {
    });
  }

  /** Apply: slides the panel out, removes it and tells the delegate. */
  confirmButtonClicked(sender?: Object): void {
    this.close(() => this.delegate?.filterControllerDidComplete(this));
  }

  /** Reset: closes the panel like Apply; subclasses reset their selection first. */
  restoreButtonClicked(sender?: Object): void {
    this.confirmButtonClicked(undefined);
  }

  /** A tap on the dimmed area: closes the panel without telling the delegate. */
  hide(): void {
    this.close(() => {
    });
  }

  referenceSizeForHeaderInSection(section: number): CYLSize {
    return new CYLSize(this.collectionView.width, 38);
  }

  insetForSectionAt(section: number): CYLEdgeInsets {
    return CYLFilterBaseController.sectionInset;
  }

  // Rendering

  addListener(listener: () => void): () => void {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter((other: () => void) => other !== listener);
    };
  }

  /** Set by the view: runs the slide animation. */
  setAnimator(animator: CYLFilterPanelAnimator | undefined): void {
    this.animator = animator;
  }

  protected notify(): void {
    for (const listener of this.listeners) {
      listener();
    }
  }

  private animate(visible: boolean, completion: () => void): void {
    const finish = () => {
      this.isPanelVisible = visible;
      this.contentView.alpha = visible ? DIMMED_ALPHA : 0;
      completion();
    };
    if (this.animator !== undefined) {
      this.animator(visible, finish);
    } else {
      finish();
    }
  }

  private close(completion: () => void): void {
    if (!this.isShowing) {
      completion();
      return;
    }
    this.animate(false, () => {
      this.isShowing = false;
      this.notify();
      completion();
    });
  }
}

/**
 * Renders a filter panel over its host: place it in a `Stack` above the host's content and call `show()`. `content`
 * is the panel's list.
 */
@Component
export struct CYLFilterPanelView {
  controller: CYLFilterBaseController = new CYLFilterBaseController();
  @BuilderParam content: () => void = this.emptyContent;
  @State private showing: boolean = false;
  @State private panelOffset: number = 0;
  @State private dimAlpha: number = 0;
  @State private hostWidth: number = 0;
  private removeListener?: () => void;

  @Builder
  emptyContent() {
  }

  aboutToAppear(): void {
    CYLUIContext.remember(this.getUIContext());
    this.removeListener = this.controller.addListener(() => {
      this.showing = this.controller.isShowing;
    });
    this.showing = this.controller.isShowing;
    this.controller.setAnimator((visible: boolean, completion: () => void) => {
      if (visible) {
        this.panelOffset = -this.panelWidth();
        this.dimAlpha = 0;
      }
      this.getUIContext().animateTo({
        duration: ANIMATION_DURATION,
        onFinish: () => completion()
      }, () => {
        this.panelOffset = visible ? 0 : -this.panelWidth();
        this.dimAlpha = visible ? DIMMED_ALPHA : 0;
      });
    });
  }

  aboutToDisappear(): void {
    this.controller.setAnimator(undefined);
    if (this.removeListener !== undefined) {
      this.removeListener();
    }
  }

  private panelWidth(): number {
    // Before the host has been measured (the panel opened right away), the display's width, never a 0-wide panel.
    let width = this.hostWidth;
    if (width <= 0) {
      try {
        width = this.getUIContext().px2vp(display.getDefaultDisplaySync().width);
      } catch (error) {
        width = 0;
      }
    }
    return Math.max(0, width - HOST_VISIBLE_WIDTH);
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.showing) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(this.controller.contentView.backgroundColor)
          .opacity(this.dimAlpha)
          .accessibilityLevel('no')
          .onClick(() => this.controller.hide())
        Column() {
          Scroll() {
            Column() {
              this.content()
            }
            .width('100%')
            // [EN] Space below the last row too, so it is never cut by the Reset / OK bar. [CN] 最后一行下方同样留白，不被重置 / 确定栏截断。
            .padding({ top: this.controller.collectionView.contentInsetTop, bottom: 16 })
          }
          .layoutWeight(1)
          .width('100%')
          // Clipped to its area: the rows drew past it, so the last one sat half under the Reset / OK bar.
          .clip(true)
          .align(Alignment.Top)
          .scrollBar(this.controller.collectionView.showsVerticalScrollIndicator ? BarState.Auto : BarState.Off)
          Row() {
            Column() {
              CYLIndexPathButtonView({
                button: this.controller.restoreButton,
                onTap: () => this.controller.restoreButtonClicked(this.controller.restoreButton)
              })
            }
            .layoutWeight(1)
            .height(BOTTOM_BUTTON_HEIGHT)
            .border({ width: { top: 0.5 }, color: LINE_COLOR })
            Column() {
              CYLIndexPathButtonView({
                button: this.controller.okButton,
                onTap: () => this.controller.confirmButtonClicked(this.controller.okButton)
              })
            }
            .layoutWeight(1)
            .height(BOTTOM_BUTTON_HEIGHT)
            .border({ width: { top: 0.5, left: 0.5 }, color: LINE_COLOR })
          }
          .width('100%')
          .height(BOTTOM_BUTTON_HEIGHT)
          .zIndex(1)
        }
        .width(this.panelWidth())
        .height('100%')
        .backdropBlur(BLUR_RADIUS)
        // A light frosted panel, as iOS's blurred capture: without a tint of its own the panel showed the dimming layer
        // through its blur, so its tags and title looked greyed out under a mask.
        .backgroundColor('#E6FFFFFF')
        .offset({ x: this.panelOffset })
      }
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(this.showing ? HitTestMode.Default : HitTestMode.Transparent)
    .onAreaChange((oldArea: Area, newArea: Area) => {
      this.hostWidth = Number(newArea.width);
      this.controller.collectionView.width = this.panelWidth();
    })
  }
}
