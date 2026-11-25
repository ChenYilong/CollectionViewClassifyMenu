/**
 * `cyl-tag-list`: the Mini Program port of the core's `CYLTagListView`. As on iOS, Android and HarmonyOS, one view has
 * two ways to be filled:
 *
 * - Sections: the configuration dictionary of `CYLTagListView(configuration:)`, the Flutter plugin and the React Native
 *   component (model.js), drawn with `tagLayout` and CYLTabBarController's cyl-animated-item icons.
 * - Flat tags: the `tags` property and the tag methods (`addTag(_:)`, `setTags`, editing, renaming, deleting, dragging,
 *   the word picker, the cache), the core's CYLTagListView filled the android-tagview way, also with the AndroidTagView
 *   TagContainerLayout options (tag-model.js). The flat tags are one section of the list (section 0, keys "0-<index>"):
 *   used when the configuration has no `sections`.
 *
 * A Mini Program cannot host the native iOS / Android view, so this component draws the list itself with the same rules.
 *
 * Long press (docs/tag-long-press-action.md): the configuration's `longPressAction` ("callout", "report", "none", "reorder",
 * or an array: the first that can begin wins) or the property `longPressAction` decides what a long press on an item does:
 * a callout with the item's `subtitle` (a small bubble with an arrow), a drag that reorders (flat tags only, with
 * `allowsReordering` or while editing; the default of flat tags is ["reorder", "report"], the documented default), or only
 * the event `taglongpress`, which every long press sends (except "none"; a drag only when it did not move). A tap, a fold, a
 * rebuild or another long press hides the callout; `dismissCallout()` does too. WeChat sends no tap for the release of a
 * long press.
 *
 * Sections. Properties: `configuration`, `animationSpeed` (0, the default, uses each section's `style.animationSpeed`;
 * above 0 overrides it, as `CYLTagListView.animationSpeed`), `animationLoops`, `longPressAction`.
 * Methods (through `selectComponent`): `playAll()`, `playItems(keys)`, `selectedItems()`, `setSelectedItems(keys)`,
 * `setExpanded(section, expanded)`, `isSectionExpanded(section)`, `contentHeight()`, `cellMetrics()`, `dismissCallout()`.
 * Events: `tagtap` {section, item, title, selected, sectionTitle}, `taglongpress` {section, item, title, subtitle},
 * `selectionchange` {keys, items: [{section, item, title}]}, `foldchange` {sections}, `contentheightchange` {height}.
 * Every icon is drawn by CYLTabBarController's cyl-animated-item (../cyl-animated-item, vendored by commit). Animations
 * play in the engine components the app gives as the abstract nodes `cyl-lottie-view`, `cyl-pag-view`, `cyl-rive-view`
 * and `cyl-svga-view` (generic:cyl-lottie-view="…"; forwarded to cyl-animated-item), with the files the app registers
 * with animations.js `configure()`; a GIF is drawn by `<image>`. Without an engine a tag shows its symbol or image.
 *
 * Flat tags. One section of tags laid out in rows (flex wrap: the rows of `CYLCollectionViewLeftAlignedLayout`, aligned
 * by `rowAlignment`). Properties: `tags` (CYLTag objects, tag-model.makeTag; a tag's `subtitle` is its callout text),
 * `listStyle` (a tag-model style: defaultStyle(), tagCloudStyle(), tagContainerStyle(), wordPickerStyle()), `colorTheme`,
 * `allowsTapping`, `removesItemsOnDelete`, `allowsReordering`, `selectionMode`, `allowsEmptySelection`,
 * `defaultTagImage`, `containerBorderWidth` / `Color` / `CornerRadius`, `showsSectionHeaders` + `sectionTitle`.
 * Setting `tags` replaces the tags (`replaceTags`); the methods below change them as the core's do. `selectedItems()` and
 * `setSelectedItems(keys)` use the keys "0-<index>".
 *
 * Events of flat tags (the core's handlers): `tagtap` {position, tag} (tagClickHandler), `tagdelete` {position, tag}
 * (tagDeleteHandler, after the tag was removed unless `removesItemsOnDelete` is false), `taglongpress` {position, tag}
 * (tagLongPressHandler), `tagmove` {from, to} (tagMoveHandler), `selectedtagdrag` {position, tag}
 * (selectedTagDragHandler), `reorderingchange` {reordering}, `contentchange` after the tags changed.
 *
 * Editing mode (iOS `CYLTagListView.setEditing(_:animated:)`): `editing` (or `setEditing(true)`) shows every enabled
 * tag's delete indicator, lets tags be dragged, makes a tap report (`tagtap`) without changing the selection, and shows
 * the add control below the tags (`showsAddItemViewWhileEditing`); `editingchange` {editing} follows, and a submitted
 * name is `requestnewitem` {name, position} (the host adds it, as iOS's `menu(_:didRequestNewItemWithName:at:)`).
 * With `cachePolicy` ('database', 'userDefaults', 'sandboxFile'; 'none' by default) and `cacheName`, the titles are
 * saved after each edit while editing (`cachedTitles()` reads them back, `saveToCache()` saves now; cache.js).
 *
 * Network sync (iOS 3fc2c23b): leaving editing sends `editingfinish` {titles} (the edited titles by cache key, "0",
 * already saved) for the host to upload; `setRemoteSource(source)` (an object with `fetchSectionsWithKeys(keys,
 * callback(sections, error))`) and `loadPolicy` ('cacheThenNetwork' by default, 'cacheFirst', 'networkFirst') drive
 * `loadSections(keys, completion(sections, origin))`; downloads are saved to the cache first.
 *
 * Renaming (iOS 990cf115): with `supportsRenamingItems`, every enabled tag shows an edit icon before its cross while
 * editing; a tap on it (or on the title, `renamesOnTitleTapWhileEditing`) starts renaming (`beginRenaming(position)`):
 * the add field shows the title and its submit renames the tag, then `tagrename` {position, title, tag}; or a host's
 * editor set with `setRenameRequestHandler(fn(position, title))` gets it, finishing with `finishRenaming(title)` or
 * `cancelRenaming()`. A tag's id (`identifier`, else its title) is kept by reordering and renaming: `cachedItems()`,
 * `editableSectionItems()`, `editingfinish` {titles, items} and `loadItems(keys, completion(items, origin))` (with the
 * remote source's `fetchItemsWithKeys`). `showsClearButton` puts a trash button in the header: `clearbuttontap`
 * {section: 0}.
 *
 * Folding (iOS `defaultVisibleRows` + `CYLMenuFoldControl` tail): with `defaultVisibleRows` > 0 the tags show that
 * many rows with a fold control (a chevron, `foldControlContent` 'icon' / 'title' / 'titleAndIcon') as the last tag;
 * a tap on it (or `setExpanded(true)`) shows every tag, the control then folding them again; `foldchange` {canFold,
 * expanded}. Editing shows every tag, as iOS.
 *
 * Word picker (iOS 选词填入): `setTagsWithCharactersOfText(text)` (one tag per character, keeps `selectionMode`),
 * `selectedText()`, `selectItemsFrom(start, end)`, and `allowsSmearSelection`: a drag that starts on a tag selects every
 * tag from it to the one under the finger (or deselects them when it started on a selected one); a tap still toggles;
 * `selectionchange` {positions}; `smearingchange` {smearing} when a smear starts and ends, so a host holds its
 * <scroll-view> meanwhile (catching touchmove alone does not stop native scrolling). Needs `selectionMode` 'multiple';
 * `tagModel.wordPickerStyle()` is the matching look.
 */
const model = require('./model.js');
const tagModel = require('./tag-model.js');
const animations = require('./animations.js');
const locale = require('../locale.js');
const theme = require('./theme.js');
const { coreString } = require('../core-strings.js');
const { CYLTagListStore, loadSections, loadItems } = require('./cache.js');
const { iconImage } = require('./editing-icons.js');

/** The section the flat tags are: their keys are "0-<index>", as `selectedItems` on every platform. */
const TAGS_SECTION = 0;

/**
 * `reorderingchange` and `smearingchange` bubble and cross component boundaries, so a container that is an ancestor in
 * the host's template (through a slot), such as a page's single scroller, hears when a drag or a smear starts and ends
 * and turns its own scrolling off meanwhile.
 */
const GESTURE_EVENT = { bubbles: true, composed: true };

/** How far a press moves before it counts as a drag rather than a long press (`dragThreshold`). */
const DRAG_THRESHOLD = 8;

let nextKey = 1;

function keyed(tag) {
  return { ...tag, _key: nextKey++ };
}

function publicTag(tag) {
  const copy = { ...tag };
  delete copy._key;
  return copy;
}

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
    // What a long press does (a name or an array of names); null: the configuration's `longPressAction`, else a report
    // (flat tags: a drag where they reorder, else a report).
    longPressAction: { type: null, value: null },
    // Flat tags (used when the configuration has no `sections`).
    tags: { type: Array, value: [] },
    listStyle: { type: Object, value: null },
    colorTheme: { type: String, value: 'none' },
    allowsTapping: { type: Boolean, value: true },
    removesItemsOnDelete: { type: Boolean, value: true },
    allowsReordering: { type: Boolean, value: false },
    selectionMode: { type: String, value: 'none' },
    allowsEmptySelection: { type: Boolean, value: true },
    defaultTagImage: { type: String, value: '' },
    containerBorderWidth: { type: Number, value: 0 },
    containerBorderColor: { type: String, value: '' },
    containerCornerRadius: { type: Number, value: 0 },
    showsSectionHeaders: { type: Boolean, value: false },
    sectionTitle: { type: String, value: '' },
    editing: { type: Boolean, value: false },
    showsAddItemViewWhileEditing: { type: Boolean, value: true },
    cachePolicy: { type: String, value: 'none' },
    cacheName: { type: String, value: 'CYLTagListView' },
    loadPolicy: { type: String, value: 'cacheThenNetwork' },
    supportsRenamingItems: { type: Boolean, value: false },
    renamesOnTitleTapWhileEditing: { type: Boolean, value: true },
    showsClearButton: { type: Boolean, value: false },
    defaultVisibleRows: { type: Number, value: 0 },
    allowsSmearSelection: { type: Boolean, value: false },
    // While the tags are editing, and during a drag, the tags catch touchmove (`scrollLocked`). In WeChat's render layer
    // a catch binding only stops the event from bubbling: it does NOT stop native scrolling (a fast swipe on a tag still
    // scrolls, which is wanted). The only real lock is the HOST's: put the list in a <scroll-view> (not a page that
    // scrolls: a page with `min-height: 100vh` and taller content is itself the scroller, and nothing holds it) and set
    // its scroll-y to false on `reorderingchange` {reordering: true} (and `smearingchange` {smearing: true} for the word
    // picker), back on false; give the page `"disableScroll": true`. On by default.
    disablesScrollingWhileReordering: { type: Boolean, value: true },
    foldControlContent: { type: String, value: 'icon' },
    foldControlColor: { type: String, value: '' },
  },

  data: {
    sections: [],
    foldPosition: 'none',
    foldContent: 'title',
    foldColor: '#808080',
    backgroundStyle: '',
    // The long-press callout {text, left, top, arrow, below}, or null.
    callout: null,
    // Flat tags: shown instead of the sections.
    flat: false,
    items: [],
    list: {},
    ripples: {},
    deleteLabel: '',
    isEditing: false,
    // A drag is in progress and scrolling is held (`disablesScrollingWhileReordering`).
    scrollLocked: false,
    showsAddItem: false,
    addText: '',
    addPlaceholder: '',
    addTitle: '',
    renameLabel: '',
    clearLabel: '',
    clearImage: '',
    clearStyle: '',
    renamingIndex: -1,
    canFold: false,
    expanded: false,
    foldTitle: '',
    foldStyle: '',
    tagsFoldContent: 'icon',
  },

  observers: {
    tags(tags) {
      this._tagsSet = true;
      this._tags = (tags || []).map(keyed);
      this._selection = [];
      this._render(true);
    },
    'listStyle, colorTheme, defaultTagImage, containerBorderWidth, containerBorderColor, containerCornerRadius'() {
      this._render(false);
    },
    editing(value) {
      this.setEditing(value);
    },
    'cachePolicy, cacheName'(policy, name) {
      this._cache = CYLTagListStore.cache(policy, name);
    },
    showsAddItemViewWhileEditing() {
      this._updateAddItem();
    },
    'supportsRenamingItems, renamesOnTitleTapWhileEditing'() {
      this._render(false);
    },
    'showsClearButton, sectionTitle'() {
      this._updateClearButton();
    },
    'defaultVisibleRows, foldControlContent, foldControlColor'() {
      this._render(false);
      this._measureFold();
    },
  },

  lifetimes: {
    created() {
      this._initTags();
    },
    attached() {
      this.expanded = {};
      if (!this._tags) this._initTags();
      this.setData({
        deleteLabel: coreString('CYLMenuDeleteTag'),
        addPlaceholder: locale.tc('CYLMenuAddTagPlaceholder'),
        addTitle: locale.tc('CYLMenuAddTag'),
        renameLabel: locale.tc('CYLMenuRenameTag'),
      });
      this._updateClearButton();
      this._cache = CYLTagListStore.cache(this.data.cachePolicy, this.data.cacheName);
      // The initial tags, when the observer has not run for them.
      if (!this._tagsSet) this._tags = (this.data.tags || []).map(keyed);
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
      if (this._usesTags()) return;
      this.rows = null;
      if (this.model) this.render(true);
    },
  },

  methods: {
    /** Whether the list shows the flat tags: its configuration has no `sections`. */
    _usesTags() {
      const configuration = this.data.configuration;
      return !(configuration && Array.isArray(configuration.sections));
    },

    _initTags() {
      this._tags = [];
      this._selection = [];
      this._pressed = -1;
      this._dragging = null;
      this._rippleId = 1;
      this._editing = false;
      this._cache = null;
      this._remoteSource = null;
      this._renaming = -1;
      this._renameRequestHandler = null;
      this._expanded = false;
      this._fold = { canFold: false, visible: [] };
    },

    rebuild() {
      this.dismissCallout();
      if (this._usesTags()) {
        this._render(false);
        return;
      }
      if (this.data.flat) this.setData({ flat: false, items: [] });
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

    /**
     * Expands or folds a section, as a tap on its fold control (the core's `setExpanded(_:forSection:animated:)`).
     * Flat tags: `setExpanded(expanded)` (or `setExpanded(0, expanded)`) shows every tag, or folds them to
     * `defaultVisibleRows` again.
     */
    setExpanded(section, expanded) {
      if (this._usesTags()) {
        this._setTagsExpanded(arguments.length < 2 ? section : expanded);
        return;
      }
      if (!!this.expanded[section] === !!expanded) return;
      this.expanded[section] = !!expanded;
      this.render(false);
      this.reportFoldState();
    },

    isSectionExpanded(section) {
      if (this._usesTags()) return this._expanded;
      return !!this.expanded[section];
    },

    /**
     * Selects exactly `keys` ("<section>-<item>") without rebuilding or measuring again (the core's selection from
     * code: `selectItem(at:)` / `selectedIndexPaths`); no event is sent, as on iOS. Flat tags: the keys "0-<index>".
     */
    setSelectedItems(keys) {
      if (this._usesTags()) {
        const sections = [{ items: this._tags }];
        this._selection = model.sanitizeSelection(keys || [], sections).map((k) => model.parseKey(k).item);
        this._render(false);
        return;
      }
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
      if (this._usesTags()) {
        this._setTagsExpanded(!this._expanded);
        return;
      }
      const section = Number(event.currentTarget.dataset.section);
      this.expanded[section] = !this.expanded[section];
      this.render(false);
      this.reportFoldState();
    },

    /** Hides the long-press callout. */
    dismissCallout() {
      if (this.data.callout) this.setData({ callout: null });
    },

    /**
     * A long press on an item, of a section or a flat tag: the first action of `longPressAction` that can begin decides
     * (model.longPressDecision). "reorder" begins a drag of a flat tag (`_reorderBegin`; the touches then drive
     * `_reorderChanged`, `_reorderEnd` and `_reorderCancel`).
     */
    onItemLongPress(event) {
      const flat = this._usesTags();
      const item = flat ? this._tagItem(this._index(event)) : model.itemAt(this.model, event.currentTarget.dataset.key);
      if (!item) return;
      const own = this.data.longPressAction;
      let actions = own ? model.longPressActions(own) : null;
      if (!own) actions = flat ? model.longPressActions(model.LONG_PRESS_ACTION.reorder) : this.model.longPressActions;
      const decision = model.longPressDecision(actions, item.subtitle.length > 0, flat && this._canReorder());
      this.dismissCallout();
      if (decision === model.LONG_PRESS_ACTION.reorder) {
        this._reorderBegin(item.item, event);
        return;
      }
      if (flat) {
        // The press ends without a drag: the tag is no longer highlighted.
        this._pressed = -1;
        this._render(false);
      }
      if (decision === model.LONG_PRESS_ACTION.none) return;
      if (decision === model.LONG_PRESS_ACTION.callout) this.showCallout(item);
      this._reportLongPress(item);
    },

    /** `taglongpress`: {position, tag} for a flat tag, {section, item, title, subtitle} for a section's item. */
    _reportLongPress(item) {
      if (!item) return;
      if (this._usesTags()) {
        const tag = this._tags[item.item];
        if (tag) this.triggerEvent('taglongpress', { position: item.item, tag: publicTag(tag) });
        return;
      }
      this.triggerEvent('taglongpress', { section: item.section, item: item.item, title: item.title, subtitle: item.subtitle });
    },

    /** A flat tag as an item of the list's section 0 ({key, section, item, title, subtitle}), or null. */
    _tagItem(index) {
      const tag = this._tags[index];
      if (!tag) return null;
      return {
        key: model.key(TAGS_SECTION, index),
        section: TAGS_SECTION,
        item: index,
        title: String(tag.title),
        subtitle: tag.subtitle != null ? String(tag.subtitle) : '',
      };
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

    /** Every selected item's key ("<section>-<item>"; flat tags: "0-<index>"). */
    selectedItems() {
      if (this._usesTags()) return this.selectedIndexes().map((index) => model.key(TAGS_SECTION, index));
      return this.selection.slice();
    },

    contentHeight() {
      return this.height || 0;
    },

    /**
     * The tag and title frames of the last measurement (every tag shown), for layout checks against the core:
     * [{key, title, width, height, titleWidth, left, right}], left and right being the title's distance to the tag's edges.
     * Sections only (empty for flat tags).
     */
    cellMetrics() {
      if (this._usesTags()) return [];
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

    /** Restarts every animated icon on the list from progress 0 (Play all, `playAllAnimations()`); flat tags have none. */
    playAll() {
      if (this._usesTags()) return;
      this.playItems(this.model.sections.flatMap((section) => section.items.map((item) => item.key)));
    },

    // MARK: Flat tags (the core's tag methods)

    /** The tags, in order (getTags()). */
    getTags() {
      return this._tags.map(publicTag);
    },

    /** Adds a tag (addTag(_:)). */
    addTag(tag) {
      this._tags.push(keyed(tag));
      this._render(true);
    },

    /** Adds tags (addTags(_:)). */
    addTags(tags) {
      this._tags.push(...tags.map(keyed));
      this._render(true);
    },

    /** Inserts a tag; selections at or after it move down; an index past the end adds it at the end. */
    insertTag(tag, index) {
      const position = Math.min(Math.max(0, index), this._tags.length);
      this._tags.splice(position, 0, keyed(tag));
      this._selection = tagModel.shiftSelection(this._selection, position, 1);
      this._render(true);
    },

    /** Removes a tag (remove(position)); selections after it move up; out-of-range indexes are ignored. */
    removeTag(index) {
      if (index < 0 || index >= this._tags.length) return;
      this._tags.splice(index, 1);
      this._selection = tagModel.removeSelection(this._selection, index);
      this._render(true);
    },

    /** Removes every tag. */
    removeAllTags() {
      this._tags = [];
      this._selection = [];
      this._render(true);
    },

    /** Replaces the tags (setTags). */
    replaceTags(tags) {
      this._tags = tags.map(keyed);
      this._selection = [];
      this._render(true);
    },

    // MARK: Selection of flat tags

    /** The selected positions, ascending (selectedIndexPaths). */
    selectedIndexes() {
      return this._selection.slice().sort((a, b) => a - b);
    },

    /** toggleSelection(at:): in 'none' mode it still selects (any number), as AndroidTagView's long press. */
    toggleSelection(index) {
      if (index < 0 || index >= this._tags.length) return;
      this._selection = tagModel.toggleSelection(this._selection, index, this.data.selectionMode);
      this._render(false);
    },

    // MARK: Word picker (iOS setTags(withCharactersOf:), selectedText, smear selection)

    /** One tag per character of `text` (graphemes); keeps `selectionMode`, unlike setting `tags`. */
    setTagsWithCharactersOfText(text) {
      this._tags = tagModel.characters(text).map((title) => keyed(tagModel.makeTag(title)));
      this._selection = [];
      this._render(true);
    },

    /** The titles of the selected tags joined in order: the picked text. */
    selectedText() {
      return this.selectedIndexes().map((index) => String(this._tags[index].title)).join('');
    },

    /** Selects the enabled tags from `start` through `end` (either order) without an event. Needs 'multiple'. */
    selectItemsFrom(start, end) {
      if (this.data.selectionMode !== 'multiple' || !this._tags[start] || !this._tags[end]) return;
      this._selection = tagModel.smearSelection(this._selection, start, end, true, this._tags);
      this._render(false);
    },

    /** Whether a smear may start on the tag at `index`. */
    _canSmearFrom(index) {
      const tag = this._tags[index];
      return !!this.data.allowsSmearSelection && this.data.selectionMode === 'multiple' && !this._editing
        && !!tag && tag.isEnabled !== false;
    },

    /** The smear's next tag: the one under the finger extends the range from the first one. */
    _smearTo(index) {
      const smear = this._smear;
      if (!smear || index < 0 || !this._canSmearFrom(index)) return;
      const next = tagModel.smearSelection(smear.base, smear.anchor, index, smear.selects, this._tags);
      if (next.join(',') === this._selection.slice().sort((a, b) => a - b).join(',')) return;
      this._selection = next;
      this._render(false);
      this.triggerEvent('selectionchange', { positions: next.slice() });
    },

    /** Deselects every tag without an event (deselectAllItems()). */
    deselectAll() {
      this._selection = [];
      this._render(false);
    },

    // MARK: Editing (iOS CYLTagListView editing mode and cache)

    /** Whether the tags are in editing mode (`isEditing`). */
    isEditing() {
      return this._editing;
    },

    /** `setEditing(_:animated:)`: enters or leaves editing mode, then `editingchange` {editing}. */
    setEditing(editing) {
      const value = !!editing;
      if (value === this._editing) return;
      this._editing = value;
      if (!value) {
        this._endRenaming();
        // The edited titles and items, for the host to upload (the cache already has them).
        this.triggerEvent('editingfinish', { titles: this.editableSectionTitles(), items: this.editableSectionItems() });
      }
      this._dragging = null;
      this.setData({ isEditing: value, addText: value ? this.data.addText : '' });
      this._updateScrollLock();
      this._updateAddItem();
      // Editing shows every tag; leaving it folds again.
      this._measureFold();
      this._render(false);
      this.triggerEvent('editingchange', { editing: value });
    },

    /** `cachedTitles(inSection:)`: the titles saved in the cache, in order; undefined when nothing was saved or no cache. */
    cachedTitles() {
      return this._cache ? this._cache.cachedTitles('0') : undefined;
    },

    /** `saveEditableSectionsToCache()`: saves the current titles to the cache (the tags are saved after each edit). */
    saveToCache() {
      // With ids, so a renamed tag stays the same tag.
      if (this._cache) this._cache.saveItems(this.editableSectionItems()['0'], '0');
    },

    /** `cachedItems(forSection:)`: the saved items ({identifier, title}); undefined when nothing was saved. */
    cachedItems() {
      return this._cache ? this._cache.cachedItems('0') : undefined;
    },

    /** `editableSectionItems()`: the items by cache key ({"0": [{identifier, title}]}): the id, else the title. */
    editableSectionItems() {
      return { 0: this._tags.map((tag) => ({ identifier: this._identifier(tag), title: String(tag.title) })) };
    },

    /** `loadItems(withKeys:completion:)`: `loadSections` with ids (the remote source's `fetchItemsWithKeys`). */
    loadItems(keys, completion) {
      loadItems({ cache: this._cache, remote: this._remoteSource, policy: this.data.loadPolicy, keys, completion });
    },

    // MARK: Renaming (iOS 990cf115)

    /** `renamingIndexPath`: the position of the tag being renamed; -1 otherwise. */
    renamingIndex() {
      return this._renaming;
    },

    /** `renameRequestHandler`: your own editor, `fn(position, title)`, instead of the add field; null: the add field. */
    setRenameRequestHandler(handler) {
      this._renameRequestHandler = typeof handler === 'function' ? handler : null;
      this._updateAddItem();
    },

    /** Whether the tag at `index` can be renamed now (editing, enabled, `supportsRenamingItems`). */
    isRenamable(index) {
      const tag = this._tags[index];
      return !!tag && this._editing && this.data.supportsRenamingItems && tag.isEnabled !== false;
    },

    /** `beginRenaming(at:)`: the add field shows the tag's title; its submit renames it (or the host's editor gets it). */
    beginRenaming(index) {
      if (!this.isRenamable(index)) return;
      this._renaming = index;
      const title = String(this._tags[index].title);
      if (this._renameRequestHandler) {
        this._renameRequestHandler(index, title);
        return;
      }
      this.setData({ renamingIndex: index, addText: title, addPlaceholder: locale.tc('CYLMenuRenamePlaceholder'), addTitle: locale.tc('CYLMenuRenameDone') });
      this._updateAddItem();
    },

    /** `cancelRenaming()`: ends renaming without a change. */
    cancelRenaming() {
      if (this._renaming < 0) return;
      this._endRenaming();
      this.setData({ addText: '' });
    },

    /**
     * `finishRenaming(to:)`: renames the tag to `title` (trimmed; an empty or unchanged one only ends renaming), saves
     * the cache and sends `tagrename` {position, title, tag}.
     */
    finishRenaming(title) {
      const index = this._renaming;
      if (index < 0) return;
      this._endRenaming();
      this.setData({ addText: '' });
      const name = String(title == null ? '' : title).trim();
      const tag = this._tags[index];
      if (!tag || !name || name === String(tag.title)) return;
      // The id stays with the tag: a tag without one keeps its old title as its id.
      if (!this._hasIdentifier(tag)) tag.identifier = String(tag.title);
      tag.title = name;
      this._render(true);
      this.triggerEvent('tagrename', { position: index, title: name, tag: publicTag(tag) });
    },

    /** `submitNewItem(named:)`: adds a tag from your own editor, as the add field's submit does (trimmed). */
    submitNewItem(name) {
      const trimmed = String(name == null ? '' : name).trim();
      if (!trimmed) return;
      this.cancelRenaming();
      this.triggerEvent('requestnewitem', { name: trimmed, position: this._tags.length });
      this.saveToCache();
    },

    onRename(event) {
      this.beginRenaming(this._index(event));
    },

    // MARK: Folding of flat tags (iOS defaultVisibleRows, CYLMenuFoldControl tail)

    /** Whether the folded tags are shown (`isExpanded(section:)`). */
    isExpanded() {
      return this._expanded;
    },

    /** `setExpanded(_:forSection:animated:)` of the flat tags: shows every tag, or folds them to `defaultVisibleRows`. */
    _setTagsExpanded(expanded) {
      const value = !!expanded;
      if (value === this._expanded) return;
      this._expanded = value;
      this._applyFold();
      this.triggerEvent('foldchange', { canFold: this._fold.canFold, expanded: value });
    },

    /** Shows every tag, measures their rows and the fold control, then folds (a layout change measures again). */
    _measureFold() {
      if (!(this.data.defaultVisibleRows > 0) || this._editing || !this.createSelectorQuery) {
        if (this._fold.canFold || this.data.canFold) {
          this._fold = { canFold: false, visible: [] };
          this._applyFold();
        }
        return;
      }
      this._fold = { canFold: false, visible: [] };
      this._applyFold(true, () => {
        const query = this.createSelectorQuery();
        query.selectAll('.cyl-tc-item').boundingClientRect();
        query.select('.cyl-tc-items').boundingClientRect();
        query.select('#CYLTagListFoldSizer').boundingClientRect();
        query.exec((results) => {
          const [rects, container, sizer] = results || [];
          if (!rects || !container) return;
          const listStyle = this._style();
          this._fold = tagModel.foldVisibility({
            rects: rects.map((rect) => ({ left: rect.left, top: rect.top, right: rect.right })),
            containerRight: container.right,
            tailWidth: sizer ? sizer.width : 0,
            spacing: listStyle.interitemSpacing,
            limit: this.data.defaultVisibleRows,
            expanded: false,
          });
          this._applyFold();
          this.triggerEvent('foldchange', { canFold: this._fold.canFold, expanded: this._expanded });
        });
      });
    },

    /** The items' hidden flags and the fold control from the last measurement (`measuring`: the sizer, every tag). */
    _applyFold(measuring = false, callback) {
      const fold = this._fold;
      const folded = fold.canFold && !this._expanded && !this._editing;
      const patch = {
        canFold: fold.canFold && !this._editing,
        expanded: this._expanded,
        measuringFold: measuring,
        foldTitle: locale.tc(this._expanded ? 'CYLMenuCollapse' : 'CYLMenuExpand'),
      };
      (this.data.items || []).forEach((item, index) => {
        patch[`items[${index}].hidden`] = folded && fold.visible.length > index ? !fold.visible[index] : false;
      });
      this.setData(patch, callback);
    },

    onClearTap() {
      this.triggerEvent('clearbuttontap', { section: 0 });
    },

    _hasIdentifier(tag) {
      const id = tag.identifier;
      return (typeof id === 'string' && id.length > 0) || (typeof id === 'number' && id !== 0);
    },

    _identifier(tag) {
      return this._hasIdentifier(tag) ? String(tag.identifier) : String(tag.title);
    },

    _endRenaming() {
      if (this._renaming < 0 && this.data.renamingIndex < 0) return;
      this._renaming = -1;
      this.setData({ renamingIndex: -1, addPlaceholder: locale.tc('CYLMenuAddTagPlaceholder'), addTitle: locale.tc('CYLMenuAddTag') });
      this._updateAddItem();
    },

    /** The add field: while editing and `showsAddItemViewWhileEditing`, or while renaming without the host's editor. */
    _updateAddItem() {
      const renaming = this._renaming >= 0 && !this._renameRequestHandler;
      this.setData({ showsAddItem: this._editing && (this.data.showsAddItemViewWhileEditing || renaming) });
    },

    _updateClearButton() {
      if (!this.data.showsClearButton) {
        this.setData({ clearImage: '' });
        return;
      }
      const style = this._style();
      const side = Math.ceil(tagModel.lineHeight(style.headerFontSize || 15));
      const clear = locale.tc('CYLMenuClearSection');
      this.setData({
        clearImage: style.clearButtonImage || iconImage('clear', style.clearButtonColor || style.headerTextColor || '#999999'),
        clearStyle: `width: ${side}px; height: ${side}px`,
        clearLabel: this.data.sectionTitle ? `${clear} ${this.data.sectionTitle}` : clear,
      });
    },

    /** `editableSectionTitles()`: the titles by cache key ({"0": titles}, the flat tags being one section). */
    editableSectionTitles() {
      return { 0: this._tags.map((tag) => String(tag.title)) };
    },

    /** `remoteSource`: the server the tags are also kept on (`fetchSectionsWithKeys(keys, callback)`); null: none. */
    setRemoteSource(source) {
      this._remoteSource = source || null;
    },

    /**
     * `loadSections(withKeys:completion:)`: the titles under `keys` (["0"]) from the cache and the remote source in the
     * order of `loadPolicy`; `completion(sections, origin)` once or twice; downloads are saved to the cache first.
     */
    loadSections(keys, completion) {
      loadSections({ cache: this._cache, remote: this._remoteSource, policy: this.data.loadPolicy, keys, completion });
    },

    onAddInput(event) {
      this.setData({ addText: event.detail.value });
    },

    /** `CYLTagListAddItemView.submit()`: the trimmed name as `requestnewitem` {name, position}; the field is cleared. */
    onAddSubmit() {
      const name = String(this.data.addText || '').trim();
      if (!name) return;
      if (this._renaming >= 0) {
        // A submit while renaming renames.
        this.finishRenaming(name);
        return;
      }
      this.setData({ addText: '' });
      this.triggerEvent('requestnewitem', { name, position: this._tags.length });
      this.saveToCache();
    },

    // MARK: Rendering of flat tags

    _style() {
      return this.data.listStyle || tagModel.defaultStyle();
    },

    _render(contentChanged) {
      if (!this._tags || !this._usesTags()) return;
      const listStyle = this._style();
      const context = {
        listStyle,
        theme: this.data.colorTheme,
        selection: this._selection,
        pressed: this._pressed,
        defaultTagImage: this.data.defaultTagImage,
        dragging: this._dragging ? this._dragging.current : -1,
        editing: this._editing,
      };
      const renames = this._editing && this.data.supportsRenamingItems;
      const items = this._tags.map((tag, index) => {
        const item = tagModel.renderTag(tag, index, { ...context, renamable: renames });
        item.renamesOnTitleTap = !!item.editingIcons && this.data.renamesOnTitleTapWhileEditing;
        // The key of the list's section 0: the element's id, so the long-press callout finds the tag.
        item.listKey = model.key(TAGS_SECTION, index);
        // A space (a word picker cell) is read as "Space", not as silence.
        if (String(tag.title).length > 0 && String(tag.title).trim().length === 0) {
          item.accessibilityLabel = coreString('CYLMenuSpaceCharacter');
        }
        return item;
      });
      const list = tagModel.renderList(listStyle, {
        containerBorderWidth: this.data.containerBorderWidth,
        containerBorderColor: this.data.containerBorderColor,
        containerCornerRadius: this.data.containerCornerRadius,
      });
      // While editing, every change of the tags is saved (a delete, an added tag, a drop; iOS saves after each edit).
      if (contentChanged && this._editing) this.saveToCache();
      const fold = this._fold || { canFold: false, visible: [] };
      const folded = fold.canFold && !this._expanded && !this._editing;
      items.forEach((item, index) => {
        item.hidden = folded && fold.visible.length > index ? !fold.visible[index] : false;
      });
      const tail = tagModel.renderTag(tagModel.makeTag('x'), 0, { listStyle, theme: this.data.colorTheme });
      const foldColor = this.data.foldControlColor || listStyle.normal.textColor;
      // The chevron as large as an editing icon: the title's cap height x 1.25 (a text glyph drew a 6 px dash).
      const chevronSide = tagModel.editingIconSide(listStyle.normal.fontSize);
      this.setData({
        flat: true,
        backgroundStyle: '',
        items,
        list,
        foldStyle: `${tail.style}; color: ${foldColor}; font-size: ${listStyle.normal.fontSize}px`,
        foldChevron: iconImage('chevron', foldColor),
        foldChevronStyle: `width: ${chevronSide}px; height: ${chevronSide}px`,
        tagsFoldContent: this.data.foldControlContent,
        foldTitle: locale.tc(this._expanded ? 'CYLMenuCollapse' : 'CYLMenuExpand'),
      }, () => {
        if (contentChanged) {
          this.triggerEvent('contentchange', { count: this._tags.length });
          this._measureFold();
        }
      });
    },

    _index(event) {
      return Number(event.currentTarget.dataset.index);
    },

    // MARK: Touches of flat tags (press, smear, and the phases of a drag that a long press began)

    onTouchStart(event) {
      const index = this._index(event);
      const touch = event.touches[0];
      this._touchStart = { x: touch.clientX, y: touch.clientY };
      // `allowsSmearSelection`: the tag the finger went down on anchors a smear; the frames find the tags it crosses.
      this._smear = null;
      this._smearPending = this._canSmearFrom(index) ? { anchor: index, rects: null } : null;
      if (this._smearPending && this.createSelectorQuery) {
        const pending = this._smearPending;
        this._measure((rects) => { pending.rects = rects; });
      }
      // Pressed: CYLMenuStyle.highlightedBackgroundColor, only while taps are allowed.
      if (this.data.allowsTapping && this._pressed !== index) {
        this._pressed = index;
        this._render(false);
      }
      const item = this.data.items[index];
      if (item && item.rippleColor) this._showRipple(index, touch, item);
    },

    onTouchMove(event) {
      const touch = event.touches[0];
      const drag = this._dragging;
      const pending = this._smearPending;
      if (!drag && pending && this._touchStart) {
        if (!this._smear && Math.hypot(touch.clientX - this._touchStart.x, touch.clientY - this._touchStart.y) > DRAG_THRESHOLD) {
          this._smear = { anchor: pending.anchor, base: this._selection.slice(), selects: !this._selection.includes(pending.anchor) };
          this._pressed = -1;
          // The host holds its scroller now (a catch binding does not stop native scrolling).
          this.triggerEvent('smearingchange', { smearing: true }, GESTURE_EVENT);
          this._smearTo(pending.anchor);
        }
        if (this._smear && pending.rects) {
          const target = pending.rects.findIndex((rect) => rect && touch.clientX >= rect.left && touch.clientX <= rect.right
            && touch.clientY >= rect.top && touch.clientY <= rect.bottom);
          this._smearTo(target);
        }
        if (this._smear) return;
      }
      if (!drag) {
        if (this._pressed >= 0 && this._touchStart
          && Math.hypot(touch.clientX - this._touchStart.x, touch.clientY - this._touchStart.y) > 10) {
          this._pressed = -1;
          this._render(false);
        }
        return;
      }
      this._reorderChanged(touch);
    },

    onTouchEnd() {
      if (this._smear) this.triggerEvent('smearingchange', { smearing: false }, GESTURE_EVENT);
      this._smear = null;
      this._smearPending = null;
      if (this._pressed >= 0) {
        this._pressed = -1;
        this._render(false);
      }
      if (this._dragging) this._reorderEnd();
    },

    onTouchCancel() {
      if (this._smear) this.triggerEvent('smearingchange', { smearing: false }, GESTURE_EVENT);
      this._smear = null;
      this._smearPending = null;
      this._pressed = -1;
      if (this._dragging) this._reorderCancel();
      this._render(false);
    },

    /** Whether the flat tags can move now: `allowsReordering`, or editing. */
    _canReorder() {
      return !!this.data.allowsReordering || this._editing;
    },

    /** The "reorder" long-press action begins: the tag is picked up (beginInteractiveMovementForItem). */
    _reorderBegin(index, event) {
      const touch = (event.touches && event.touches[0]) || this._touchStart || { clientX: 0, clientY: 0 };
      this._pressed = -1;
      // It is reported as a long press if it does not move.
      this._dragging = {
        from: index,
        current: index,
        start: { x: touch.clientX != null ? touch.clientX : touch.x, y: touch.clientY != null ? touch.clientY : touch.y },
        moved: false,
        rects: null,
      };
      const drag = this._dragging;
      this._updateScrollLock();
      this._render(false);
      this.triggerEvent('reorderingchange', { reordering: true }, GESTURE_EVENT);
      if (this._selection.includes(index)) {
        this.triggerEvent('selectedtagdrag', { position: index, tag: publicTag(this._tags[index]) });
      }
      this._measure((rects) => {
        if (this._dragging === drag) drag.rects = rects;
      });
    },

    /** The drag moves (updateInteractiveMovementTargetPosition): the tag moves to the place under the finger. */
    _reorderChanged(touch) {
      const drag = this._dragging;
      if (Math.hypot(touch.clientX - drag.start.x, touch.clientY - drag.start.y) > DRAG_THRESHOLD) drag.moved = true;
      if (!drag.rects) return;
      const target = drag.rects.findIndex((rect) => rect && touch.clientX >= rect.left && touch.clientX <= rect.right
        && touch.clientY >= rect.top && touch.clientY <= rect.bottom);
      if (target < 0 || target === drag.current) return;
      // The interactive movement: the item moves to the place under the finger, within the section.
      this._tags = tagModel.moveItem(this._tags, drag.current, target);
      this._selection = tagModel.moveSelection(this._selection, drag.current, target);
      drag.current = target;
      drag.rects = null;
      this._render(false);
      this._measure((rects) => {
        if (this._dragging === drag) drag.rects = rects;
      });
    },

    /** The drag ends (endInteractiveMovement): `tagmove` when it moved, else the long press is reported. */
    _reorderEnd() {
      const drag = this._dragging;
      this._dragging = null;
      this._updateScrollLock();
      this._render(false);
      this.triggerEvent('reorderingchange', { reordering: false }, GESTURE_EVENT);
      if (drag.current !== drag.from) {
        // The new order survives a relaunch when the list has a cache.
        this.saveToCache();
        this.triggerEvent('tagmove', { from: drag.from, to: drag.current });
        this.triggerEvent('contentchange', { count: this._tags.length });
      }
      // A long press that did not move is reported (onTagLongClick).
      if (!drag.moved) this._reportLongPress(this._tagItem(drag.current));
    },

    /** The drag is cancelled (cancelInteractiveMovement): back to where it was. */
    _reorderCancel() {
      const drag = this._dragging;
      this._tags = tagModel.moveItem(this._tags, drag.current, drag.from);
      this._selection = tagModel.moveSelection(this._selection, drag.current, drag.from);
      this._dragging = null;
      this._updateScrollLock();
      this.triggerEvent('reorderingchange', { reordering: false }, GESTURE_EVENT);
    },

    /** Holds page scrolling while editing or dragging (`disablesScrollingWhileReordering`): the items catch touchmove. */
    _updateScrollLock() {
      const locked = !!this.data.disablesScrollingWhileReordering && (this._editing || !!this._dragging);
      if (locked !== this.data.scrollLocked) this.setData({ scrollLocked: locked });
    },

    onTap(event) {
      this.dismissCallout();
      const index = this._index(event);
      if (!this.data.allowsTapping) return;
      const tag = this._tags[index];
      if (!tag || tag.isEnabled === false) return;
      const before = this._selection;
      // Editing: a tap reports the tag without changing the selection.
      if (!this._editing) {
        this._selection = tagModel.tapSelection(before, index, this.data.selectionMode, this.data.allowsEmptySelection);
      }
      if (this._selection !== before) this._render(false);
      this.triggerEvent('tagtap', { position: index, tag: publicTag(tag) });
    },

    onDelete(event) {
      const index = this._index(event);
      const tag = this._tags[index];
      if (!tag || !(tag.isDeletable || this._editing) || tag.isEnabled === false) return;
      if (this.data.removesItemsOnDelete) {
        this._tags.splice(index, 1);
        this._selection = tagModel.removeSelection(this._selection, index);
        this._pressed = -1;
        this._render(true);
      }
      this.triggerEvent('tagdelete', { position: index, tag: publicTag(tag) });
    },

    noop() {},

    _measure(callback) {
      this.createSelectorQuery().selectAll('.cyl-tc-item').boundingClientRect((rects) => {
        callback(rects || []);
      }).exec();
    },

    /** AndroidTagView's ripple: a circle from the touch point to the farthest corner, fading out. */
    _showRipple(index, touch, item) {
      this.createSelectorQuery().select(`#cyl-item-${item.listKey}`).boundingClientRect((rect) => {
        if (!rect) return;
        const x = touch.clientX - rect.left;
        const y = touch.clientY - rect.top;
        const dx = Math.max(x, rect.width - x);
        const dy = Math.max(y, rect.height - y);
        const radius = Math.sqrt(dx * dx + dy * dy);
        const id = this._rippleId++;
        const key = item.key;
        const style = `left: ${x - radius}px; top: ${y - radius}px; width: ${2 * radius}px; height: ${2 * radius}px; `
          + `background-color: ${item.rippleColor}; animation-duration: ${item.rippleDuration}s`;
        this.setData({ [`ripples.k${key}`]: [{ id, style }] });
        setTimeout(() => {
          const current = this.data.ripples[`k${key}`];
          if (current && current[0] && current[0].id === id) this.setData({ [`ripples.k${key}`]: null });
        }, item.rippleDuration * 1000);
      }).exec();
    },
  },
});
