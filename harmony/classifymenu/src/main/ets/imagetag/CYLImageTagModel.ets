/**
 * The models and the geometry of the image tags (iOS CYLImageTagGroupView.swift; Android CYLImageTagGroupView.kt).
 * Geometry after shellljx/TagViewGroup (TagGroupUtils, Apache License 2.0). Lengths are vp.
 */
import { MeasureText } from '@kit.ArkUI';
import { CYLEdgeInsets, CYLPoint, CYLRect, CYLSize } from '../core/CYLTypes';

/**
 * Where a tag goes from the dot (TagViewGroup's DIRECTION). "Straight" tags hang on a slanted line; the others on a
 * vertical line and then along their bottom edge.
 */
export enum CYLImageTagDirection {
  leftCenter = 0,
  leftTop = 1,
  leftTopStraight = 2,
  leftBottom = 3,
  leftBottomStraight = 4,
  rightCenter = 5,
  rightTop = 6,
  rightTopStraight = 7,
  rightBottom = 8,
  rightBottomStraight = 9,
  /** Centered on the dot, without a line (the ripple). */
  center = 10
}

/** The computed members of `CYLImageTagDirection` (an ArkTS enum has no members). */
export class CYLImageTagDirections {
  /**
   * `next`: the next of the ten line directions, in declaration order (`center` is skipped), as the sample turns a
   * tag on each tap while editing.
   */
  static next(direction: CYLImageTagDirection): CYLImageTagDirection {
    if (direction === CYLImageTagDirection.rightBottomStraight || direction === CYLImageTagDirection.center) {
      return CYLImageTagDirection.leftCenter;
    }
    return (direction as number) + 1 as CYLImageTagDirection;
  }

  static isLeft(direction: CYLImageTagDirection): boolean {
    return direction <= CYLImageTagDirection.leftBottomStraight;
  }

  static isCenterLine(direction: CYLImageTagDirection): boolean {
    return direction === CYLImageTagDirection.leftCenter || direction === CYLImageTagDirection.rightCenter;
  }
}

/** The defaults of `CYLImageTagGroupView` (its static members on iOS). */
export class CYLImageTagDefaults {
  /** 8: the dot's outer radius. */
  static readonly defaultCircleRadius: number = 8;
  /** 4: the dot's inner radius. */
  static readonly defaultCircleInnerRadius: number = 4;
  /** 28: the vertical distance of the lines. */
  static readonly defaultVerticalDistance: number = 28;
  /** 20: the tilt distance of the slanted lines. */
  static readonly defaultTiltDistance: number = 20;
  /** 1: the line width. */
  static readonly defaultLineWidth: number = 1;
  /** 6: the most tags in one group. */
  static readonly maximumTagCount: number = 6;
  /** 20: the ripple's largest radius. */
  static readonly defaultRippleMaxRadius: number = 20;
}

/** One tag: a title, its direction and anything the host keeps with it (the sample's TagGroupModel.Tag). */
export class CYLImageTag {
  /** The text of the tag. */
  title: string;
  /** Where the tag goes from the dot. */
  direction: CYLImageTagDirection;
  /** A link of the tag (the sample's Tag.link), not opened by the view. */
  link?: string;
  /** Anything the host keeps with the tag. */
  userInfo?: Object;

  /** `init(title:direction:link:userInfo:)`. */
  constructor(title: string, direction: CYLImageTagDirection, link?: string, userInfo?: Object) {
    this.title = title;
    this.direction = direction;
    this.link = link;
    this.userInfo = userInfo;
  }

  /** An independent copy (the user info is shared). */
  copy(): CYLImageTag {
    return new CYLImageTag(this.title, this.direction, this.link, this.userInfo);
  }
}

/** A group of tags at a point of the picture, as fractions of its size (the sample's TagGroupModel). */
export class CYLImageTagGroup {
  /** The tags, at most `CYLImageTagDefaults.maximumTagCount` of them are shown. */
  tags: CYLImageTag[];
  /** The dot's place, as fractions of the picture's width and height. */
  percentPosition: CYLPoint;

  /** `init(tags:percentPosition:)`. */
  constructor(tags: CYLImageTag[], percentPosition: CYLPoint) {
    this.tags = tags;
    this.percentPosition = percentPosition;
  }

  /**
   * Directions for `count` new tags, as the sample's edit dialog sets them: one tag right-center; two right-top and
   * right-bottom; three right-top, right-center and right-bottom; then left-top, left-center and left-bottom.
   */
  static defaultDirections(count: number): CYLImageTagDirection[] {
    if (count < 1) {
      return [];
    }
    if (count === 1) {
      return [CYLImageTagDirection.rightCenter];
    }
    if (count === 2) {
      return [CYLImageTagDirection.rightTop, CYLImageTagDirection.rightBottom];
    }
    const all: CYLImageTagDirection[] = [CYLImageTagDirection.rightTop, CYLImageTagDirection.rightCenter,
      CYLImageTagDirection.rightBottom, CYLImageTagDirection.leftTop, CYLImageTagDirection.leftCenter,
      CYLImageTagDirection.leftBottom];
    return all.slice(0, Math.min(count, CYLImageTagDefaults.maximumTagCount));
  }

  /** An independent copy, with copies of the tags. */
  copy(): CYLImageTagGroup {
    return new CYLImageTagGroup(this.tags.map((tag: CYLImageTag) => tag.copy()), this.percentPosition);
  }
}

/**
 * A tag of a group (TagViewGroup's ITagView). The group sizes it with `sizeThatFits` and places it; the group view
 * draws it with `contentBuilder`, or as a CYLImageTagLabel when there is none.
 */
export interface CYLImageTagItem {
  /** Where the tag goes from the dot. */
  tagDirection: CYLImageTagDirection;
  /** The screen reader's label of the tag. */
  accessibilityLabel?: string;
  /** The screen reader's hint of the tag (set by the group). */
  accessibilityHint?: string;
  /** The size the tag needs within `width`. */
  sizeThatFits(width: number): CYLSize;
  /** Draws a custom tag (a data source's view); undefined draws a label. */
  contentBuilder?: WrappedBuilder<[CYLImageTagItem]>;
}

/** The default tag (TagViewGroup's TagTextView): white 13 vp text with a black glow, 12 × 4 vp padding. */
export class CYLImageTagLabel implements CYLImageTagItem {
  /** Where the tag goes from the dot; `rightCenter` by default. */
  tagDirection: CYLImageTagDirection = CYLImageTagDirection.rightCenter;
  /** Space around the text. {4, 12, 4, 12} by default. */
  contentInsets: CYLEdgeInsets = new CYLEdgeInsets(4, 12, 4, 12);
  text: string = '';
  textColor: string = '#FFFFFFFF';
  fontSize: number = 13;
  fontWeight: FontWeight = FontWeight.Normal;
  shadowColor: string = '#FF000000';
  shadowRadius: number = 3.5;
  accessibilityLabel?: string;
  accessibilityHint?: string;
  contentBuilder?: WrappedBuilder<[CYLImageTagItem]>;

  /** One line when it fits; wrapped to `width` otherwise (long titles, large font sizes). */
  sizeThatFits(width: number): CYLSize {
    const horizontal = this.contentInsets.left + this.contentInsets.right;
    const maximum = width > horizontal ? width - horizontal : 100000;
    let textWidth = 0;
    let textHeight = 0;
    try {
      const size: SizeOptions = MeasureText.measureTextSize({
        textContent: this.text,
        fontSize: this.fontSize,
        fontWeight: this.fontWeight,
        constraintWidth: maximum
      });
      textWidth = px2vp(Number(size.width ?? 0));
      textHeight = px2vp(Number(size.height ?? 0));
    } catch (error) {
      textWidth = this.text.length * this.fontSize;
      textHeight = this.fontSize * 1.2;
    }
    return new CYLSize(Math.ceil(Math.min(textWidth, maximum) + horizontal),
      Math.ceil(textHeight + this.contentInsets.top + this.contentInsets.bottom));
  }
}

/** One tag placed by a layout: its frame, and the line from the dot (none for `center`). */
export class CYLImageTagPlacement {
  readonly frame: CYLRect;
  readonly line: CYLPoint[];

  constructor(frame: CYLRect, line: CYLPoint[]) {
    this.frame = frame;
    this.line = line;
  }
}

/** The result of `CYLImageTagGeometry.layout`. */
export class CYLImageTagLayoutResult {
  /** The dot's center, with the display offset. */
  readonly centerPoint: CYLPoint;
  /** The ripple's center (without the display offset, as iOS). */
  readonly rippleCenter: CYLPoint;
  readonly placements: CYLImageTagPlacement[];

  constructor(centerPoint: CYLPoint, rippleCenter: CYLPoint, placements: CYLImageTagPlacement[]) {
    this.centerPoint = centerPoint;
    this.rippleCenter = rippleCenter;
    this.placements = placements;
  }
}

/** The inputs of the geometry: the group's lengths. */
export class CYLImageTagMetrics {
  circleRadius: number = CYLImageTagDefaults.defaultCircleRadius;
  verticalDistance: number = CYLImageTagDefaults.defaultVerticalDistance;
  tiltDistance: number = CYLImageTagDefaults.defaultTiltDistance;
  /** The distances of the last layout: at least the tallest tag, so neighboring tags never overlap. */
  layoutVerticalDistance: number = 0;
  layoutTiltDistance: number = 0;
}

/** TagGroupUtils: the geometry of a group, free of rendering. */
export class CYLImageTagGeometry {
  /** The space the dot and the tags need on each side of the center (getTagViewUsed). */
  static tagSpaceUsed(metrics: CYLImageTagMetrics, directions: CYLImageTagDirection[], sizes: CYLSize[]): CYLEdgeInsets {
    const r = metrics.circleRadius;
    let left = r;
    let top = r;
    let right = r;
    let bottom = r;
    let tallest = 0;
    for (const size of sizes) {
      tallest = Math.max(tallest, size.height);
    }
    // Grown only when a tag is taller than the vertical distance (large text); the tilt grows by the same amount.
    const v = Math.max(metrics.verticalDistance, tallest);
    const t = metrics.tiltDistance + (v - metrics.verticalDistance);
    metrics.layoutVerticalDistance = v;
    metrics.layoutTiltDistance = t;
    const count = Math.min(directions.length, sizes.length);
    for (let i = 0; i < count; i++) {
      const w = sizes[i].width;
      const h = sizes[i].height;
      switch (directions[i]) {
        case CYLImageTagDirection.rightTopStraight:
          right = Math.max(right, t + w);
          top = Math.max(top, h + t);
          break;
        case CYLImageTagDirection.rightTop:
          right = Math.max(right, w);
          top = Math.max(top, h + v);
          break;
        case CYLImageTagDirection.rightCenter:
          right = Math.max(right, w);
          top = Math.max(top, Math.max(v, h));
          break;
        case CYLImageTagDirection.rightBottom:
          right = Math.max(right, w);
          bottom = Math.max(bottom, v);
          break;
        case CYLImageTagDirection.rightBottomStraight:
          right = Math.max(right, t + w);
          bottom = Math.max(bottom, t);
          break;
        case CYLImageTagDirection.leftTop:
          left = Math.max(left, w);
          top = Math.max(top, h + v);
          break;
        case CYLImageTagDirection.leftTopStraight:
          left = Math.max(left, w + t);
          top = Math.max(top, h + t);
          break;
        case CYLImageTagDirection.leftCenter:
          left = Math.max(left, w);
          top = Math.max(top, Math.max(v, h));
          break;
        case CYLImageTagDirection.leftBottom:
          left = Math.max(left, w);
          bottom = Math.max(bottom, v);
          break;
        case CYLImageTagDirection.leftBottomStraight:
          left = Math.max(left, w + t);
          bottom = Math.max(bottom, t);
          break;
        default:
          left = Math.max(left, w / 2);
          bottom = Math.max(bottom, h / 2);
          break;
      }
    }
    return new CYLEdgeInsets(top, left, bottom, right);
  }

  /** The top-left corner of a tag of `size` in `direction` around `center` (getStartPoint). */
  static originForTag(metrics: CYLImageTagMetrics, center: CYLPoint, size: CYLSize,
    direction: CYLImageTagDirection): CYLPoint {
    const cx = center.x;
    const cy = center.y;
    const v = Math.max(metrics.verticalDistance, metrics.layoutVerticalDistance);
    const t = Math.max(metrics.tiltDistance, metrics.layoutTiltDistance);
    const w = size.width;
    const h = size.height;
    switch (direction) {
      case CYLImageTagDirection.rightTopStraight:
        return new CYLPoint(cx + t, cy - t - h);
      case CYLImageTagDirection.rightTop:
        return new CYLPoint(cx, cy - v - h);
      case CYLImageTagDirection.rightCenter:
        return new CYLPoint(cx, cy - h);
      case CYLImageTagDirection.rightBottom:
        return new CYLPoint(cx, cy + v - h);
      case CYLImageTagDirection.rightBottomStraight:
        return new CYLPoint(cx + t, cy + t - h);
      case CYLImageTagDirection.leftTop:
        return new CYLPoint(cx - w, cy - v - h);
      case CYLImageTagDirection.leftTopStraight:
        return new CYLPoint(cx - w - t, cy - t - h);
      case CYLImageTagDirection.leftCenter:
        return new CYLPoint(cx - w, cy - h);
      case CYLImageTagDirection.leftBottom:
        return new CYLPoint(cx - w, cy + v - h);
      case CYLImageTagDirection.leftBottomStraight:
        return new CYLPoint(cx - w - t, cy + t - h);
      default:
        return new CYLPoint(cx - w / 2, cy - h / 2);
    }
  }

  /** The width a tag may take: never more than the width beside the dot. */
  static tagWidthLimit(metrics: CYLImageTagMetrics, boundsWidth: number): number {
    return Math.max(44, boundsWidth - 2 * metrics.circleRadius - metrics.tiltDistance);
  }

  /** layoutSubviews: the dot moved inward when tags would leave the view (checkBounds), the tags and the lines. */
  static layout(metrics: CYLImageTagMetrics, width: number, height: number, percent: CYLPoint, offset: CYLPoint,
    directions: CYLImageTagDirection[], sizes: CYLSize[]): CYLImageTagLayoutResult {
    const used = CYLImageTagGeometry.tagSpaceUsed(metrics, directions, sizes);
    let cx = width * percent.x;
    let cy = height * percent.y;
    if (used.right > width - cx) {
      cx -= used.right - (width - cx);
    }
    if (used.left > cx) {
      cx += used.left - cx;
    }
    if (used.bottom > height - cy) {
      cy -= used.bottom - (height - cy);
    }
    if (used.top > cy) {
      cy += used.top - cy;
    }
    const center = new CYLPoint(cx + offset.x, cy + offset.y);
    const placements: CYLImageTagPlacement[] = [];
    const count = Math.min(directions.length, sizes.length);
    for (let i = 0; i < count; i++) {
      const direction = directions[i];
      const origin = CYLImageTagGeometry.originForTag(metrics, center, sizes[i], direction);
      const frame = new CYLRect(origin.x, origin.y, sizes[i].width, sizes[i].height);
      const line: CYLPoint[] = [];
      if (direction !== CYLImageTagDirection.center) {
        const left = CYLImageTagDirections.isLeft(direction);
        line.push(center);
        if (!CYLImageTagDirections.isCenterLine(direction)) {
          line.push(new CYLPoint(left ? frame.maxX : frame.x, frame.maxY));
        }
        line.push(new CYLPoint(left ? frame.x : frame.maxX, frame.maxY));
      }
      placements.push(new CYLImageTagPlacement(frame, line));
    }
    return new CYLImageTagLayoutResult(center, new CYLPoint(cx, cy), placements);
  }

  /** The part of a polyline drawn at `progress` 0...1 of its length (a shape layer's strokeEnd). */
  static partialLine(points: CYLPoint[], progress: number): CYLPoint[] {
    if (points.length < 2 || progress >= 1) {
      return points;
    }
    let total = 0;
    for (let i = 1; i < points.length; i++) {
      total += Math.hypot(points[i].x - points[i - 1].x, points[i].y - points[i - 1].y);
    }
    let remaining = Math.max(0, progress) * total;
    const result: CYLPoint[] = [points[0]];
    for (let i = 1; i < points.length; i++) {
      const a = points[i - 1];
      const b = points[i];
      const length = Math.hypot(b.x - a.x, b.y - a.y);
      if (length <= remaining) {
        result.push(b);
        remaining -= length;
      } else {
        const f = length > 0 ? remaining / length : 0;
        result.push(new CYLPoint(a.x + (b.x - a.x) * f, a.y + (b.y - a.y) * f));
        break;
      }
    }
    return result;
  }

  /** The union of the dot and the tag frames (occupiedFrame). */
  static occupiedFrame(center: CYLPoint, radius: number, frames: CYLRect[]): CYLRect {
    let minX = center.x - radius;
    let minY = center.y - radius;
    let maxX = center.x + radius;
    let maxY = center.y + radius;
    for (const f of frames) {
      minX = Math.min(minX, f.x);
      minY = Math.min(minY, f.y);
      maxX = Math.max(maxX, f.maxX);
      maxY = Math.max(maxY, f.maxY);
    }
    return new CYLRect(minX, minY, maxX - minX, maxY - minY);
  }

  /**
   * CYLImageTagView's separateGroups for one group: the smallest vertical move of `frame` that clears every earlier
   * group (`placed`) and stays inside `height`; 0 when it is clear already or nothing works.
   */
  static separationOffset(frame: CYLRect, placed: CYLRect[], height: number, spacing: number): number {
    const isClear = (dy: number): boolean => {
      const minY = frame.y + dy;
      const maxY = frame.maxY + dy;
      if (minY < 0 || maxY > height) {
        return false;
      }
      const moved = new CYLRect(frame.x, minY - spacing / 2, frame.width, frame.height + spacing);
      return !placed.some((other: CYLRect) => moved.intersects(other));
    };
    if (isClear(0)) {
      return 0;
    }
    let best = Number.MAX_VALUE;
    for (const other of placed) {
      const candidates: number[] = [other.maxY + spacing - frame.y, other.y - spacing - frame.maxY];
      for (const dy of candidates) {
        if (Math.abs(dy) < Math.abs(best) && isClear(dy)) {
          best = dy;
        }
      }
    }
    return best === Number.MAX_VALUE ? 0 : best;
  }

  /** The list of titles in the language (ListFormatter). */
  static joinTitles(titles: string[], language: string): string {
    if (titles.length === 0) {
      return '';
    }
    if (titles.length === 1) {
      return titles[0];
    }
    if (language.toLowerCase().startsWith('zh')) {
      const conjunction = '和';
      return titles.slice(0, titles.length - 1).join('、') + conjunction + titles[titles.length - 1];
    }
    if (titles.length === 2) {
      return titles[0] + ' and ' + titles[1];
    }
    return titles.slice(0, titles.length - 1).join(', ') + ', and ' + titles[titles.length - 1];
  }
}
