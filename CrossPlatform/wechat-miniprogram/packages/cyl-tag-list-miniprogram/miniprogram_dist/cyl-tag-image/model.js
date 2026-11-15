/**
 * The model of `cyl-tag-image`: the core's CYLImageTagView and CYLImageTagGroupView (CollectionViewClassifyMenu/Class/
 * ImageTag, geometry after shellljx/TagViewGroup's TagGroupUtils): the directions, the groups, the space the tags use,
 * where each tag and line goes, how the dot moves inward, how groups keep from covering each other, the lines drawn
 * up to a progress, and the show / hide animations. It has no `wx` calls, so it runs under Node in the tests.
 *
 * Sizes are in points (px); a tag's size is measured by the component (CYLImageTagLabel: 13 pt text, 12 × 4 padding).
 */

/** CYLImageTagDirection, in declaration order (its raw values). */
const DIRECTIONS = ['leftCenter', 'leftTop', 'leftTopStraight', 'leftBottom', 'leftBottomStraight',
  'rightCenter', 'rightTop', 'rightTopStraight', 'rightBottom', 'rightBottomStraight', 'center'];

/** CYLImageTagGroupView's defaults. */
const DEFAULTS = {
  circleRadius: 8,
  circleInnerRadius: 4,
  verticalDistance: 28,
  tiltDistance: 20,
  lineWidth: 1,
  rippleMaxRadius: 20,
  rippleAlpha: 100 / 255,
  circleColor: 'rgba(0, 0, 0, 0.188)',
  circleInnerColor: '#FFFFFF',
  lineColor: '#FFFFFF',
};

/** 6: the most tags in one group. */
const MAXIMUM_TAG_COUNT = 6;

/** CYLImageTagView's space between groups it separates. */
const GROUP_SPACING = 4;

/** CYLImageTagLabel's insets {4, 12, 4, 12} and 13 pt font. */
const LABEL_INSETS = { top: 4, left: 12, bottom: 4, right: 12 };
const LABEL_FONT_SIZE = 13;

/** The next of the ten line directions (`center` is skipped), as the sample turns a tag on each tap while editing. */
function nextDirection(direction) {
  if (direction === 'rightBottomStraight' || direction === 'center') return 'leftCenter';
  const index = DIRECTIONS.indexOf(direction);
  return index >= 0 ? DIRECTIONS[index + 1] : 'leftCenter';
}

function isLeft(direction) {
  return DIRECTIONS.indexOf(direction) <= DIRECTIONS.indexOf('leftBottomStraight');
}

function isCenterLine(direction) {
  return direction === 'leftCenter' || direction === 'rightCenter';
}

/** CYLImageTag. */
function makeTag(title, direction, link) {
  const tag = { title: String(title), direction };
  if (link) tag.link = link;
  return tag;
}

function clamp01(value) {
  return Math.min(1, Math.max(0, value));
}

/** CYLImageTagGroup: tags at a point of the picture, as fractions of its size. */
function makeGroup(tags, percentPosition) {
  return { tags, percentPosition: { x: clamp01(percentPosition.x), y: clamp01(percentPosition.y) } };
}

/** An independent copy, with copies of the tags. */
function copyGroup(group) {
  return {
    tags: group.tags.map((tag) => ({ ...tag })),
    percentPosition: { x: group.percentPosition.x, y: group.percentPosition.y },
  };
}

/**
 * `CYLImageTagGroup.defaultDirections(forTagCount:)`: one tag right-center; two right-top and right-bottom; three
 * right-top, right-center and right-bottom; then left-top, left-center and left-bottom.
 */
function defaultDirections(count) {
  if (count < 1) return [];
  if (count === 1) return ['rightCenter'];
  if (count === 2) return ['rightTop', 'rightBottom'];
  return ['rightTop', 'rightCenter', 'rightBottom', 'leftTop', 'leftCenter', 'leftBottom']
    .slice(0, Math.min(count, MAXIMUM_TAG_COUNT));
}

/** The widest a tag may be: the width beside the dot (`itemSizes()`), at least 44. */
function labelMaximumWidth(width, params = DEFAULTS) {
  return Math.max(44, width - 2 * params.circleRadius - params.tiltDistance);
}

/**
 * `tagSpaceUsed(for:)`: the space the dot and the tags need on each side of the center, and the distances the layout
 * uses (grown by the tallest tag when it is taller than the vertical distance; the tilt by the same amount).
 * `items`: [{ direction, width, height }].
 */
function tagSpaceUsed(items, params = DEFAULTS) {
  const r = params.circleRadius;
  let left = r;
  let top = r;
  let right = r;
  let bottom = r;
  const tallest = items.reduce((max, item) => Math.max(max, item.height), 0);
  const v = Math.max(params.verticalDistance, tallest);
  const t = params.tiltDistance + (v - params.verticalDistance);
  for (const { direction, width, height } of items) {
    switch (direction) {
      case 'rightTopStraight': right = Math.max(right, t + width); top = Math.max(top, height + t); break;
      case 'rightTop': right = Math.max(right, width); top = Math.max(top, height + v); break;
      case 'rightCenter': right = Math.max(right, width); top = Math.max(top, Math.max(v, height)); break;
      case 'rightBottom': right = Math.max(right, width); bottom = Math.max(bottom, v); break;
      case 'rightBottomStraight': right = Math.max(right, t + width); bottom = Math.max(bottom, t); break;
      case 'leftTop': left = Math.max(left, width); top = Math.max(top, height + v); break;
      case 'leftTopStraight': left = Math.max(left, width + t); top = Math.max(top, height + t); break;
      case 'leftCenter': left = Math.max(left, width); top = Math.max(top, Math.max(v, height)); break;
      case 'leftBottom': left = Math.max(left, width); bottom = Math.max(bottom, v); break;
      case 'leftBottomStraight': left = Math.max(left, width + t); bottom = Math.max(bottom, t); break;
      default: left = Math.max(left, width / 2); bottom = Math.max(bottom, height / 2); break;
    }
  }
  return { insets: { top, left, bottom, right }, verticalDistance: v, tiltDistance: t };
}

/** `originForTag(of:direction:)`: the top-left corner of a tag of `size` in `direction`. */
function originForTag(size, direction, center, v, t) {
  const { x: cx, y: cy } = center;
  const { width: w, height: h } = size;
  switch (direction) {
    case 'rightTopStraight': return { x: cx + t, y: cy - t - h };
    case 'rightTop': return { x: cx, y: cy - v - h };
    case 'rightCenter': return { x: cx, y: cy - h };
    case 'rightBottom': return { x: cx, y: cy + v - h };
    case 'rightBottomStraight': return { x: cx + t, y: cy + t - h };
    case 'leftTop': return { x: cx - w, y: cy - v - h };
    case 'leftTopStraight': return { x: cx - w - t, y: cy - t - h };
    case 'leftCenter': return { x: cx - w, y: cy - h };
    case 'leftBottom': return { x: cx - w, y: cy + v - h };
    case 'leftBottomStraight': return { x: cx - w - t, y: cy + t - h };
    default: return { x: cx - w / 2, y: cy - h / 2 };
  }
}

/**
 * `layoutSubviews()` of a group in a view `width` × `height`: the dot from `percentPosition`, moved inward when tags
 * would leave the view (TagViewGroup's checkBounds), plus `displayOffset`; each tag's frame and its line (from the dot,
 * to the tag's bottom corner for the slanted and vertical lines, then along its bottom edge). `sizes[i]` is the size of
 * tag i. Returns { center, base (the dot before the offset: the ripple's place), frames, lines, occupied }.
 */
function layoutGroup(group, sizes, width, height, displayOffset = { x: 0, y: 0 }, params = DEFAULTS) {
  const tags = group.tags.slice(0, MAXIMUM_TAG_COUNT);
  const items = tags.map((tag, i) => ({ direction: tag.direction, width: sizes[i].width, height: sizes[i].height }));
  const used = tagSpaceUsed(items, params);
  let cx = width * group.percentPosition.x;
  let cy = height * group.percentPosition.y;
  const { insets } = used;
  if (insets.right > width - cx) cx -= insets.right - (width - cx);
  if (insets.left > cx) cx += insets.left - cx;
  if (insets.bottom > height - cy) cy -= insets.bottom - (height - cy);
  if (insets.top > cy) cy += insets.top - cy;
  const center = { x: cx + displayOffset.x, y: cy + displayOffset.y };
  const frames = [];
  const lines = [];
  items.forEach((item) => {
    const size = { width: item.width, height: item.height };
    const origin = originForTag(size, item.direction, center, used.verticalDistance, used.tiltDistance);
    const frame = { x: origin.x, y: origin.y, width: size.width, height: size.height };
    frames.push(frame);
    if (item.direction === 'center') {
      lines.push(null);
      return;
    }
    const left = isLeft(item.direction);
    const maxX = frame.x + frame.width;
    const maxY = frame.y + frame.height;
    const points = [{ x: center.x, y: center.y }];
    if (!isCenterLine(item.direction)) points.push({ x: left ? maxX : frame.x, y: maxY });
    points.push({ x: left ? frame.x : maxX, y: maxY });
    lines.push(points);
  });
  const r = params.circleRadius;
  let occupied = { x: center.x - r, y: center.y - r, width: 2 * r, height: 2 * r };
  for (const frame of frames) occupied = union(occupied, frame);
  return { center, base: { x: cx, y: cy }, frames, lines, occupied, used };
}

function union(a, b) {
  const x = Math.min(a.x, b.x);
  const y = Math.min(a.y, b.y);
  return { x, y, width: Math.max(a.x + a.width, b.x + b.width) - x, height: Math.max(a.y + a.height, b.y + b.height) - y };
}

function intersects(a, b) {
  return a.x < b.x + b.width && b.x < a.x + a.width && a.y < b.y + b.height && b.y < a.y + a.height;
}

/**
 * CYLImageTagView's `separateGroups()`: each group that overlaps an earlier one moves up or down by the smallest
 * distance that clears every earlier group and stays inside the view. Only the display moves; while editing (or for a
 * hidden group) groups stay where they are. `frames[i]` is group i's occupied frame without an offset. Returns the
 * vertical offset of each group.
 */
function separateGroups(frames, height, { editing = false, hidden = [] } = {}) {
  const placed = [];
  return frames.map((frame, index) => {
    if (editing || hidden[index]) {
      placed.push(frame);
      return 0;
    }
    const isClear = (dy) => {
      const moved = { ...frame, y: frame.y + dy };
      if (moved.y < 0 || moved.y + moved.height > height) return false;
      const grown = { ...moved, y: moved.y - GROUP_SPACING / 2, height: moved.height + GROUP_SPACING };
      return !placed.some((other) => intersects(grown, other));
    };
    if (isClear(0)) {
      placed.push(frame);
      return 0;
    }
    let best = Infinity;
    for (const other of placed) {
      for (const dy of [other.y + other.height + GROUP_SPACING - frame.y, other.y - GROUP_SPACING - (frame.y + frame.height)]) {
        if (Math.abs(dy) < Math.abs(best) && isClear(dy)) best = dy;
      }
    }
    const dy = best === Infinity ? 0 : best;
    placed.push({ ...frame, y: frame.y + dy });
    return dy;
  });
}

/**
 * A line drawn up to `progress` (0...1 of its length, as CAShapeLayer.strokeEnd), as straight pieces: each
 * { x, y, length, angle } (degrees), drawn from (x, y).
 */
function linePieces(points, progress) {
  if (!points || points.length < 2) return [];
  const segments = [];
  let total = 0;
  for (let i = 1; i < points.length; i += 1) {
    const dx = points[i].x - points[i - 1].x;
    const dy = points[i].y - points[i - 1].y;
    const length = Math.sqrt(dx * dx + dy * dy);
    segments.push({ x: points[i - 1].x, y: points[i - 1].y, length, angle: (Math.atan2(dy, dx) * 180) / Math.PI });
    total += length;
  }
  let remaining = total * clamp01(progress);
  const pieces = [];
  for (const segment of segments) {
    if (remaining <= 0) break;
    const length = Math.min(segment.length, remaining);
    pieces.push({ ...segment, length });
    remaining -= length;
  }
  return pieces;
}

/**
 * One animated value at time `t` (0...1) through `values`, decelerating as the sample's DecelerateInterpolator, and
 * piecewise linear between the values (`makeStep`).
 */
function animatedValue(values, t) {
  const time = clamp01(t);
  if (values.length === 0) return 0;
  if (time >= 1) return values[values.length - 1];
  const eased = 1 - (1 - time) * (1 - time);
  const position = eased * (values.length - 1);
  const index = Math.min(Math.floor(position), values.length - 1);
  const next = Math.min(index + 1, values.length - 1);
  return values[index] + (values[next] - values[index]) * (position - index);
}

/** The show animation (ms): the dot bounces 0.4 s, the lines grow 0.3 s, the tags fade in 0.2 s. */
const SHOW_DURATION = 900;
/** The hide animation (ms): the dot bounces 0.4 s, then the lines and the tags go together in 0.4 s. */
const HIDE_DURATION = 800;

/** The dot's bounce: both radii go 3 pt down, 3 pt up and back in 0.4 s; `elapsed` in ms. */
function bounce(elapsed, params = DEFAULTS) {
  const t = elapsed / 400;
  const r = params.circleRadius;
  const inner = params.circleInnerRadius;
  return {
    circleRadius: animatedValue([Math.max(0, r - 3), r + 3, r], t),
    circleInnerRadius: animatedValue([Math.max(0, inner - 3), inner + 3, inner], t),
  };
}

/** `show(animated:)` at `elapsed` ms: { circleRadius, circleInnerRadius, linesProgress, tagAlpha }. */
function showFrame(elapsed, params = DEFAULTS) {
  return {
    ...bounce(elapsed, params),
    linesProgress: elapsed < 400 ? 0 : animatedValue([0, 1], (elapsed - 400) / 300),
    tagAlpha: elapsed < 700 ? 0 : animatedValue([0, 1], (elapsed - 700) / 200),
  };
}

/** `hide(animated:)` at `elapsed` ms: the bounce, then the lines (decelerating) and the tags (ease out) go. */
function hideFrame(elapsed, params = DEFAULTS) {
  const t = Math.max(0, (elapsed - 400) / 400);
  return {
    ...bounce(elapsed, params),
    linesProgress: elapsed < 400 ? 1 : animatedValue([1, 0], t),
    tagAlpha: elapsed < 400 ? 1 : 1 - (1 - (1 - Math.min(1, t)) ** 2),
  };
}

module.exports = {
  DIRECTIONS,
  DEFAULTS,
  MAXIMUM_TAG_COUNT,
  GROUP_SPACING,
  LABEL_INSETS,
  LABEL_FONT_SIZE,
  nextDirection,
  isLeft,
  isCenterLine,
  makeTag,
  makeGroup,
  copyGroup,
  defaultDirections,
  labelMaximumWidth,
  tagSpaceUsed,
  originForTag,
  layoutGroup,
  separateGroups,
  linePieces,
  animatedValue,
  SHOW_DURATION,
  HIDE_DURATION,
  bounce,
  showFrame,
  hideFrame,
};
