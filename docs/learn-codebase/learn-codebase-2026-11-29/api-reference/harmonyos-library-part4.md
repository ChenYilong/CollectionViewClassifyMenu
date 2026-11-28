# harmonyos: library (part 4 of 4)

## harmony/classifymenu/src/main/ets/imagetag/CYLImageTagGroupView.ets

A group of tags around a dot on a picture (iOS CYLImageTagGroupView; TagViewGroup's TagViewGroup): the dot, a line
to each tag, the tags, an optional ripple, show / hide animations, taps, a long press and dragging.
`CYLImageTagGroupView` holds the state and the API (as the iOS class); `CYLImageTagGroupViewComponent` draws it.

- `export class CYLImageTagRippleView` (L16)
  A pulsing circle (TagViewGroup's RippleView): it grows to `maximumRadius` and fades out, once a second.

- `tagDirection: CYLImageTagDirection = CYLImageTagDirection.center;` (L18)
  Always `center`: the ripple sits on the dot.

- `maximumRadius: number = CYLImageTagDefaults.defaultRippleMaxRadius;` (L20)
  The largest radius of the circle.

- `startAlpha: number = 100 / 255;` (L22)
  The opacity at the start, 0...1. 100/255 by default.

- `color: string = CYLColor.WHITE;` (L24)
  The circle's color, white by default.

- `isAnimating: boolean = true;` (L26)
  Whether it pulses.

- `startAnimating(): void` (L33)
  Starts pulsing.

- `stopAnimating(): void` (L38)
  Stops pulsing.

- `export interface CYLImageTagGroupViewDataSource` (L44)
  TagViewGroup's TagAdapter: the tags (`numberOfTags(in:)`, `groupView(_:viewForTagAt:)`).

- `numberOfTags(groupView: CYLImageTagGroupView): number;` (L46)
  How many tags the group shows (at most `maximumTagCount`).

- `viewForTagAt(groupView: CYLImageTagGroupView, index: number): CYLImageTagItem;` (L48)
  The tag at `index`.

- `export interface CYLImageTagGroupViewDelegate` (L52)
  TagViewGroup's OnTagGroupClickListener and OnTagGroupDragListener. Every method is optional.

- `groupViewDidTapCircle?: (groupView: CYLImageTagGroupView) => void;` (L54)
  The dot was tapped (or activated with a screen reader).

- `didTapTagAt?: (groupView: CYLImageTagGroupView, index: number) => void;` (L56)
  The tag at `index` was tapped (`groupView(_:didTapTagAt:)`).

- `groupViewDidLongPress?: (groupView: CYLImageTagGroupView) => void;` (L58)
  The group was long-pressed.

- `didDragToPercentPosition?: (groupView: CYLImageTagGroupView, percentPosition: CYLPoint) => void;` (L60)
  The user dragged the group (only while `isDraggable`) (`groupView(_:didDragToPercentPosition:)`).

- `export enum CYLImageTagGroupViewAnimatableValue` (L67)
  Animatable values of a group (TagViewGroup's CIRCLE_RADIUS, CIRCLE_INNER_RADIUS, LINES_RATIO, TAG_ALPHA), for
  `animate`.

- `export class CYLImageTagGroupView` (L83)

- `readonly id: number = nextGroupId++;` (L93)
  A unique id (for ForEach keys and test ids).

- `revision: number = 0;` (L95)
  Bumped on every change the component draws.

- `showAnimation?: (groupView: CYLImageTagGroupView, completion: () => void) => void;` (L128)
  A custom show animation (setShowAnimator): call the completion when done.

- `hideAnimation?: (groupView: CYLImageTagGroupView, completion: () => void) => void;` (L130)
  A custom hide animation (setHideAnimator): call the completion when done.

- `accessibilityMoveStep: number = 0.05;` (L132)
  How far one move up / down / left / right action moves the group, as a fraction of the view. 0.05.

- `get circleRadius(): number` (L141)
  The dot's outer radius (TagViewGroup's radius).

- `get circleInnerRadius(): number` (L152)
  The dot's inner radius (inner_radius).

- `get lineWidth(): number` (L162)
  The line width (line_width).

- `get verticalDistance(): number` (L172)
  The vertical distance of the lines (v_distance).

- `get tiltDistance(): number` (L182)
  The tilt distance of the slanted lines (tilt_distance).

- `get circleColor(): string` (L192)
  The ring's color: 0x30 black by default.

- `get circleInnerColor(): string` (L202)
  The dot's color: white by default.

- `get lineColor(): string` (L212)
  The lines' color: white by default.

- `get percentPosition(): CYLPoint` (L227)
  The dot's place as fractions of the view's size (setPercent), clamped to 0...1; it moves inward when tags would
  leave the view.

- `get centerPoint(): CYLPoint` (L237)
  The dot's center, in the view's coordinates (getCenterPoint), after the last layout.

- `get displayOffset(): CYLPoint` (L242)
  Points added to the dot's place without changing `percentPosition`. Zero by default.

- `get occupiedFrame(): CYLRect` (L254)
  The area the group draws in: the dot and every tag, after the last layout.

- `get tags(): CYLImageTag[]` (L261)
  Tags shown with CYLImageTagLabel tags. Setting it replaces the data source's tags.

- `get dataSource(): CYLImageTagGroupViewDataSource | undefined` (L271)
  Custom tags instead (setTagAdapter); call `reloadData()` when they change.

- `get tagViews(): CYLImageTagItem[]` (L280)
  The tags, in order (getTagList), without the ripple.

- `get tagLabelConfiguration(): ((label: CYLImageTagLabel, tag: CYLImageTag) => void) | undefined` (L285)
  Configures each CYLImageTagLabel the group makes (font, colors, insets).

- `get showsRipple(): boolean` (L296)
  A pulsing circle under the dot (addRipple, RippleView). False by default.

- `get rippleMaxRadius(): number` (L315)
  The ripple's largest radius.

- `get rippleAlpha(): number` (L328)
  The ripple's opacity at the start, 0...1, 100/255 by default (ripple_alpha 100).

- `get rippleView(): CYLImageTagRippleView | undefined` (L341)
  The ripple, while `showsRipple`.

- `get linesProgress(): number` (L348)
  How much of each line is drawn, 0...1 (setLinesRatio). 1 by default.

- `get tagAlpha(): number` (L358)
  The tags' opacity (setTagAlpha). 1 by default.

- `get isGroupHidden(): boolean` (L368)
  Whether the group is hidden by `hide(animated:)`.

- `get delegate(): CYLImageTagGroupViewDelegate | undefined` (L375)
  Taps, the long press and drags.

- `get isDraggable(): boolean` (L385)
  Lets the user drag the group (setOnTagGroupDragListener). False by default.

- `get longPressAccessibilityActionName(): string | undefined` (L397)
  The name of the long-press action of the dot, such as "删除标签组". undefined: "长按" (`CYLMenuLongPress`).

- `get tagAccessibilityHint(): string | undefined` (L407)
  The hint of every tag, such as "轻点两下改变方向" in edit mode. undefined by default.

- `get circleAccessibilityLabel(): string` (L420)
  The dot's screen reader label: "标签组：<the tag titles>" (core string `CYLImageTagGroup`).

- `get longPressActionName(): string` (L436)
  The name of the long-press action: `longPressAccessibilityActionName`, else "长按".

- `accessibilityMove(dx: number, dy: number): boolean` (L442)
  Move up / down / left / right: a drag by `accessibilityMoveStep`; false when the group cannot move.

- `setPercentPosition(percentX: number, percentY: number): void` (L455)
  Sets the dot's place as fractions of the view's size (setPercent).

- `reloadData(): void` (L460)
  Makes the tags again, from the data source or from `tags`.

- `tagSpaceUsed(): CYLEdgeInsets` (L490)
  The space the dot and the tags need on each side of the center (getTagViewUsed).

- `originForTag(size: CYLSize, direction: CYLImageTagDirection): CYLPoint` (L495)
  The top-left corner of a tag of `size` in `direction` (getStartPoint).

- `setBounds(width: number, height: number): void` (L502)
  The view's size; the component sets it.

- `layoutIfNeeded(): void` (L514)
  Lays the dot, the tags and the lines out again (layoutSubviews).

- `get tagFrames(): CYLRect[]` (L526)
  The frames of the tags after the last layout.

- `lineAt(index: number): number[][]` (L531)
  The drawn part of each tag's line (by `linesProgress`), as ArkUI Polyline points.

- `get rippleCenter(): CYLPoint` (L541)
  The ripple's center after the last layout.

- `handleTap(index: number): void` (L557)
  A tap on the tag at `index`, or on the dot when `index` is negative.

- `handlePanStart(): void` (L570)
  The pan began: the dot's center is kept under the finger's offset.

- `handlePanUpdate(offsetX: number, offsetY: number): void` (L575)
  The pan moved by (`offsetX`, `offsetY`) since it began.

- `value(animatable: CYLImageTagGroupViewAnimatableValue): number` (L589)
  The current value of an animatable value.

- `animate(animatable: CYLImageTagGroupViewAnimatableValue, values: number[], duration: number,` (L623)
  Animates one value through `values`, decelerating (as an ObjectAnimator with a DecelerateInterpolator); with no
  values or no duration (seconds) it jumps to the last value.

- `show(animated: boolean, completion?: () => void): void` (L693)
  Shows the group: the dot bounces, the lines grow, the tags fade in (the sample's show animator), or runs
  `showAnimation` when set.

- `hide(animated: boolean, completion?: () => void): void` (L719)
  Hides it: the dot bounces, then the lines and tags fade together (the sample's hide animator), or
  `hideAnimation`.

- `dispose(): void` (L754)
  Stops a running animation (the component calls it when it disappears).

- `function cylImageTagLabelBuilder(item: CYLImageTagItem)` (L762)
  Draws a default tag.

- `export struct CYLImageTagGroupViewComponent` (L782)
  Draws a `CYLImageTagGroupView`: lay it over a picture (the size of its parent).

## harmony/classifymenu/src/main/ets/imagetag/CYLImageTagModel.ets

The models and the geometry of the image tags (iOS CYLImageTagGroupView.swift; Android CYLImageTagGroupView.kt).
Geometry after shellljx/TagViewGroup (TagGroupUtils, Apache License 2.0). Lengths are vp.

- `export enum CYLImageTagDirection` (L13)
  Where a tag goes from the dot (TagViewGroup's DIRECTION). "Straight" tags hang on a slanted line; the others on a
  vertical line and then along their bottom edge.

- `center = 10` (L25)
  Centered on the dot, without a line (the ripple).

- `export class CYLImageTagDirections` (L29)
  The computed members of `CYLImageTagDirection` (an ArkTS enum has no members).

- `static next(direction: CYLImageTagDirection): CYLImageTagDirection` (L34)
  `next`: the next of the ten line directions, in declaration order (`center` is skipped), as the sample turns a
  tag on each tap while editing.

- `export class CYLImageTagDefaults` (L51)
  The defaults of `CYLImageTagGroupView` (its static members on iOS).

- `static readonly defaultCircleRadius: number = 8;` (L53)
  8: the dot's outer radius.

- `static readonly defaultCircleInnerRadius: number = 4;` (L55)
  4: the dot's inner radius.

- `static readonly defaultVerticalDistance: number = 28;` (L57)
  28: the vertical distance of the lines.

- `static readonly defaultTiltDistance: number = 20;` (L59)
  20: the tilt distance of the slanted lines.

- `static readonly defaultLineWidth: number = 1;` (L61)
  1: the line width.

- `static readonly maximumTagCount: number = 6;` (L63)
  6: the most tags in one group.

- `static readonly defaultRippleMaxRadius: number = 20;` (L65)
  20: the ripple's largest radius.

- `export class CYLImageTag` (L69)
  One tag: a title, its direction and anything the host keeps with it (the sample's TagGroupModel.Tag).

- `title: string;` (L71)
  The text of the tag.

- `direction: CYLImageTagDirection;` (L73)
  Where the tag goes from the dot.

- `link?: string;` (L75)
  A link of the tag (the sample's Tag.link), not opened by the view.

- `userInfo?: Object;` (L77)
  Anything the host keeps with the tag.

- `constructor(title: string, direction: CYLImageTagDirection, link?: string, userInfo?: Object)` (L80)
  `init(title:direction:link:userInfo:)`.

- `copy(): CYLImageTag` (L88)
  An independent copy (the user info is shared).

- `export class CYLImageTagGroup` (L94)
  A group of tags at a point of the picture, as fractions of its size (the sample's TagGroupModel).

- `tags: CYLImageTag[];` (L96)
  The tags, at most `CYLImageTagDefaults.maximumTagCount` of them are shown.

- `percentPosition: CYLPoint;` (L98)
  The dot's place, as fractions of the picture's width and height.

- `constructor(tags: CYLImageTag[], percentPosition: CYLPoint)` (L101)
  `init(tags:percentPosition:)`.

- `static defaultDirections(count: number): CYLImageTagDirection[]` (L110)
  Directions for `count` new tags, as the sample's edit dialog sets them: one tag right-center; two right-top and
  right-bottom; three right-top, right-center and right-bottom; then left-top, left-center and left-bottom.

- `copy(): CYLImageTagGroup` (L127)
  An independent copy, with copies of the tags.

- `export interface CYLImageTagItem` (L136)
  A tag of a group (TagViewGroup's ITagView). The group sizes it with `sizeThatFits` and places it; the group view
  draws it with `contentBuilder`, or as a CYLImageTagLabel when there is none.

- `tagDirection: CYLImageTagDirection;` (L138)
  Where the tag goes from the dot.

- `accessibilityLabel?: string;` (L140)
  The screen reader's label of the tag.

- `accessibilityHint?: string;` (L142)
  The screen reader's hint of the tag (set by the group).

- `sizeThatFits(width: number): CYLSize;` (L144)
  The size the tag needs within `width`.

- `contentBuilder?: WrappedBuilder<[CYLImageTagItem]>;` (L146)
  Draws a custom tag (a data source's view); undefined draws a label.

- `export class CYLImageTagLabel implements CYLImageTagItem` (L150)
  The default tag (TagViewGroup's TagTextView): white 13 vp text with a black glow, 12 × 4 vp padding.

- `tagDirection: CYLImageTagDirection = CYLImageTagDirection.rightCenter;` (L152)
  Where the tag goes from the dot; `rightCenter` by default.

- `contentInsets: CYLEdgeInsets = new CYLEdgeInsets(4, 12, 4, 12);` (L154)
  Space around the text. {4, 12, 4, 12} by default.

- `sizeThatFits(width: number): CYLSize` (L166)
  One line when it fits; wrapped to `width` otherwise (long titles, large font sizes).

- `export class CYLImageTagPlacement` (L190)
  One tag placed by a layout: its frame, and the line from the dot (none for `center`).

- `export class CYLImageTagLayoutResult` (L201)
  The result of `CYLImageTagGeometry.layout`.

- `readonly centerPoint: CYLPoint;` (L203)
  The dot's center, with the display offset.

- `readonly rippleCenter: CYLPoint;` (L205)
  The ripple's center (without the display offset, as iOS).

- `export class CYLImageTagMetrics` (L216)
  The inputs of the geometry: the group's lengths.

- `layoutVerticalDistance: number = 0;` (L221)
  The distances of the last layout: at least the tallest tag, so neighboring tags never overlap.

- `export class CYLImageTagGeometry` (L226)
  TagGroupUtils: the geometry of a group, free of rendering.

- `static tagSpaceUsed(metrics: CYLImageTagMetrics, directions: CYLImageTagDirection[], sizes: CYLSize[]): CYLEdgeInsets` (L228)
  The space the dot and the tags need on each side of the center (getTagViewUsed).

- `static originForTag(metrics: CYLImageTagMetrics, center: CYLPoint, size: CYLSize,` (L298)
  The top-left corner of a tag of `size` in `direction` around `center` (getStartPoint).

- `static tagWidthLimit(metrics: CYLImageTagMetrics, boundsWidth: number): number` (L333)
  The width a tag may take: never more than the width beside the dot.

- `static layout(metrics: CYLImageTagMetrics, width: number, height: number, percent: CYLPoint, offset: CYLPoint,` (L338)
  layoutSubviews: the dot moved inward when tags would leave the view (checkBounds), the tags and the lines.

- `static partialLine(points: CYLPoint[], progress: number): CYLPoint[]` (L377)
  The part of a polyline drawn at `progress` 0...1 of its length (a shape layer's strokeEnd).

- `static occupiedFrame(center: CYLPoint, radius: number, frames: CYLRect[]): CYLRect` (L407)
  The union of the dot and the tag frames (occupiedFrame).

- `static separationOffset(frame: CYLRect, placed: CYLRect[], height: number, spacing: number): number` (L425)
  CYLImageTagView's separateGroups for one group: the smallest vertical move of `frame` that clears every earlier
  group (`placed`) and stays inside `height`; 0 when it is clear already or nothing works.

- `static joinTitles(titles: string[], language: string): string` (L451)
  The list of titles in the language (ListFormatter).

## harmony/classifymenu/src/main/ets/imagetag/CYLImageTagView.ets

A picture with groups of tags on it (iOS CYLImageTagView; Android CYLImageTagView.kt), each group at a position
relative to the picture. In edit mode the groups can be dragged and a tap on a tag turns it to the next direction.
`CYLImageTagView` holds the state and the API (as the iOS class); `CYLImageTagViewComponent` draws it.

- `export class CYLImageTagImageView` (L18)
  `CYLImageTagView.imageView` (iOS `UIImageView`): the picture as the component draws it, its image, content mode
  and accessibility. Changes are drawn at once.

- `setChangeHandler(handler: () => void): void` (L27)
  Called by the `CYLImageTagView` that owns it.

- `get contentMode(): ImageFit` (L41)
  `contentMode`: `ImageFit.Cover` (aspect fill, the default), `ImageFit.Contain`…

- `export class CYLImageTagView implements CYLImageTagGroupViewDelegate` (L79)

- `revision: number = 0;` (L81)
  Bumped on every change the component draws.

- `readonly imageView: CYLImageTagImageView = new CYLImageTagImageView();` (L87)
  The picture's image view (`imageView`).

- `groupConfiguration?: (groupView: CYLImageTagGroupView, index: number) => void;` (L93)
  Configures each group view after it is made (radii, colors, line lengths).

- `imageTapHandler?: () => void;` (L95)
  A tap on the picture outside the tags (the sample toggles the tags).

- `circleTapHandler?: (index: number) => void;` (L97)
  A tap on the circle of the group at this index.

- `tagTapHandler?: (groupIndex: number, tagIndex: number, tag: CYLImageTag) => void;` (L99)
  After the turn of the tag while editing.

- `longPressHandler?: (index: number) => void;` (L101)
  A long press on the group at this index.

- `dragHandler?: (index: number, percentPosition: CYLPoint) => void;` (L103)
  The group at this index was dragged to a new position (relative to the picture).

- `constructor()` (L106)
  `init()`: an empty view.

- `get imageAccessibilityHint(): string | undefined` (L113)
  The picture's screen reader hint, such as "轻点两下显示或隐藏标签" (`imageView.accessibilityHint`).

- `get imageAccessibilityLabel(): string | undefined` (L125)
  The picture's screen reader label (`imageView.accessibilityLabel`); undefined: "图片" (core string
  `CYLImageTagPicture`).

- `get image(): CYLImage | undefined` (L134)
  The picture (`imageView.image`).

- `get tagGroups(): CYLImageTagGroup[]` (L143)
  The groups, kept up to date while editing (getTagGroupModels). Setting it replaces them (setTagList).

- `get groupViews(): CYLImageTagGroupView[]` (L155)
  The group views, in the order of `tagGroups`.

- `get isEditing(): boolean` (L163)
  Edit mode (setEditMode): groups can be dragged, a tap on a tag turns it to the next direction, no ripples. False
  by default: groups show a ripple and toggle with an animation.

- `get longPressAccessibilityActionName(): string | undefined` (L178)
  The name of every group's long-press action, such as "删除标签组" in edit mode. undefined: "长按".

- `get pictureAccessibilityLabel(): string` (L190)
  The picture's label.

- `addTagGroup(group: CYLImageTagGroup): void` (L198)
  Adds a copy of the group and its view on top of the others.

- `removeTagGroup(index: number): void` (L214)
  Removes the group at this index and its view; an index past the end does nothing.

- `removeAllTagGroups(): void` (L225)
  Removes every group and its view.

- `toggleTagGroups(animated: boolean): void` (L235)
  Shows hidden groups and hides shown ones, animated (excuteTagsAnimation).

- `setBounds(width: number, height: number): void` (L248)
  The view's size; the component sets it.

- `layoutSubviews(): void` (L265)
  Keeps groups from covering each other: each group that overlaps an earlier one moves up or down by the smallest
  distance that clears every earlier group and stays inside the view. Only the display moves (`displayOffset`).
  While editing, groups stay where they are dragged.

- `didTapTagAt: (groupView: CYLImageTagGroupView, tagIndex: number) => void =` (L293)
  `groupView(_:didTapTagAt:)`.

- `didDragToPercentPosition: (groupView: CYLImageTagGroupView, percentPosition: CYLPoint) => void =` (L316)
  `groupView(_:didDragToPercentPosition:)`.

- `export struct CYLImageTagViewComponent` (L339)
  Draws a `CYLImageTagView`: the picture (aspect fill, clipped) with its groups on top.

## harmony/classifymenu/src/main/ets/tagviews/CYLTagButton.ets

One tag (iOS CYLTagButton.swift; Android CYLTagButton.kt): an icon and a title side by side (the icon after, above or
below the title with `imagePlacement`), in a box drawn from the style's appearance for the current state, with an
optional delete indicator, an optional badge and an optional animated icon (Lottie, PAG, Rive, SVGA or GIF, by the
file's extension). It is also the one icon + title + animated icon component of the libraries built on this one (a
search bar item, a placeholder's icon): `new CYLTagButton(title, image, animationURL)` makes one for use on its own.
The animated icon is CYLTabBarController's shared component, `CYLAnimatedItemView` (`CYLTagAnimatedIcon`): iOS and
Android subclass it, and ArkTS structs cannot subclass, so the tag wraps it in its icon slot and keeps its own
layout, measuring, title, delete indicator and badge. The library depends on no animation library: the app registers
the types it plays (`CYLAnimatedItemEngines.register(type)`) and the views that play them
(`CYLTagAnimationBuilder.register(builder)`); a type nobody registered shows the static image, or the placeholder.
`CYLTagButton` holds the state, the layout and the API (as the iOS class); `CYLTagButtonComponent` draws it, and
`CYLTagButtonHost` draws it inside an ArkUI V2 (`@ComponentV2`) parent. The icon may be a pixel image, a rawfile, a
pixel map or a system symbol (`$r('sys.symbol.camera')`, drawn with `SymbolGlyph`); every color takes a
`ResourceColor`, so theme colors (`$r('sys.color.font_primary')`) follow the color mode.

- `const BADGE_DOT_DIAMETER: number = 8;` (L45)
  The badge: a dot's diameter, the minimum height of a badge with text, its text's side padding and font size.

- `const SYMBOL_DEFAULT_SIDE: number = 16;` (L52)
  The side of a system symbol drawn without an icon slot (a zero `imageSize`), SymbolGlyph's default font size.

- `export const CYLTagBadgeDefaultColor: string = '#FF3B30';` (L56)
  `UIColor.systemRed`, the default `badgeColor`.

- `export class CYLTagButtonPart` (L62)
  A subview of the tag as last laid out (`imageView`, `titleLabel`, `deleteIndicatorLabel`): its frame in the tag's
  coordinates and what it shows. The component draws each part from it.

- `tintsImage: boolean = false;` (L74)
  Whether the style sets an icon color for the state (`CYLMenuStyle.setIconColor`): then bitmap icons are tinted
  too, as template images are on iOS; without one, a bitmap keeps its own colors (an original image).

- `rotation: number = 0;` (L79)
  Degrees (the fold chevron's turn).

- `maxLines: number = CYLTagTitleMaxLines.single;` (L84)
  The most lines of a title (`CYLMenuStyle.titleMaxLines`): 1 by default, `CYLTagTitleMaxLines.unlimited` for as many
  as it needs.

- `export class CYLTagButton` (L88)

- `revision: number = 0;` (L92)
  Bumped on every change the component draws.

- `readonly imageView: CYLTagButtonPart = new CYLTagButtonPart();` (L96)
  The icon (as laid out).

- `readonly titleLabel: CYLTagButtonPart = new CYLTagButtonPart();` (L100)
  The title (as laid out).

- `readonly deleteIndicatorLabel: CYLTagButtonPart = new CYLTagButtonPart();` (L104)
  The delete indicator (hidden unless `showsDeleteIndicator`, or while a cross is drawn).

- `readonly badgeLabel: CYLTagButtonPart = new CYLTagButtonPart();` (L108)
  The badge (hidden while `badgeValue` is undefined), at the top trailing corner of the icon.

- `fontScale: number = 1;` (L112)
  The system font scale (iOS: the trait collection's content size category).

- `changeHandler?: () => void;` (L143)
  Called on every change the component draws (the tag list re-renders from the button).

- `playToken: number = 0;` (L149)
  Bumped by `playAnimation()`.

- `animationViewToken: number = 0;` (L153)
  Bumped when the animated icon's view must be made again (a new file or size).

- `crossLines: number[][] = [];` (L157)
  The two lines of the drawn cross ([x1, y1, x2, y2] each), or empty.

- `deleteIndicatorImage?: CYLImage = undefined;` (L162)
  `CYLMenuStyle.deleteIndicatorImage` and its frame in the tag: a square inside the indicator, the padding beside it,
  not above it, so a one-line tag keeps the full line height for it.

- `elevation: number = 0;` (L167)
  `CYLMenuStyle.elevation`: a shadow under the tag (vp); the tag stops clipping its content then.

- `editingIconFrames: CYLRect[] = [];` (L172)
  The frames of the two editing icons (the edit icon, then the cross) while `showsRenameIndicator`, or empty.

- `editingIndicatorsFrame: CYLRect = new CYLRect();` (L174)
  The frame of `editingIndicatorsView` (the two icon slots and the space between them), or empty.

- `editingIconColor: ResourceColor = CYLColor.BLACK;` (L176)
  The color of the editing icons (`CYLMenuStyle.deleteIndicatorColor`, else the text color).

- `indicatorColorIsExplicit: boolean = false;` (L182)
  Whether `crossColor`, `editingIconColor` and the delete label's colour are EXPLICIT (the style's `deleteIndicatorColor`, or an
  explicit title colour they follow) rather than the built-in default text colour. Only an explicit colour is lifted on a disabled
  tag (the built-in disabled look is never adapted); the `resolvedCrossColor` family reads it.

- `appearanceCornerRadius: number = 0;` (L185)
  The appearance's radius as it is (the capsule constant by default): `cylanimateditem` implements the capsule.

- `glassTintAlpha: number = -1;` (L187)
  A selected Liquid Glass tag keeps its full color (tint alpha 1, still glass); -1 is the modifier's default share.

- `static readonly GLASS_DEFAULT_TINT: ResourceColor = Color.Transparent;` (L192)
  What a glass tag with no explicit background color hands to `CYLAnimatedItemBackgroundModifier`: a transparent color means
  "no color", and the glass draws its frosted default tint (225, 222, 220 at 0.5; white at 0.14 in dark mode).

- `static glassTintColor(explicitColor: ResourceColor | undefined): ResourceColor` (L198)
  The color a glass tag hands to the modifier: the explicit color, or `GLASS_DEFAULT_TINT` ("no color") when there is none
  or it is fully transparent (a cleared color means "unset" under glass, as on iOS).

- `static itemBackgroundStyleOf(style: CYLMenuStyle): CYLAnimatedItemBackgroundStyle` (L206)
  The background style a tag of `style` hands to `CYLAnimatedItemBackgroundModifier` (also the inline fold cell's).

- `static itemBackgroundColor(style: CYLMenuStyle, appearance: CYLTagAppearance, pressed: boolean = false): ResourceColor` (L216)
  The color a tag in `appearance` hands to `CYLAnimatedItemBackgroundModifier`. Where glass is drawn only an EXPLICIT color
  tints it (`glassTintColor`; an unset one means no tint); flat keeps the effective color. `pressed` uses the style's
  highlighted color. The inline fold cell shares this rule, so it has the tags' background.

- `static hasItemBorder(style: CYLMenuStyle, appearance: CYLTagAppearance): boolean` (L228)
  Whether a tag in `appearance` hands a border to `CYLAnimatedItemBackgroundModifier`. Flat: any border colour. Where glass
  is drawn: only a colour the app / configuration / preset set (the built-in default is dropped so the shared glass rim
  shows); a width set without a colour draws none. The inline fold cell shares this rule.

- `static itemBorderColor(style: CYLMenuStyle, appearance: CYLTagAppearance): ResourceColor` (L234)
  The border colour a tag in `appearance` hands to the modifier (clear when `hasItemBorder` is false).

- `static itemBorderWidth(style: CYLMenuStyle, appearance: CYLTagAppearance): number` (L241)
  The border width a tag in `appearance` hands to the modifier: 0 without a border (the shared glass rim then applies).

- `itemBackgroundStyle: CYLAnimatedItemBackgroundStyle = CYLAnimatedItemBackgroundStyle.flat;` (L250)
  The background, radius and border are `cylanimateditem`'s (`CYLAnimatedItemBackgroundModifier`, the interface of
  `CYLAnimatedItemView.itemBackgroundStyle…`): the style; the radius is `cornerRadius` (the appearance's, the capsule constant by default).

- `glassTint?: ResourceColor = undefined;` (L255)
  The glass tint the item's colour resolution judges a colour against: the explicit (or pressed) background color, undefined
  while there is none (the frosted default tint). Not `backgroundColor`, which holds `GLASS_DEFAULT_TINT` for "none".

- `subclassTitleColor?: ResourceColor = undefined;` (L262)
  The CHANNELS of the title colour, handed to `CYLAnimatedItemColorResolver` (the item's one precedence and adaptation path):
  the EXPLICIT colour of the current state (set by the app / configuration / preset: the subclass-explicit level), undefined
  while there is none; and the BUILT-IN one (the style's default: the subclass built-in level). The tag never writes the
  integrator-owned `titleColor` / `iconColor`.

- `subclassIconColor?: ResourceColor = undefined;` (L268)
  The same two channels of the icon colour: the style's icon color, or, while that is unset, an explicit title color the icon
  follows; and the style's built-in colour (the icon follows the title's).

- `imageRotationDuration: number = 0;` (L277)
  Milliseconds over which a change of `imageView.rotation` is animated (the fold chevron); 0: at once.

- `animationFrame: CYLRect = new CYLRect();` (L281)
  The animated icon's frame (when `animationURL` is set).

- `animationImage: ResourceStr = '';` (L285)
  The static image under the animated icon while it loads and after it fails (`CYLAnimatedItemView.image`), or ''.

- `animationIconColor: ResourceColor = '';` (L292)
  The explicit color `CYLAnimatedItemView` tints the animated icon's static image with (its `subclassIconColor` channel:
  `animationImage` / `animationSelectedImage` while the animation loads and after it fails): the state's `CYLMenuStyle.iconColor` when
  the style sets one, as the tag's own static icon is tinted; '' (the image's own colors) otherwise or without an
  animation.

- `animationSelectedImage: ResourceStr = '';` (L296)
  The static image under the animated icon while selected (`CYLAnimatedItemView.selectedImage`), or ''.

- `constructor(title?: string, image?: CYLImage, animationURL?: string)` (L302)
  `init(frame:)` without arguments; `init(title:image:)` / `init(title:image:animationURL:)` with them: a tag for use
  on its own (a search bar item, a toolbar button), drawn with the default style, sized to fit (`intrinsicSize()`).

- `get badgeValue(): string | undefined` (L317)
  `badgeValue`, as `UITabBarItem.badgeValue`: undefined (the default) hides the badge, '' shows a dot, any other text
  ('3', '99+') a capsule with it, at the top trailing corner of the icon (of the title when there is no icon). The
  screen reader reads it as the tag's value (`accessibilityValue`).

- `get badgeColor(): ResourceColor | undefined` (L332)
  `badgeColor`: the badge's background, any `ResourceColor` (a theme color follows the color mode); undefined
  restores the default, system red.

- `get badgeTextColor(): ResourceColor | undefined` (L344)
  The badge's text color; undefined (the default) is white.

- `get badgeFont(): CYLFont | undefined` (L356)
  The badge's font; undefined (the default) is 11 fp bold, scaled with `fontScale`.

- `get badgeMinimumSize(): CYLSize` (L368)
  The smallest size of a badge with text; zero (the default) is 16 vp high and at least as wide (a dot stays 8 vp).

- `get badgeContentInsets(): CYLEdgeInsets` (L381)
  The space around a badge's text (its left and right insets widen it, its top and bottom insets heighten it); the
  default is 4 vp on the left and right, 1 vp above and below.

- `get badgePositionAdjustment(): CYLOffset` (L393)
  Moves the badge from the icon's (or the title's) top trailing corner; it stays inside the tag.

- `get accessibilityLabel(): string | undefined` (L405)
  What the screen reader reads first: the label that was set, else the title.

- `get accessibilityValue(): string | undefined` (L421)
  The badge as the screen reader reads it: its text, or "New" (localized) for a dot; undefined without a badge.

- `get image(): CYLImage | undefined` (L444)
  The icon: a pixel image, a rawfile, a pixel map, or a system symbol (`$r('sys.symbol.camera')`), which is drawn
  with `SymbolGlyph` in the state's icon color (`CYLMenuStyle.iconColor(state)`).

- `get selectedImage(): CYLImage | undefined` (L456)
  Shown while selected; undefined keeps `image`.

- `get animationURL(): string | undefined` (L471)
  Animated icon: `asset:<rawfile>` (`.json` Lottie, `.pag` PAG, `.riv` Rive, `.gif` GIF, `.svga` SVGA; options after
  `#`), drawn by `CYLAnimatedItemView` with the view the app registered for its type. Without it, `image` is shown;
  with it, `image` (`selectedImage` while selected) shows while it loads, after it fails and when no engine of its
  type is registered (a pixel map or a symbol cannot: the component's placeholder shows instead).

- `get animationRestingProgress(): number` (L486)
  The frame (0...1) of the animated icon shown while not selected. Default 0, the first frame.

- `get animationSpeed(): number | undefined` (L500)
  The playback speed of the animated icon; undefined (the default) uses `style.animationSpeed`.

- `resetAnimationSpeed(): void` (L510)
  `resetAnimationSpeed()`: follows `style.animationSpeed` again.

- `get animationLoops(): boolean` (L517)
  True repeats the animated icon after `playAnimation()`; false (the default) plays once.

- `get animationView(): CYLAnimationPlayer | undefined` (L539)
  `animationView`: the live player of the animated icon, the one the app's animation view handed over with
  `CYLTagAnimationContext.ready(player)` (the example's players expose `lottieItem`, `pagController`,
  `gifFrames`, `svgaMovie`), or undefined while there is none (no `animationURL`, not drawn yet, no engine). It is
  always undefined for a type drawn by a component-level builder (Rive): that one is driven through
  `CYLAnimatedItemView`'s own props.

- `get animationPlayer(): CYLAnimationPlayer | undefined` (L546)
  The player of the animated icon (`animationView`).

- `get showsDeleteIndicator(): boolean` (L553)
  Shows the style's delete indicator ("×") after the title. False by default.

- `get deleteIndicatorHitFrame(): CYLRect` (L568)
  The area a tap on the delete indicator should cover, in the tag's coordinates: from the space before it to the
  trailing edge, the tag's full height. Empty while it is hidden.

- `get showsRenameIndicator(): boolean` (L577)
  `showsRenameIndicator`: shows a rename indicator (an edit icon, `sys.symbol.square_and_pencil`) before the delete
  indicator, for a tag that can be renamed in editing mode; with `showsDeleteIndicator`, the two icons are drawn by
  `editingIndicatorsView` instead of the style's indicator. False by default.

- `get renameIndicatorHitFrame(): CYLRect` (L589)
  `renameIndicatorHitFrame`: the area a tap on the rename indicator covers, the tag's full height; empty while hidden.

- `get editingIndicatorsView(): CYLAnimatedItemStackModel` (L598)
  `editingIndicatorsView`: the two editing icons while `showsRenameIndicator` (the edit icon, then the cross): the
  model of a CYLTabBarController `CYLAnimatedItemStackView` laid out in a row (`axis` 'horizontal'),
  `CYLMenuStyle.editingIndicatorSpacing` apart, tinted with the indicator color (`iconColor`).

- `get showsEditingIcons(): boolean` (L613)
  Whether the two editing icons replace the delete indicator.

- `get style(): CYLMenuStyle` (L620)
  The style the tag is drawn with. Setting copies it; set it again after changing it.

- `static get isAnimationEngineAvailable(): boolean` (L671)
  Whether the app registered an animation engine (`CYLAnimatedItemEngines.register(type)`). The library depends on
  no animation library; the example registers Lottie, PAG, Rive, SVGA and GIF.

- `playAnimation(): void` (L679)
  Plays the animated icon from the start, as a tab icon plays when the tab is tapped; called before the icon is
  loaded (a tag shown for the first time), it plays once the icon is loaded.

- `static widthWithImage(title: string | undefined, image: CYLImage | undefined, style: CYLMenuStyle,` (L696)
  `width(forTitle:image:style:traitCollection:)`: the width a tag needs in every state.

- `static widthWithRenameIndicator(title: string | undefined, iconSize: CYLSize, showsDeleteIndicator: boolean,` (L704)
  `width(forTitle:iconSize:showsDeleteIndicator:style:traitCollection:)`.

- `static iconSize(image: CYLImage | undefined, animated: boolean, style: CYLMenuStyle): CYLSize` (L717)
  `iconSize(for:animated:style:)`.

- `static height(style: CYLMenuStyle, fontScale: number = 1): number` (L724)
  `height(for:traitCollection:)`.

- `static heightForTitle(title: string | undefined, iconSize: CYLSize, style: CYLMenuStyle, fontScale: number = 1): number` (L731)
  `height(forTitle:iconSize:style:traitCollection:)`.

- `get minimumSize(): CYLSize` (L739)
  The smallest size `intrinsicSize()` returns, such as a touch target (36 x 36 for a search bar item); zero (the
  default) adds nothing. The content is centered in the extra room.

- `intrinsicSize(): CYLSize` (L752)
  `intrinsicContentSize`: the size the tag needs for its content (its width in every state and its height), at
  least `minimumSize`.

- `setBounds(width: number, height: number): void` (L765)
  The tag's size, from the component; lays the parts out again.

- `setAnimationPlayer(player: CYLAnimationPlayer | undefined): void` (L782)
  Called by the component once the animated icon is loaded (or undefined when it is gone).

- `itemDidLoad(): void` (L799)
  The animated icon of a builder-drawn type has loaded: a `playAnimation()` made before that replays now.

- `pendingPlay: boolean = false;` (L810)
  Plays once the animated icon is loaded (a tap made it again).

- `get currentState(): number` (L822)
  Disabled wins over selected.

- `resolvedTitleColor(): ResourceColor` (L1179)
  The title color to draw: the item's resolution (`CYLAnimatedItemColorResolver.resolvedTitleColor`) of the tag's channels.
  Read when the tag draws, so a light / dark switch re-resolves it.

- `resolvedIconColor(): ResourceColor` (L1187)
  The icon color to draw (a symbol's font color, a bitmap's tint when `imageView.tintsImage`): the item's resolution
  (`CYLAnimatedItemColorResolver.resolvedIconColor`) of the tag's channels.

- `adaptedOnGlass(color: ResourceColor, kind: string, explicit: boolean): ResourceColor` (L1196)
  The dark-glass rule for a colour the tag draws itself (the item's `adaptedOnGlass`, `CYLAnimatedItemContrast.adaptedOnGlassState`),
  judged against the tag's own glass state: `color` itself unless glass is drawn in dark mode, then lifted to 4.5:1 (`kind` text)
  or 3:1 (icon). A built-in colour (`explicit` false) of a disabled tag is never adapted; a dynamic colour (a resource) is never changed.

- `static adaptedOnGlassOf(color: ResourceColor, kind: string, backgroundStyle: CYLAnimatedItemBackgroundStyle,` (L1207)
  The same rule for any view that draws a glass of `backgroundStyle` (the inline fold cell shares it): `color` itself unless glass is
  really drawn and the mode is dark, then lifted against the glass of `glassTint` / `tintAlpha`.

- `resolvedCrossColor(): ResourceColor` (L1214)
  The delete cross's colour to draw (an icon: 3:1 on drawn dark glass). Read when the tag draws, so a light / dark switch re-resolves it.

- `resolvedDeleteLabelColor(): ResourceColor` (L1219)
  The delete label's colour to draw (a text: 4.5:1 on drawn dark glass).

- `resolvedDeleteSymbolColor(): ResourceColor` (L1224)
  The delete symbol image's colour to draw (an icon: 3:1). A delete bitmap keeps its own colours.

- `resolvedEditingIconColor(): ResourceColor` (L1229)
  The editing icons' colour (an icon: 3:1), the value `editingIndicatorsView.iconColor` gets when it is a static colour.

- `resolvedAnimationIconColor(): ResourceColor` (L1238)
  The explicit icon colour handed to the animated icon (`CYLTagAnimatedIcon.subclassIconColor`), '' while there is none. The
  tag lifts it itself (3:1) because the inner `CYLAnimatedItemView` stays flat: giving it the glass state would make it draw a
  second glass inside the tag. The item then judges the lifted colour as flat and leaves it as it is.

- `resolvedAnimationBuiltInIconColor(): ResourceColor` (L1244)
  The built-in icon colour handed to the animated icon (`CYLTagAnimatedIcon.builtInIconColor`), lifted like `resolvedAnimationIconColor`.

- `export struct CYLTagButtonComponent` (L1337)
  Draws a `CYLTagButton`. Without `tagWidth` / `tagHeight` it takes the tag's intrinsic size. `interactive` (the
  default) shows the pressed look while touched; a cell that handles touches itself turns it off.

- `aboutToAppear(): void` (L1348)
  A tag drawn on its own (no tag list or controller around it) still measures its title with the window's text
  metrics: without them the width came from an estimate, far too narrow for CJK titles ("SVG…").

- `export struct CYLTagButtonHost` (L1572)
  Draws a `CYLTagButton` inside an ArkUI V2 parent (`@ComponentV2`), which cannot link a V1 `@Observed` object
  itself: the host holds the button as V1 state and links it to `CYLTagButtonComponent` (the bridge that
  CYLSearchViewController uses for CYLTableViewPlaceHolder's V1 placeholders). The host keeps the button it was
  created with: change that button's properties to redraw it, and give the host another key (a `ForEach` key) to draw
  another button. Without `tagWidth` / `tagHeight` the tag takes its intrinsic size (`intrinsicSize()`).

- `tagWidth?: number;` (L1580)
  The width; undefined uses the button's intrinsic width.

- `tagHeight?: number;` (L1584)
  The height; undefined uses the button's intrinsic height.

- `interactive: boolean = true;` (L1588)
  Shows the pressed look while touched (the default); off when the parent handles touches.

- `onTagClick?: () => void;` (L1592)
  Called on a tap.

## harmony/classifymenu/src/main/ets/tagviews/CYLTagCreateCell.ets

The "+ 新建标签" item of the tag list (iOS CYLTagCreateCell.swift; Android CYLTagCreateCell.kt;
`CYLMenuItemType.create`): an outlined tag with a plus icon, an action rather than a tag (never selected). Draw it
with `CYLTagListCellComponent`.

- `export class CYLTagCreateCell extends CYLTagListCell` (L13)

- `static get plusImage(): CYLImage` (L15)
  The plus icon of the core resources (drawn in the icon color).

- `static title(name?: string): string` (L20)
  "新建标签" for an empty name, "新建标签：<name>" otherwise.

- `static outlinedStyle(style: CYLMenuStyle): CYLMenuStyle` (L25)
  The outlined look of the item, from a list (or section) style.

- `configureCreate(name: string | undefined, style: CYLMenuStyle, isEnabled: boolean): void` (L30)
  `configure(name:style:isEnabled:)`: "+ 新建标签" or "+ 新建标签：<name>" in `style` (already outlined).

## harmony/classifymenu/src/main/ets/tagviews/CYLTagFoldButton.ets

The view of a fold control (iOS CYLTagFoldButton.swift; Android CYLTagFoldButton.kt): a `CYLTagButton` without a
border or background, the title then the chevron. Expanded, it shows what the control shows expanded (only the
icon, turned 180°, or the collapse title). Draw it with `CYLTagButtonComponent`.

- `const ROTATION_DURATION: number = 0.25;` (L13)
  Seconds.

- `const EXPANDED_ROTATION: number = (Math.PI - 0.0001) * 180 / Math.PI;` (L15)
  Just under π, so that it turns the same way back and forth (degrees).

- `export class CYLTagFoldButton extends CYLTagButton` (L18)

- `get foldControl(): CYLMenuFoldControl | undefined` (L23)
  The control last applied.

- `get isExpanded(): boolean` (L28)
  The state last applied.

- `applyFoldControl(foldControl: CYLMenuFoldControl, color: ResourceColor | undefined, expanded: boolean,` (L36)
  Shows `foldControl` in `color` (its own color wins) for the expanded or collapsed state; the icon turns with an
  animation when `animated`.

- `applyInlineFoldControl(foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: boolean,` (L45)
  The inline fold control (`CYLMenuFoldControlPosition.tail`): the same content, drawn like the tags of
  `itemStyle` (its normal look), so it reads as the last tag; an icon-only control is a circle.

- `static inlineSize(foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: boolean,` (L53)
  The size of the inline fold control in that state: the tags' height, and at least as wide as it is high.

- `static size(foldControl: CYLMenuFoldControl, expanded: boolean, fontScale: number = 1): CYLSize` (L59)
  The size the control needs in that state (at least a 44 vp wide touch target).

## harmony/classifymenu/src/main/ets/tagviews/CYLTagFoldCell.ets

The inline fold control of the tag list (iOS CYLTagFoldCell.swift; Android CYLTagFoldCell.kt): a cell among the
tags, after the last visible one, drawn like a tag (`CYLTagFoldButton`). The cell is the accessibility element
(id `CYLTagListFoldControl`), a button whose label the list sets.

- `export class CYLTagFoldCell` (L13)

- `readonly foldButton: CYLTagFoldButton = new CYLTagFoldButton();` (L15)
  The control drawn in the cell; the cell handles its taps.

- `accessibilityLabel: string = '';` (L17)
  The cell's screen reader label ("<section> 更多/收起"), set by the list.

- `configure(foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: boolean, animated: boolean): void` (L21)
  Shows `foldControl` for the expanded or collapsed state, drawn like the tags of `itemStyle`.

- `export struct CYLTagFoldCellComponent` (L28)
  Draws a `CYLTagFoldCell`.

## harmony/classifymenu/src/main/ets/tagviews/CYLTagListAccessibility.ets

- `export class CYLTagListAccessibilityIdentifier` (L6)
  Stable accessibility identifiers of the tag list's views (iOS CYLTagListAccessibility.swift; Android
  CYLTagListAccessibility.kt), so UI tests and tools find them without coordinates. The labels stay localized; the
  identifiers never change. ArkUI takes them as a component's `id`.

- `static readonly title: string = 'CYLTagListTitle';` (L8)
  The list's title view, a header.

- `static readonly foldControl: string = 'CYLTagListFoldControl';` (L10)
  Every fold control ("<section> 更多/收起"), in a section header, at the bottom or among the tags.

- `static readonly item: string = 'CYLTagListItem';` (L12)
  Every tag cell; its label is the tag's title.

- `static readonly createItem: string = 'CYLTagCreateItem';` (L14)
  The "+ 新建标签" item (`CYLMenuItemType.create`).

- `static readonly moreButton: string = 'CYLTagListMoreButton';` (L16)
  The More button of a section header (`menuShowsMoreButtonInSection`).

- `static readonly deleteButton: string = 'CYLTagListDeleteButton';` (L18)
  The tappable delete indicator ("×") of a deletable tag.

- `static readonly renameButton: string = 'CYLTagListRenameButton';` (L20)
  The rename indicator of a tag in editing mode (an edit icon before the delete indicator).

- `static readonly renameTitle: string = 'CYLTagListRenameTitle';` (L22)
  The title of a renamable tag in editing mode: a tap renames it too (`renamesOnTitleTapWhileEditing`).

- `static readonly clearButton: string = 'CYLTagListClearButton';` (L24)
  A section header's clear button (`menuShowsClearButtonForSection`).

## harmony/classifymenu/src/main/ets/tagviews/CYLTagListCell.ets

The cell of the tag list (iOS CYLTagListCell.swift; Android CYLTagListCell.kt): one `CYLTagButton` (the tag view);
the cell is the accessibility element, a button whose label is the tag's title. It shows the style's touch ripple
and makes the delete indicator tappable.
`CYLTagListCell` holds the state and the API; `CYLTagListCellComponent` draws it.

- `export class CYLTagRipple` (L17)
  A ripple to play: a circle from the touch point to the farthest corner, fading out.

- `duration: number = 1;` (L24)
  Seconds.

- `export class CYLTagListCell` (L28)

- `revision: number = 0;` (L30)
  Bumped on every change the component draws.

- `readonly button: CYLTagButton = new CYLTagButton();` (L32)
  The tag view. The cell handles touches, so the button ignores them.

- `appliedStyle?: CYLMenuStyle;` (L34)
  The list's style object last applied, so that a style is copied into the button only when it changes.

- `deleteHandler?: () => void;` (L36)
  Called when the delete indicator is tapped.

- `accessibilityLabel: string = '';` (L38)
  The cell's screen reader label (the tag's title).

- `accessibilityIdentifier: string = CYLTagListAccessibilityIdentifier.item;` (L41)
  The component id (`CYLTagListAccessibilityIdentifier`).

- `accessibilitySelected: boolean = false;` (L43)
  Whether the cell reads as selected.

- `rippleListener?: (ripple: CYLTagRipple) => void;` (L46)
  Set by the component to play ripples.

- `renameHandler?: () => void;` (L50)
  `renameHandler`: called when the rename indicator is tapped, and on a title tap while `renamesOnTitleTap`.

- `renamesOnTitleTap: boolean = false;` (L52)
  `renamesOnTitleTap`: a tap on the title (outside the editing icons) renames too. Needs `isRenamable`.

- `get isRenamable(): boolean` (L58)
  `isRenamable`: shows the rename indicator (an edit icon before the cross, `CYLTagButton.showsRenameIndicator`) and
  makes it tappable. Needs `isDeletable`. False by default.

- `get renameAccessibilityLabel(): string` (L69)
  The label of the rename indicator for screen readers ("Edit").

- `get renameTitleFrame(): CYLRect` (L74)
  The title's tap area while `renamesOnTitleTap`: the title, clear of the editing icons, 4 vp taller each way.

- `get isDeletable(): boolean` (L86)
  Shows the delete indicator and makes it tappable. False by default.

- `get deleteAccessibilityLabel(): string` (L97)
  The label of the delete indicator for screen readers.

- `get isHighlighted(): boolean` (L102)
  Pressed: `CYLMenuStyle.highlightedBackgroundColor`.

- `showRipple(point: CYLPoint): void` (L114)
  Plays `CYLMenuStyle`'s touch ripple (`rippleColor`) from `point`, in the tag's coordinates; a touch plays it
  too.

- `configure(title: string, image: CYLImage | undefined, selectedImage: CYLImage | undefined,` (L135)
  Shows a tag: its title (also its accessibility label), icons, look and state.

- `performTapAt(x: number, y: number): boolean` (L162)
  A tap at (`x`, `y`) in the cell: on the rename indicator (or the title while `renamesOnTitleTap`) it calls
  `renameHandler`, on the delete indicator `deleteHandler`; returns whether it did. The list takes every physical tap
  on an item in one gesture (ahead of the views inside it), so it asks the cell first.

- `prepareForReuse(): void` (L181)
  Clears what a reused cell must not keep (`prepareForReuse`).

- `export struct CYLTagListCellComponent` (L192)
  Draws a `CYLTagListCell`; `onCellClick` gets the taps outside the delete indicator.

## harmony/classifymenu/src/main/ets/tagviews/CYLTagView.ets

The TagCollectionView demo view (iOS CYLTagView.swift, Views/CYLTagCell.swift, Views/CYLTagHeaderCell.swift and
their XIBs; Android CYLTagView.kt): groups of `CYLTagModel` from a `CYLMenuDataSource`, each with a header whose
button opens the group or folds it to its first row, the tags in left-aligned rows.
`CYLTagView` holds the state and the API (as the iOS class, with its collection view data source and flow layout
methods); `CYLTagViewComponent` draws it.

- `const CONTENT_INSET_TOP: number = 35;` (L16)
  `collectionView.contentInset.top`.

- `const LINE_SPACING: number = 10;` (L18)
  `UICollectionViewFlowLayout.minimumLineSpacing`'s default.

- `const TAG_BACKGROUND: string = CYLColor.rgb(0, 0.47843137250000001, 1);` (L20)
  CYLTagCell.xib: the label's blue (0, 0.478, 1), white text, alpha 0.4.

- `const HEADER_BACKGROUND: string = CYLColor.rgb(0.93725490199999995, 0.93725490199999995, 0.95686274510000002);` (L25)
  CYLTagHeaderCell.xib: background (0.937, 0.937, 0.957), the name at 17 pt 22 from the leading edge, the button
  at 14 pt at the trailing and top layout margins (8).

- `export const CYLTagViewElementKindSectionHeader: string = 'UICollectionElementKindSectionHeader';` (L32)
  `UICollectionView.elementKindSectionHeader`.

- `export class CYLTagCell` (L35)
  A tag of `CYLTagView`: a capsule label with the model's title.

- `model?: CYLTagModel;` (L37)
  The tag shown.

- `frame: CYLRect = new CYLRect();` (L39)
  Where the cell is, in the view's content.

- `font: CYLFont = CYLTagModel.titleFont();` (L42)
  The title font for the text size the view measured with.

- `get accessibilityLabel(): string` (L45)
  The screen reader label: the title.

- `export interface CYLTagHeaderCellDelegate` (L51)
  Receives the taps on a group header's fold button.

- `tagHeaderCell(headerCell: CYLTagHeaderCell, section: number): void;` (L53)
  The group of `headerCell` (in `section`) was opened or folded; reload the list.

- `export class CYLTagHeaderCell` (L57)
  The header of a `CYLTagView` group: the group's name and a button that opens or folds it.

- `group?: CYLTagGroup;` (L59)
  The group shown.

- `delegate?: CYLTagHeaderCellDelegate;` (L61)
  Receives the taps on the fold button.

- `frame: CYLRect = new CYLRect();` (L63)
  Where the header is, in the view's content.

- `get buttonTitle(): string` (L66)
  The fold button's title: 收起 when the group is open, else 更多.

- `get buttonAccessibilityHint(): string` (L71)
  The fold button names the group it changes.

- `btnClick(): void` (L76)
  Handle group button taps: toggle the group, then let the delegate reload.

- `export class CYLTagView implements CYLTagHeaderCellDelegate` (L87)

- `static readonly sectionInset: CYLEdgeInsets = CYLTagViewSectionInset;` (L89)
  The insets of every group's tags.

- `static readonly cellSpacing: number = CYLTagViewCellSpacing;` (L91)
  The horizontal space between two tags of a row.

- `revision: number = 0;` (L94)
  Bumped on every change the component draws.

- `groups: CYLTagGroup[] = [];` (L96)
  All data groups (`CYLTagGroup`).

- `menuDataSource?: CYLMenuDataSource;` (L98)
  The groups and their tags.

- `menuDelegate?: CYLMenuDelegate;` (L100)
  Receives the taps on tags.

- `headers: CYLTagHeaderCell[] = [];` (L102)
  The laid out headers and cells, from `layout()`.

- `constructor()` (L110)
  `init()`: an empty view.

- `static makeTagView(): CYLTagView` (L114)
  `makeTagView()` (Objective-C `+tagView`).

- `get isShowHeader(): boolean` (L119)
  Whether each group shows its header (default true).

- `get fontScale(): number` (L129)
  The system font scale the tags are measured at (iOS: the content size category).

- `reloadMenuData(): void` (L147)
  Reads the groups and their tags from the data source again.

- `setWidth(width: number): void` (L171)
  The view's width, from the component (`layoutSubviews`).

- `numberOfVisibleItems(section: number): number` (L193)
  `numberOfVisibleItems(inSection:)`: the tags a section shows now (Android `numberOfVisibleItemsInSection`).

- `viewForSupplementaryElementOfKind(kind: string, indexPath: CYLIndexPath): CYLTagHeaderCell | undefined` (L214)
  The header of a section (`kind` `CYLTagViewElementKindSectionHeader`); undefined for another kind.

- `export struct CYLTagViewComponent` (L334)
  Draws a `CYLTagView` in a vertical scroll view.
