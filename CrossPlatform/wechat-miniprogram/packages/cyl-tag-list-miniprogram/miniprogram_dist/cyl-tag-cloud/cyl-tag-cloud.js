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
 */
const model = require('./model.js');
const { coreString } = require('../core-strings.js');

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
  },

  data: {
    items: [],
    list: {},
    ripples: {},
    deleteLabel: '',
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
  },

  lifetimes: {
    created() {
      this._tags = [];
      this._selection = [];
      this._pressed = -1;
      this._dragging = null;
      this._rippleId = 1;
    },
    attached() {
      this.setData({ deleteLabel: coreString('CYLMenuDeleteTag') });
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

    /** Deselects every tag without an event (deselectAllItems()). */
    deselectAll() {
      this._selection = [];
      this._render(false);
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
      };
      const items = this._tags.map((tag, index) => model.renderTag(tag, index, context));
      const list = model.renderList(listStyle, {
        containerBorderWidth: this.data.containerBorderWidth,
        containerBorderColor: this.data.containerBorderColor,
        containerCornerRadius: this.data.containerCornerRadius,
      });
      this.setData({ items, list }, () => {
        if (contentChanged) this.triggerEvent('contentchange', { count: this._tags.length });
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
      if (this._pressed >= 0) {
        this._pressed = -1;
        this._render(false);
      }
      const drag = this._dragging;
      if (!drag) return;
      this._dragging = null;
      this._render(false);
      this.triggerEvent('reorderingchange', { reordering: false });
      if (drag.current !== drag.from) {
        this.triggerEvent('tagmove', { from: drag.from, to: drag.current });
        this.triggerEvent('contentchange', { count: this._tags.length });
      }
      // A long press that did not move is reported (onTagLongClick).
      if (!drag.moved) this._reportLongPress(drag.current);
    },

    onTouchCancel() {
      const drag = this._dragging;
      this._pressed = -1;
      if (drag) {
        // cancelInteractiveMovement(): back to where it was.
        this._tags = model.moveItem(this._tags, drag.current, drag.from);
        this._selection = model.moveSelection(this._selection, drag.current, drag.from);
        this._dragging = null;
        this.triggerEvent('reorderingchange', { reordering: false });
      }
      this._render(false);
    },

    onTap(event) {
      const index = this._index(event);
      if (!this.data.allowsTapping) return;
      const tag = this._tags[index];
      if (!tag || tag.isEnabled === false) return;
      const before = this._selection;
      this._selection = model.tapSelection(before, index, this.data.selectionMode, this.data.allowsEmptySelection);
      if (this._selection !== before) this._render(false);
      this.triggerEvent('tagtap', { position: index, tag: publicTag(tag) });
    },

    onLongPress(event) {
      const index = this._index(event);
      const touch = (event.touches && event.touches[0]) || this._touchStart || { clientX: 0, clientY: 0 };
      if (this._pressed >= 0) this._pressed = -1;
      if (this.data.allowsReordering) {
        // A long press begins the interactive movement; it is reported as a long press if it does not move.
        this._dragging = {
          from: index,
          current: index,
          start: { x: touch.clientX != null ? touch.clientX : touch.x, y: touch.clientY != null ? touch.clientY : touch.y },
          moved: false,
          rects: null,
        };
        const drag = this._dragging;
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
      if (!tag || !tag.isDeletable || tag.isEnabled === false) return;
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
