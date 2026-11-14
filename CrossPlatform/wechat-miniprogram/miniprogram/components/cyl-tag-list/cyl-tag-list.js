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

function cellStyle(style, selected) {
  const s = selected ? style.selected : style.normal;
  return [
    `height: ${style.itemHeight}px`,
    `border-radius: ${s.cornerRadius}px`,
    `border-width: ${s.borderWidth != null ? s.borderWidth : 1}px`,
    `border-color: ${s.borderColor}`,
    `color: ${s.textColor}`,
    `background-color: ${s.backgroundColor}`,
  ].join('; ');
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
        foldPosition: m.foldControl.position,
        foldContent: m.foldControl.content,
        tailStyle: cellStyle(m.style, false),
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
      query.exec((results) => {
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
