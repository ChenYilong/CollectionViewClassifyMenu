/**
 * The fold control of a `CYLTagListView` ("更多 ⌄"), as iOS `CYLMenuFoldControl.swift`: where it is (below the
 * section, in the section header, or as the last tag) and what it shows (icon and title, title only, icon only, or
 * title and icon always). Expanded, a control with an icon keeps only the icon, turned 180°; a title-only control shows
 * its collapse title; a title-and-icon-always control shows its collapse title and the turned icon.
 */
import { CYLMenuLocalizedString, CYLMenuResources } from './CYLMenuResources';
import { CYLFont, CYLImage } from './CYLTypes';

/**
 * The most the system font scale grows a fold / More control (its text and its size). At accessibility font sizes the
 * control would otherwise dwarf the header; tags and titles keep scaling normally.
 */
export const CYLFoldControlMaxFontScale: number = 1.3;

/** The widest a fold control in a section header gets, as a fraction of the header's width (the title truncates). */
export const CYLHeaderFoldMaxWidthFraction: number = 0.4;

/** Where the fold control of a foldable section is. */
export enum CYLMenuFoldControlPosition {
  /** No fold control: every row is shown. */
  none = 0,
  /** Centered below the section's tags. */
  footer = 1,
  /** At the trailing edge of the section header. */
  headerTrailing = 2,
  /** At the leading edge of the section header. */
  headerLeading = 3,
  /** The last item of the tags. */
  tail = 4
}

/** What the fold control shows while the section is collapsed. */
export enum CYLMenuFoldControlContent {
  /** "更多 ⌄"; expanded, only the icon, turned. */
  iconAndTitle = 0,
  /** "更多"; expanded, the collapse title ("收起"). */
  title = 1,
  /** "⌄"; expanded, the same icon, turned. */
  icon = 2,
  /**
   * "更多 ⌄" collapsed and "收起 ⌃" expanded ("More ⌄" / "Less ⌃"): the title and the icon in both states, the icon
   * turned 180° when expanded. In a configuration: "titleAndIconAlways" ("titleAndIcon" is an older alias of
   * `iconAndTitle`).
   */
  titleAndIcon = 3
}

export class CYLMenuFoldControl {
  position: CYLMenuFoldControlPosition;
  content: CYLMenuFoldControlContent;
  /** Title and icon color; undefined uses `CYLMenuStyle.foldControlColor`. */
  color?: string;
  /** Undefined: the footnote size (13 fp). */
  font?: CYLFont;
  /** The icon turns 180° when expanded. */
  rotatesImageWhenExpanded: boolean = true;
  private customTitle?: string;
  private customCollapseTitle?: string;
  private customImage?: CYLImage;

  constructor(position: CYLMenuFoldControlPosition = CYLMenuFoldControlPosition.none,
    content: CYLMenuFoldControlContent = CYLMenuFoldControlContent.icon) {
    this.position = position;
    this.content = content;
  }

  /** Shown while collapsed; default the localized "更多" (`CYLMenuExpand`). */
  get title(): string {
    return this.customTitle ?? CYLMenuLocalizedString('CYLMenuExpand');
  }

  set title(value: string) {
    this.customTitle = value;
  }

  /** Shown while expanded by a control that keeps its title; default the localized "收起" (`CYLMenuCollapse`). */
  get collapseTitle(): string {
    return this.customCollapseTitle ?? CYLMenuLocalizedString('CYLMenuCollapse');
  }

  set collapseTitle(value: string) {
    this.customCollapseTitle = value;
  }

  /** The icon, pointing down while collapsed; default the core's chevron (`cyl_fold_chevron`). */
  get image(): CYLImage {
    return this.customImage ?? (CYLMenuResources.image('cyl_fold_chevron') as Resource);
  }

  set image(value: CYLImage) {
    this.customImage = value;
  }

  /** True while `image` is the default chevron. */
  get usesDefaultImage(): boolean {
    return this.customImage === undefined;
  }

  showsImage(expanded: boolean): boolean {
    return this.content !== CYLMenuFoldControlContent.title;
  }

  showsTitle(expanded: boolean): boolean {
    switch (this.content) {
      case CYLMenuFoldControlContent.iconAndTitle:
        return !expanded;
      case CYLMenuFoldControlContent.title:
      case CYLMenuFoldControlContent.titleAndIcon:
        return true;
      default:
        return false;
    }
  }

  /** The title shown in that state, or undefined. */
  titleWhenExpanded(expanded: boolean): string | undefined {
    if (!this.showsTitle(expanded)) {
      return undefined;
    }
    return expanded ? this.collapseTitle : this.title;
  }

  /** NSCopying (the image and colors are shared). */
  copy(): CYLMenuFoldControl {
    const c = new CYLMenuFoldControl(this.position, this.content);
    c.customTitle = this.customTitle;
    c.customCollapseTitle = this.customCollapseTitle;
    c.customImage = this.customImage;
    c.color = this.color;
    c.font = this.font;
    c.rotatesImageWhenExpanded = this.rotatesImageWhenExpanded;
    return c;
  }
}
