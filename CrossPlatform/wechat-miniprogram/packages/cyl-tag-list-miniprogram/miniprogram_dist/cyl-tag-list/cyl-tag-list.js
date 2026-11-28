/**
 * `cyl-tag-list`: the Mini Program port of the core's `CYLTagListView`, built from the same configuration dictionary
 * as `CYLTagListView(configuration:)`, the Flutter plugin and the React Native component (model.js). A Mini Program
 * cannot host the native iOS / Android view, so this component draws the list itself with the same rules.
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
  },

  data: {
    sections: [],
    foldPosition: 'none',
    foldContent: 'title',
    foldColor: '#808080',
    backgroundStyle: '',
  },

  lifetimes: {
    attached() {
      this.expanded = {};
      this.rebuild();
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
      this.model = model.normalize(this.data.configuration, { pixelRatio: pixelRatio() });
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
          style.interitemSpacing, style.lineSpacing, model.listTagHeight(m, style)).cellStyle;
        return {
          index: section.index,
          title: section.title,
          showsHeader: m.showsSectionHeaders && section.title !== '',
          canFold: fold.canFold,
          expanded,
          foldTitle: foldTitle(m.foldControl, expanded),
          tailStyle,
          ...layout,
          items: section.items.map((item, i) => {
            const selected = this.selection.includes(item.key);
            const state = model.stateOf(item, selected);
            const url = animations.url(item.animation, item.animationOptions, item.animationRestingProgress);
            const icon = model.animatedIcon({ ...item, ...animations.gifOptions(item.animation, item) }, state, style, url);
            const tag = model.tagLayout(style, item, state, { kind: icon.iconKind }, style.interitemSpacing, style.lineSpacing,
              model.listTagHeight(m, style));
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
        foldColor: m.foldControl.color || m.style.foldControlColor,
        backgroundStyle: `background-color: ${m.style.backgroundColor}`,
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
      const section = Number(event.currentTarget.dataset.section);
      this.expanded[section] = !this.expanded[section];
      this.render(false);
      this.reportFoldState();
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
