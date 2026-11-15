/**
 * `cyl-tag-list`: the Mini Program port of the core's `CYLTagListView`, built from the same configuration dictionary
 * as `CYLTagListView(configuration:)`, the Flutter plugin and the React Native component (model.js). A Mini Program
 * cannot host the native iOS / Android view, so this component draws the list itself with the same rules.
 *
 * Properties: `configuration`, `animationSpeed` (1 = each animation's own), `animationLoops`.
 * Methods (through `selectComponent`): `playAll()`, `selectedItems()`, `contentHeight()`.
 * Events: `tagtap` {section, item, title, selected}, `selectionchange` {keys, items: [{section, item, title}]},
 * `contentheightchange` {height}.
 */
const model = require('./model.js');

/**
 * Stand-ins for SF Symbols (`system:<name>`), which a Mini Program does not have, as the Android example ships
 * stand-in drawables.
 */
const SYSTEM_GLYPHS = {
  house: '🏠', magnifyingglass: '🔍', message: '💬', person: '👤', star: '⭐', gearshape: '⚙️',
  camera: '📷', 'music.note': '🎵', map: '🗺️', calendar: '📅',
};

/**
 * A tag's box: border-box, so the border lies inside the content insets as on iOS, and the width is the title, the
 * icon and the spacing plus the left and right insets (CYLTagButton.width(forTitle:iconSize:style:)).
 */
function cellStyle(style, selected) {
  const s = selected ? style.selected : style.normal;
  const border = s.borderWidth != null ? s.borderWidth : 1;
  const inset = style.contentInsets;
  return [
    `height: ${style.itemHeight}px`,
    `padding: 0 ${Math.max(0, inset.right - border)}px 0 ${Math.max(0, inset.left - border)}px`,
    `margin: 0 ${style.interitemSpacing}px ${style.lineSpacing}px 0`,
    `font-size: ${style.fontSize}px`,
    `border-radius: ${s.cornerRadius}px`,
    `border-width: ${border}px`,
    `border-color: ${s.borderColor}`,
    `color: ${s.textColor}`,
    `background-color: ${s.backgroundColor}`,
  ].join('; ');
}

/**
 * The list's padding (sectionInsets; the last line's spacing is taken off the bottom), the negative trailing margin
 * that absorbs the last tag's spacing, the header (headerHeight, headerFont) and the icon-title spacing.
 */
function layoutStyles(style) {
  const i = style.sectionInsets;
  return {
    listStyle: `padding: ${i.top}px ${i.right}px ${Math.max(0, i.bottom - style.lineSpacing)}px ${i.left}px`,
    itemsStyle: `margin-right: -${style.interitemSpacing}px`,
    headerStyle: `height: ${style.headerHeight}px; font-size: ${style.headerFontSize}px`,
    iconSpacing: style.imageTitleSpacing,
  };
}

Component({
  properties: {
    configuration: { type: Object, value: {}, observer: 'rebuild' },
    animationSpeed: { type: Number, value: 1 },
    animationLoops: { type: Boolean, value: false },
  },

  data: {
    sections: [],
    imageSize: 18,
    foldPosition: 'none',
    foldContent: 'title',
    tailStyle: '',
    listStyle: '',
    itemsStyle: '',
    headerStyle: '',
    iconSpacing: 4,
    glyphSize: 13,
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
      this.model = model.normalize(this.data.configuration);
      this.selection = this.model.selectedItems.slice();
      this.rows = null;
      this.expanded = this.expanded || {};
      this.render(true);
    },

    /** Builds the view data; with `remeasure`, shows every item and measures the rows again. */
    render(remeasure) {
      const m = this.model;
      const sections = m.sections.map((section) => {
        const rows = this.rows && this.rows[section.index];
        const expanded = !!this.expanded[section.index];
        const fold = rows && !remeasure ? model.foldState(m, rows, expanded) : { canFold: false, visible: [] };
        return {
          index: section.index,
          title: section.title,
          canFold: fold.canFold,
          expanded,
          foldTitle: model.foldTitle(expanded),
          items: section.items.map((item, i) => {
            const selected = this.selection.includes(item.key);
            const system = /^system:(.+)$/.exec(item.image);
            return {
              key: item.key,
              title: item.title,
              animation: item.animation,
              glyph: system ? (SYSTEM_GLYPHS[system[1]] || '•') : '',
              image: system ? '' : item.image,
              enabled: item.enabled,
              selected,
              hidden: fold.visible.length ? !fold.visible[i] : false,
              style: cellStyle(m.style, selected),
            };
          }),
        };
      });
      this.setData({
        sections,
        imageSize: m.style.imageSize,
        // An emoji is about 1.35 times as wide as its font size; this keeps it inside the icon slot.
        glyphSize: Math.floor(m.style.imageSize * 0.74),
        foldPosition: m.foldControl.position,
        foldContent: m.foldControl.content,
        tailStyle: cellStyle(m.style, false),
        ...layoutStyles(m.style),
      }, () => {
        if (remeasure) this.measure();
        else this.reportHeight();
      });
    },

    /** Measures the top of every item to find the rows, then folds the sections that need more rows. */
    measure() {
      if (this.model.defaultVisibleRows <= 0) {
        this.reportHeight();
        return;
      }
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
      const result = model.tap(this.model, this.selection, k);
      if (result.selected && item.animation) {
        // A tapped tag plays its animated icon, as a tapped tab does (the core's handleTap).
        const icon = this.selectComponent(`#lottie-${k}`);
        if (icon) icon.play();
      }
      if (result.changed) {
        this.selection = result.selectedItems;
        this.render(false);
      }
      this.triggerEvent('tagtap', { section: item.section, item: item.item, title: item.title, selected: result.selected });
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

    /** Restarts every animated icon on the list from progress 0 (Play all). */
    playAll() {
      this.model.sections.forEach((section) => section.items.forEach((item) => {
        if (!item.animation) return;
        const icon = this.selectComponent(`#lottie-${item.key}`);
        if (icon) icon.play();
      }));
    },
  },
});
