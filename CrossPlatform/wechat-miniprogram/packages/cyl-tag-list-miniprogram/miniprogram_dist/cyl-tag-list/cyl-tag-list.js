/**
 * `cyl-tag-list`: the Mini Program port of the core's `CYLTagListView`, built from the same configuration dictionary
 * as `CYLTagListView(configuration:)`, the Flutter plugin and the React Native component (model.js). A Mini Program
 * cannot host the native iOS / Android view, so this component draws the list itself with the same rules.
 *
 * Long press (docs/tag-long-press-action.md): the configuration's `longPressAction` ("callout", "report", "none", "reorder",
 * or an array: the first that can begin wins; this list does not reorder, cyl-tag-cloud does) or the property
 * `longPressAction` decides what a long press on an item does: a callout with the item's `subtitle` (a small bubble with an
 * arrow), or only the event `taglongpress` {section, item, title, subtitle}, which every long press sends (except "none").
 * A tap, a fold, a rebuild or another long press hides the callout; `dismissCallout()` does too. WeChat sends no tap for the
 * release of a long press.
 *
 * Properties: `configuration`, `animationSpeed` (0, the default, uses each section's `style.animationSpeed`; above 0
 * overrides it, as `CYLTagListView.animationSpeed`), `animationLoops`.
 * Methods (through `selectComponent`): `playAll()`, `playItems(keys)`, `selectedItems()`, `contentHeight()`,
 * `cellMetrics()`.
 * Events: `tagtap` {section, item, title, selected, sectionTitle}, `selectionchange` {keys, items: [{section, item,
 * title}]}, `contentheightchange` {height}.
 * Every icon is drawn by CYLTabBarController's cyl-animated-item (../cyl-animated-item, vendored by commit). Animations
 * play in the engine components the app gives as the abstract nodes `cyl-lottie-view`, `cyl-pag-view`, `cyl-rive-view`
 * and `cyl-svga-view` (generic:cyl-lottie-view="…"; forwarded to cyl-animated-item), with the files the app registers
 * with animations.js `configure()`; a GIF is drawn by `<image>`. Without an engine a tag shows its symbol or image.
 */
const model = require('./model.js');
const animations = require('./animations.js');
const locale = require('../locale.js');
const theme = require('./theme.js');

/** The core's localized fold titles (CYLMenuExpand / CYLMenuCollapse) when the string tables have them. */
function foldTitle(control, expanded) {
  if (expanded && control.collapseTitle) return control.collapseTitle;
  if (!expanded && control.title) return control.title;
  if (typeof locale.tc === 'function') {
    const k = expanded ? 'CYLMenuCollapse' : 'CYLMenuExpand';
    const text = locale.tc(k);
    if (text && text !== k) return text;
  }
  return model.foldTitle(expanded);
}

function pixelRatio() {
  try {
    return (wx.getWindowInfo ? wx.getWindowInfo() : wx.getSystemInfoSync()).pixelRatio || 2;
  } catch (error) {
    return 2;
  }
}

Component({
  properties: {
    configuration: { type: Object, value: {}, observer: 'rebuild' },
    // Any type, not Number: a page whose speed is not set yet (`{{controls.speed}}` of an empty object) passes undefined,
    // which a Number property reports as a type warning; anything not above 0 uses the style's speed anyway.
    animationSpeed: { type: null, value: 0 },
    animationLoops: { type: Boolean, value: false },
    // What a long press does (a name or an array of names); null: the configuration's `longPressAction`, else a report.
    longPressAction: { type: null, value: null },
  },

  data: {
    sections: [],
    foldPosition: 'none',
    foldContent: 'title',
    foldColor: '#808080',
    backgroundStyle: '',
    // Right to left (style key `direction`): the list's CSS direction is in backgroundStyle, this selects the mirrored wxss rules.
    rtl: false,
    // The fold / More control's capped font size (header and footer controls).
    foldFontStyle: '',
    // The long-press callout {text, left, top, arrow, below}, or null.
    callout: null,
  },

  lifetimes: {
    attached() {
      this.expanded = {};
      this.rebuild();
      // The defaults follow dark mode: build again when the system theme changes.
      this.stopThemeChanges = theme.onChange(() => this.rebuild());
    },
    detached() {
      if (this.stopThemeChanges) this.stopThemeChanges();
    },
  },

  pageLifetimes: {
    resize() {
      this.rows = null;
      if (this.model) this.render(true);
    },
  },

  methods: {
    rebuild() {
      this.dismissCallout();
      this.model = model.normalize(this.data.configuration, { pixelRatio: pixelRatio(), dark: theme.isDark() });
      this.selection = this.model.selectedItems.slice();
      this.rows = null;
      this.expanded = this.expanded || {};
      this.render(true);
    },

    /** Builds the view data; with `remeasure`, shows every item and measures the rows again. */
    render(remeasure) {
      const m = this.model;
      this.itemPaths = {};
      const sections = m.sections.map((section, sectionPosition) => {
        const style = section.style;
        const rows = this.rows && this.rows[section.index];
        const expanded = !!this.expanded[section.index];
        const fold = rows && !remeasure ? model.foldState(m, rows, expanded) : { canFold: false, visible: [] };
        const layout = model.sectionLayout(style);
        const tailStyle = model.tagLayout(style, { title: 'x', enabled: true }, 'normal', { kind: 'none' },
          style.interitemSpacing, style.lineSpacing).cellStyle
          // The More tag follows the tag's font size, capped (the system font size scales the text up).
          + `; ${model.foldControlFontCSS(style.normal.font.size)}`;
        return {
          index: section.index,
          title: section.title,
          showsHeader: m.showsSectionHeaders && section.title !== '',
          canFold: fold.canFold,
          expanded,
          foldTitle: foldTitle(m.foldControl, expanded),
          // The longer of the two titles: a hidden sizer in the "titleAndIcon" control, so it keeps its width when toggled.
          foldSizerTitle: model.longerFoldTitle(foldTitle(m.foldControl, false), foldTitle(m.foldControl, true)),
          tailStyle,
          ...layout,
          items: section.items.map((item, i) => {
            const selected = this.selection.includes(item.key);
            const state = model.stateOf(item, selected);
            const url = animations.url(item.animation, item.animationOptions, item.animationRestingProgress);
            const icon = model.animatedIcon({ ...item, ...animations.gifOptions(item.animation, item) }, state, style, url);
            const tag = model.tagLayout(style, item, state, { kind: icon.iconKind }, style.interitemSpacing, style.lineSpacing);
            this.itemPaths[item.key] = `sections[${sectionPosition}].items[${i}]`;
            return {
              key: item.key,
              title: item.title,
              styleSpeed: style.animationSpeed,
              ...icon,
              enabled: item.enabled,
              selected,
              hidden: fold.visible.length ? !fold.visible[i] : false,
              sizers: model.sizerFonts(style, state),
              ...tag,
            };
          }),
        };
      });
      this.setData({
        sections,
        foldPosition: m.foldControl.position,
        foldContent: m.foldControl.content,
        foldColor: m.foldControl.color || model.resolvedFoldControlColor(m.style, m.foldControl.position === 'headerTrailing'),
        backgroundStyle: `background-color: ${model.resolvedBackgroundColor(m.style)}${model.directionCSS(m.style)}`,
        rtl: model.isRtl(m.style),
        foldFontStyle: model.foldControlFontCSS(),
        foldHeaderStyle: model.foldHeaderWidthCSS(),
      }, () => {
        if (remeasure) this.measure();
        else this.reportHeight();
      });
    },

    /** Measures the top of every item to find the rows, then folds the sections that need more rows. */
    measure() {
      const query = this.createSelectorQuery();
      this.model.sections.forEach((section) => {
        query.selectAll(`.cyl-item-s${section.index}`).boundingClientRect();
      });
      // Every tag's title, in the same order (the fold control is not shown while measuring).
      query.selectAll('.cyl-title').boundingClientRect();
      query.exec((results) => {
        const titles = results.pop() || [];
        const cells = results.flat();
        this.metrics = cells.map((cell, i) => ({ cell, title: titles[i] }));
        if (this.model.defaultVisibleRows <= 0) {
          this.reportHeight();
          return;
        }
        this.rows = results.map((rects) => model.rowsFromTops((rects || []).map((r) => r.top)));
        this.render(false);
        this.reportFoldState();
      });
    },

    /**
     * `foldchange` {sections: [{section, canFold, expanded}]} after a measurement or a fold change, so a page knows
     * whether a section folds (the core's fold state) without reading the component's data.
     */
    reportFoldState() {
      if (!this.rows) return;
      const sections = this.model.sections.map((section) => ({
        section: section.index,
        canFold: model.foldState(this.model, this.rows[section.index] || [], false).canFold,
        expanded: !!this.expanded[section.index],
      }));
      this.triggerEvent('foldchange', { sections });
    },

    /** Expands or folds a section, as a tap on its fold control (the core's `setExpanded(_:forSection:animated:)`). */
    setExpanded(section, expanded) {
      if (!!this.expanded[section] === !!expanded) return;
      this.expanded[section] = !!expanded;
      this.render(false);
      this.reportFoldState();
    },

    isSectionExpanded(section) {
      return !!this.expanded[section];
    },

    /**
     * Selects exactly `keys` ("<section>-<item>") without rebuilding or measuring again (the core's selection from
     * code: `selectItem(at:)` / `selectedIndexPaths`); no event is sent, as on iOS.
     */
    setSelectedItems(keys) {
      this.selection = model.sanitizeSelection(keys || [], this.model.sections);
      this.render(false);
    },

    reportHeight() {
      this.createSelectorQuery().select('.cyl-tag-list').boundingClientRect().exec(([rect]) => {
        if (!rect) return;
        this.height = rect.height;
        this.triggerEvent('contentheightchange', { height: rect.height });
      });
    },

    onItemTap(event) {
      this.dismissCallout();
      const k = event.currentTarget.dataset.key;
      const item = model.itemAt(this.model, k);
      if (!item || !item.enabled) return;
      const result = model.tap(this.model, this.selection, k);
      if (result.changed) {
        this.selection = result.selectedItems;
        this.render(false);
      }
      if (result.selected) {
        // A tapped tag plays its animated icon, as a tapped tab does (the core's handleTap), after its state is set.
        wx.nextTick(() => this.playItems([k]));
      }
      const section = this.model.sections[item.section];
      this.triggerEvent('tagtap', {
        section: item.section, item: item.item, title: item.title, selected: result.selected, sectionTitle: section.title,
      });
      if (result.changed) this.triggerEvent('selectionchange', this.selectionPayload());
    },

    onFoldTap(event) {
      this.dismissCallout();
      const section = Number(event.currentTarget.dataset.section);
      this.expanded[section] = !this.expanded[section];
      this.render(false);
      this.reportFoldState();
    },

    /** Hides the long-press callout. */
    dismissCallout() {
      if (this.data.callout) this.setData({ callout: null });
    },

    /** A long press on an item: the first action of `longPressAction` that can begin decides (model.longPressDecision). */
    onItemLongPress(event) {
      const k = event.currentTarget.dataset.key;
      const item = model.itemAt(this.model, k);
      if (!item) return;
      const own = this.data.longPressAction;
      const actions = own ? model.longPressActions(own) : this.model.longPressActions;
      const decision = model.longPressDecision(actions, item.subtitle.length > 0);
      this.dismissCallout();
      if (decision === 'none') return;
      if (decision === 'callout') this.showCallout(item);
      this.triggerEvent('taglongpress', { section: item.section, item: item.item, title: item.title, subtitle: item.subtitle });
    },

    /** Shows the callout above the item (below when there is no room), its arrow at the item's center. */
    showCallout(item) {
      const query = this.createSelectorQuery();
      query.select(`#cyl-item-${item.key}`).boundingClientRect();
      query.select('.cyl-tag-list').boundingClientRect();
      query.exec(([itemRect, listRect]) => {
        if (!itemRect || !listRect) return;
        const center = itemRect.left - listRect.left + itemRect.width / 2;
        // The bubble is at most 240 wide; keep it inside the list and point the arrow at the item.
        const width = Math.min(240, Math.max(60, item.subtitle.length * 13 * 0.9 + 24));
        const left = Math.max(8, Math.min(listRect.width - 8 - width, center - width / 2));
        const below = itemRect.top < 60;
        this.setData({
          callout: {
            text: item.subtitle,
            left,
            top: below ? itemRect.bottom - listRect.top : itemRect.top - listRect.top,
            arrow: Math.max(14, Math.min(width - 14, center - left)),
            below,
          },
        });
      });
    },

    selectionPayload() {
      return {
        keys: this.selection.slice(),
        items: this.selection.map((k) => {
          const item = model.itemAt(this.model, k);
          return { section: item.section, item: item.item, title: item.title };
        }),
      };
    },

    /** Every selected item's key ("<section>-<item>"). */
    selectedItems() {
      return this.selection.slice();
    },

    contentHeight() {
      return this.height || 0;
    },

    /**
     * The tag and title frames of the last measurement (every tag shown), for layout checks against the core:
     * [{key, title, width, height, titleWidth, left, right}], left and right being the title's distance to the tag's edges.
     */
    cellMetrics() {
      const keys = this.model.sections.flatMap((section) => section.items.map((item) => [item.key, item.title]));
      return (this.metrics || []).map(({ cell, title }, i) => ({
        key: keys[i] && keys[i][0],
        title: keys[i] && keys[i][1],
        width: cell.width,
        height: cell.height,
        titleWidth: title ? title.width : 0,
        left: title ? title.left - cell.left : 0,
        right: title ? cell.right - title.right : 0,
      }));
    },

    /**
     * Plays the animated icons of these items from progress 0 (`CYLTagButton.playAnimation()`), through each item's
     * cyl-animated-item `playAnimation()`: the engine from progress 0, a GIF from its first frame (one pass of
     * `gifDuration` ms when the tag has stills), a file still loading once it is ready.
     */
    playItems(keys) {
      (keys || []).forEach((k) => {
        const item = this.selectComponent(`#anim-${k}`);
        const url = item && item.data && item.data.animationUrl;
        if (!url) return;
        // cyl-animated-item plays it: the engine from progress 0, a GIF again from its first frame (one pass with stills),
        // a file still loading once it is ready.
        if (typeof item.playAnimation === 'function') item.playAnimation();
      });
    },

    /** Restarts every animated icon on the list from progress 0 (Play all, `playAllAnimations()`). */
    playAll() {
      this.playItems(this.model.sections.flatMap((section) => section.items.map((item) => item.key)));
    },
  },
});
