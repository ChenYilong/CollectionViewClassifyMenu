/**
 * cyl-tag-cloud: the core's CYLTagListView filled the android-tagview way (its tag methods and `CYLTag`), also with
 * the AndroidTagView TagContainerLayout options the core has (color theme, tapping, deleting, reordering, default
 * image, container border, touch ripple). One section of tags laid out in rows (flex wrap: the rows of
 * `CYLCollectionViewLeftAlignedLayout`, aligned by `rowAlignment`). The look and the logic are in model.js.
 *
 * Properties: `tags` (CYLTag objects, model.makeTag), `listStyle` (a model style: defaultStyle(), tagCloudStyle(),
 * tagContainerStyle()), `colorTheme`, `allowsTapping`, `removesItemsOnDelete`, `allowsReordering`, `selectionMode`,
 * `defaultTagImage`, `containerBorderWidth` / `Color` / `CornerRadius`, `showsSectionHeaders` + `sectionTitle`.
 * Setting `tags` replaces the tags (`replaceTags`); the methods below change them as the core's do.
 *
 * Events (the core's handlers): `tagtap` {position, tag} (tagClickHandler), `tagdelete` {position, tag}
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
 * Folding (iOS `defaultVisibleRows` + `CYLMenuFoldControl` tail): with `defaultVisibleRows` > 0 the cloud shows that
 * many rows with a fold control (a chevron, `foldControlContent` 'icon' / 'title' / 'titleAndIcon') as the last tag;
 * a tap on it (or `setExpanded(true)`) shows every tag, the control then folding them again; `foldchange` {canFold,
 * expanded}. Editing shows every tag, as iOS.
 *
 * Word picker (iOS 选词填入): `setTagsWithCharactersOfText(text)` (one tag per character, keeps `selectionMode`),
 * `selectedText()`, `selectItemsFrom(start, end)`, and `allowsSmearSelection`: a drag that starts on a tag selects every
 * tag from it to the one under the finger (or deselects them when it started on a selected one), the page not
 * scrolling meanwhile; a tap still toggles; `selectionchange` {positions}. Needs `selectionMode` 'multiple';
 * `model.wordPickerStyle()` is the matching look.
 */
const model = require('./model.js');
const { coreString } = require('../core-strings.js');
const { CYLTagListStore, loadSections, loadItems } = require('./cache.js');
const { iconImage } = require('./editing-icons.js');
const locale = require('../locale.js');

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

Component({
  options: { styleIsolation: 'isolated' },

  properties: {
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
    // While a tag is dragged (from the long press to the end of the drag), its touch moves do not scroll the page, so
    // the drag and scrolling do not fight. On by default; a host with a <scroll-view> also turns its scroll-y off on
    // `reorderingchange` {reordering}.
    disablesScrollingWhileReordering: { type: Boolean, value: true },
    foldControlContent: { type: String, value: 'icon' },
    foldControlColor: { type: String, value: '' },
  },

  data: {
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
    attached() {
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
      this._render(false);
    },
  },

  methods: {
    // MARK: Tags (the core's tag methods)

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
      this._selection = model.shiftSelection(this._selection, position, 1);
      this._render(true);
    },

    /** Removes a tag (remove(position)); selections after it move up; out-of-range indexes are ignored. */
    removeTag(index) {
      if (index < 0 || index >= this._tags.length) return;
      this._tags.splice(index, 1);
      this._selection = model.removeSelection(this._selection, index);
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

    // MARK: Selection

    /** The selected positions, ascending (selectedIndexPaths). */
    selectedIndexes() {
      return this._selection.slice().sort((a, b) => a - b);
    },

    /** toggleSelection(at:): in 'none' mode it still selects (any number), as AndroidTagView's long press. */
    toggleSelection(index) {
      if (index < 0 || index >= this._tags.length) return;
      this._selection = model.toggleSelection(this._selection, index, this.data.selectionMode);
      this._render(false);
    },

    // MARK: Word picker (iOS setTags(withCharactersOf:), selectedText, smear selection)

    /** One tag per character of `text` (graphemes); keeps `selectionMode`, unlike setting `tags`. */
    setTagsWithCharactersOfText(text) {
      this._tags = model.characters(text).map((title) => keyed(model.makeTag(title)));
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
      this._selection = model.smearSelection(this._selection, start, end, true, this._tags);
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
      const next = model.smearSelection(smear.base, smear.anchor, index, smear.selects, this._tags);
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

    /** Whether the cloud is in editing mode (`isEditing`). */
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

    /** `saveEditableSectionsToCache()`: saves the current titles to the cache (the cloud saves after each edit). */
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

    // MARK: Folding (iOS defaultVisibleRows, CYLMenuFoldControl tail)

    /** Whether the folded tags are shown (`isExpanded(section:)`). */
    isExpanded() {
      return this._expanded;
    },

    /** `setExpanded(_:forSection:animated:)`: shows every tag, or folds them to `defaultVisibleRows` again. */
    setExpanded(expanded) {
      const value = !!expanded;
      if (value === this._expanded) return;
      this._expanded = value;
      this._applyFold();
      this.triggerEvent('foldchange', { canFold: this._fold.canFold, expanded: value });
    },

    onFoldTap() {
      this.setExpanded(!this._expanded);
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
          this._fold = model.foldVisibility({
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
      const side = Math.ceil(model.lineHeight(style.headerFontSize || 15));
      const clear = locale.tc('CYLMenuClearSection');
      this.setData({
        clearImage: style.clearButtonImage || iconImage('clear', style.clearButtonColor || style.headerTextColor || '#999999'),
        clearStyle: `width: ${side}px; height: ${side}px`,
        clearLabel: this.data.sectionTitle ? `${clear} ${this.data.sectionTitle}` : clear,
      });
    },

    /** `editableSectionTitles()`: the titles by cache key ({"0": titles}, the cloud being one section). */
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

    // MARK: Rendering

    _style() {
      return this.data.listStyle || model.defaultStyle();
    },

    _render(contentChanged) {
      if (!this._tags) return;
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
        const item = model.renderTag(tag, index, { ...context, renamable: renames });
        item.renamesOnTitleTap = !!item.editingIcons && this.data.renamesOnTitleTapWhileEditing;
        // A space (a word picker cell) is read as "Space", not as silence.
        if (String(tag.title).length > 0 && String(tag.title).trim().length === 0) {
          item.accessibilityLabel = coreString('CYLMenuSpaceCharacter');
        }
        return item;
      });
      const list = model.renderList(listStyle, {
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
      const tail = model.renderTag(model.makeTag('x'), 0, { listStyle, theme: this.data.colorTheme });
      const foldColor = this.data.foldControlColor || listStyle.normal.textColor;
      // The chevron as large as an editing icon: the title's cap height x 1.25 (a text glyph drew a 6 px dash).
      const chevronSide = model.editingIconSide(listStyle.normal.fontSize);
      this.setData({
        items,
        list,
        foldStyle: `${tail.style}; color: ${foldColor}; font-size: ${listStyle.normal.fontSize}px`,
        foldChevron: iconImage('chevron', foldColor),
        foldChevronStyle: `width: ${chevronSide}px; height: ${chevronSide}px`,
        foldContent: this.data.foldControlContent,
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

    // MARK: Touches

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
      if (Math.hypot(touch.clientX - drag.start.x, touch.clientY - drag.start.y) > DRAG_THRESHOLD) drag.moved = true;
      if (!drag.rects) return;
      const target = drag.rects.findIndex((rect) => rect && touch.clientX >= rect.left && touch.clientX <= rect.right
        && touch.clientY >= rect.top && touch.clientY <= rect.bottom);
      if (target < 0 || target === drag.current) return;
      // The interactive movement: the item moves to the place under the finger, within the section.
      this._tags = model.moveItem(this._tags, drag.current, target);
      this._selection = model.moveSelection(this._selection, drag.current, target);
      drag.current = target;
      drag.rects = null;
      this._render(false);
      this._measure((rects) => {
        if (this._dragging === drag) drag.rects = rects;
      });
    },

    onTouchEnd() {
      this._smear = null;
      this._smearPending = null;
      if (this._pressed >= 0) {
        this._pressed = -1;
        this._render(false);
      }
      const drag = this._dragging;
      if (!drag) return;
      this._dragging = null;
      this._setScrollLocked(false);
      this._render(false);
      this.triggerEvent('reorderingchange', { reordering: false });
      if (drag.current !== drag.from) {
        // The new order survives a relaunch when the cloud has a cache.
        this.saveToCache();
        this.triggerEvent('tagmove', { from: drag.from, to: drag.current });
        this.triggerEvent('contentchange', { count: this._tags.length });
      }
      // A long press that did not move is reported (onTagLongClick).
      if (!drag.moved) this._reportLongPress(drag.current);
    },

    onTouchCancel() {
      this._smear = null;
      this._smearPending = null;
      const drag = this._dragging;
      this._pressed = -1;
      if (drag) {
        // cancelInteractiveMovement(): back to where it was.
        this._tags = model.moveItem(this._tags, drag.current, drag.from);
        this._selection = model.moveSelection(this._selection, drag.current, drag.from);
        this._dragging = null;
        this._setScrollLocked(false);
        this.triggerEvent('reorderingchange', { reordering: false });
      }
      this._render(false);
    },

    /** Holds or releases page scrolling for a drag: the item catches its touch moves while `scrollLocked`. */
    _setScrollLocked(locked) {
      if (locked !== this.data.scrollLocked) this.setData({ scrollLocked: locked });
    },

    onTap(event) {
      const index = this._index(event);
      if (!this.data.allowsTapping) return;
      const tag = this._tags[index];
      if (!tag || tag.isEnabled === false) return;
      const before = this._selection;
      // Editing: a tap reports the tag without changing the selection.
      if (!this._editing) {
        this._selection = model.tapSelection(before, index, this.data.selectionMode, this.data.allowsEmptySelection);
      }
      if (this._selection !== before) this._render(false);
      this.triggerEvent('tagtap', { position: index, tag: publicTag(tag) });
    },

    onLongPress(event) {
      const index = this._index(event);
      const touch = (event.touches && event.touches[0]) || this._touchStart || { clientX: 0, clientY: 0 };
      if (this._pressed >= 0) this._pressed = -1;
      if (this.data.allowsReordering || this._editing) {
        // A long press begins the interactive movement; it is reported as a long press if it does not move.
        this._dragging = {
          from: index,
          current: index,
          start: { x: touch.clientX != null ? touch.clientX : touch.x, y: touch.clientY != null ? touch.clientY : touch.y },
          moved: false,
          rects: null,
        };
        const drag = this._dragging;
        this._setScrollLocked(this.data.disablesScrollingWhileReordering);
        this._render(false);
        this.triggerEvent('reorderingchange', { reordering: true });
        if (this._selection.includes(index)) {
          this.triggerEvent('selectedtagdrag', { position: index, tag: publicTag(this._tags[index]) });
        }
        this._measure((rects) => {
          if (this._dragging === drag) drag.rects = rects;
        });
        return;
      }
      this._render(false);
      this._reportLongPress(index);
    },

    onDelete(event) {
      const index = this._index(event);
      const tag = this._tags[index];
      if (!tag || !(tag.isDeletable || this._editing) || tag.isEnabled === false) return;
      if (this.data.removesItemsOnDelete) {
        this._tags.splice(index, 1);
        this._selection = model.removeSelection(this._selection, index);
        this._pressed = -1;
        this._render(true);
      }
      this.triggerEvent('tagdelete', { position: index, tag: publicTag(tag) });
    },

    noop() {},

    _reportLongPress(index) {
      const tag = this._tags[index];
      if (tag) this.triggerEvent('taglongpress', { position: index, tag: publicTag(tag) });
    },

    _measure(callback) {
      this.createSelectorQuery().selectAll('.cyl-tc-item').boundingClientRect((rects) => {
        callback(rects || []);
      }).exec();
    },

    /** AndroidTagView's ripple: a circle from the touch point to the farthest corner, fading out. */
    _showRipple(index, touch, item) {
      this.createSelectorQuery().select(`#cyl-tc-item-${index}`).boundingClientRect((rect) => {
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
