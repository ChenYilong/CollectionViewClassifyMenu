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
 * Animated icons (Lottie, GIF) come from cyl-lottie-icon; PAG and Rive engines are not linked (animations.js).
 */
const model = require('./model.js');
const animations = require('./animations.js');
const i18n = require('../../utils/i18n.js');

/** The core's localized fold titles (CYLMenuExpand / CYLMenuCollapse) when the string tables have them. */
function foldTitle(control, expanded) {
  if (expanded && control.collapseTitle) return control.collapseTitle;
  if (!expanded && control.title) return control.title;
  if (typeof i18n.tc === 'function') {
    const k = expanded ? 'CYLMenuCollapse' : 'CYLMenuExpand';
    const text = i18n.tc(k);
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
    animationSpeed: { type: Number, value: 0 },
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
      const sections = m.sections.map((section) => {
        const style = section.style;
        const rows = this.rows && this.rows[section.index];
        const expanded = !!this.expanded[section.index];
        const fold = rows && !remeasure ? model.foldState(m, rows, expanded) : { canFold: false, visible: [] };
        const layout = model.sectionLayout(style);
        const tailStyle = model.tagLayout(style, { title: 'x', enabled: true }, 'normal', { kind: 'none' },
          style.interitemSpacing, style.lineSpacing).cellStyle;
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
            const resolved = animations.resolve(item.animation);
            const icon = model.iconContent(item, state, style, resolved);
            const tag = model.tagLayout(style, item, state, icon, style.interitemSpacing, style.lineSpacing);
            return {
              key: item.key,
              title: item.title,
              animation: resolved ? item.animation : '',
              resting: item.animationRestingProgress,
              styleSpeed: style.animationSpeed,
              iconKind: icon.kind,
              iconSrc: icon.src,
              glyph: icon.glyph,
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
      });
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

    /** Plays the animated icons of these items from progress 0 (`CYLTagButton.playAnimation()`). */
    playItems(keys) {
      (keys || []).forEach((k) => {
        const icon = this.selectComponent(`#anim-${k}`);
        if (icon) icon.play();
      });
    },

    /** Restarts every animated icon on the list from progress 0 (Play all, `playAllAnimations()`). */
    playAll() {
      this.playItems(this.model.sections.flatMap((section) => section.items.map((item) => item.key)));
    },
  },
});
