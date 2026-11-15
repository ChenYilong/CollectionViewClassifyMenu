/**
 * cyl-tag-image: the core's CYLImageTagView — a picture with groups of tags on it (CYLImageTagGroupView: a dot with a
 * ring, a line to each tag, the tags, a ripple, show / hide animations, taps, a long press, dragging in edit mode).
 * The geometry and the animations are in model.js. The component fills its host: give the host a size (the samples
 * make it square).
 *
 * Properties: `image` (the picture), `imageLabel` (its accessibilityLabel; "图片" when empty), `tagGroups`
 * (model.makeGroup objects; setting it replaces the groups, as setTagList), `editing` (setEditMode: groups can be
 * dragged, a tap on a tag turns it to the next direction, no ripples).
 * Methods: getTagGroups(), addTagGroup(group), removeTagGroup(index), toggleTagGroups(animated).
 * Events: `imagetap` (a tap on the picture outside the tags), `circletap` {index}, `tagtap` {groupIndex, tagIndex,
 * tag} (after the turn while editing), `longpress` {index}, `drag` {index, percentPosition}.
 */
const model = require('./model.js');
const { coreString, joinList } = require('../../utils/cyl-core-strings.js');

const FRAME_INTERVAL = 16;

function px(value) {
  return `${Math.round(value * 100) / 100}px`;
}

Component({
  options: { styleIsolation: 'isolated' },

  properties: {
    image: { type: String, value: '' },
    imageLabel: { type: String, value: '' },
    imageHint: { type: String, value: '' },
    tagGroups: { type: Array, value: [] },
    editing: { type: Boolean, value: false },
  },

  data: {
    groups: [],
    measureTitles: [],
    labelMaxWidth: 0,
    pictureLabel: '',
    turnHint: '',
  },

  observers: {
    tagGroups(groups) {
      this._groupsSet = true;
      this._stopAnimations();
      this._groups = (groups || []).map((group) => this._state(group));
      this._refresh();
    },
    editing() {
      this._refresh();
    },
    'imageLabel, imageHint'() {
      this._updatePictureLabel();
    },
  },

  lifetimes: {
    created() {
      this._groups = [];
      this._sizes = {};
      this._timers = {};
      this._size = null;
    },
    attached() {
      this._updatePictureLabel();
      this.setData({ turnHint: coreString('CYLImageTagTurnHint') });
    },
    ready() {
      // The initial groups, when the observer has not run for them.
      if (!this._groupsSet) this._groups = (this.data.tagGroups || []).map((group) => this._state(group));
      this._refresh();
    },
    detached() {
      this._stopAnimations();
    },
  },

  methods: {
    // MARK: Groups

    /** The groups, kept up to date while editing (getTagGroupModels). */
    getTagGroups() {
      return this._groups.map((state) => model.copyGroup(state.model));
    },

    /** Adds a copy of the group on top of the others. */
    addTagGroup(group) {
      this._groups.push(this._state(group));
      this._refresh();
    },

    /** Removes the group at this index; an index past the end does nothing. */
    removeTagGroup(index) {
      if (index < 0 || index >= this._groups.length) return;
      this._stopAnimation(index);
      this._groups.splice(index, 1);
      this._refresh();
    },

    /** Shows hidden groups and hides shown ones (excuteTagsAnimation). */
    toggleTagGroups(animated = true) {
      this._groups.forEach((state, index) => {
        if (state.hidden) this._show(index, animated);
        else this._hide(index, animated);
      });
    },

    // MARK: Layout

    /** A group view's state: a copy of the group, shown, at rest. */
    _state(group) {
      return { model: model.copyGroup(group), hidden: false, anim: this._restingValues(), offset: 0 };
    },

    _restingValues() {
      return {
        circleRadius: model.DEFAULTS.circleRadius,
        circleInnerRadius: model.DEFAULTS.circleInnerRadius,
        linesProgress: 1,
        tagAlpha: 1,
      };
    },

    _updatePictureLabel() {
      const label = this.data.imageLabel || coreString('CYLImageTagPicture');
      this.setData({ pictureLabel: this.data.imageHint ? `${label}, ${this.data.imageHint}` : label });
    },

    /** Measures the view and the tags that are not measured yet, then lays the groups out. */
    _refresh() {
      const query = this.createSelectorQuery();
      query.select('.cyl-it').boundingClientRect((rect) => {
        if (!rect || !rect.width) return;
        this._rect = rect;
        this._size = { width: rect.width, height: rect.height };
        const maxWidth = model.labelMaximumWidth(rect.width);
        if (maxWidth !== this._maxWidth) {
          this._maxWidth = maxWidth;
          this._sizes = {};
        }
        const titles = [];
        for (const state of this._groups) {
          for (const tag of state.model.tags) {
            if (!this._sizes[tag.title] && !titles.includes(tag.title)) titles.push(tag.title);
          }
        }
        if (!titles.length) {
          this._layout();
          return;
        }
        this.setData({ measureTitles: titles, labelMaxWidth: maxWidth }, () => {
          this.createSelectorQuery().selectAll('.cyl-it-measure-label').boundingClientRect((rects) => {
            (rects || []).forEach((r, i) => {
              const title = titles[i];
              if (title != null) this._sizes[title] = { width: Math.ceil(r.width), height: Math.ceil(r.height) };
            });
            this.setData({ measureTitles: [] });
            this._layout();
          }).exec();
        });
      }).exec();
    },

    _tagSizes(state) {
      return state.model.tags.map((tag) => this._sizes[tag.title] || { width: 44, height: 23 });
    },

    /** Lays every group out; groups that cover each other move apart (not while editing). */
    _layout() {
      if (!this._size) return;
      const { width, height } = this._size;
      const editing = this.data.editing;
      const frames = this._groups.map((state) => (
        model.layoutGroup(state.model, this._tagSizes(state), width, height).occupied));
      const offsets = model.separateGroups(frames, height, { editing, hidden: this._groups.map((s) => s.hidden) });
      offsets.forEach((dy, index) => { this._groups[index].offset = dy; });
      this.setData({ groups: this._groups.map((state, index) => this._renderGroup(state, index)) });
    },

    _renderGroup(state, index) {
      const { width, height } = this._size;
      const sizes = this._tagSizes(state);
      const layout = model.layoutGroup(state.model, sizes, width, height, { x: 0, y: state.offset });
      state.layout = layout;
      const { anim } = state;
      const d = model.DEFAULTS;
      const { x: cx, y: cy } = layout.center;
      const ring = anim.circleRadius;
      const inner = anim.circleInnerRadius;
      const hit = Math.max(d.circleRadius * 2, 22);
      const lines = [];
      layout.lines.forEach((points, tagIndex) => {
        model.linePieces(points, anim.linesProgress).forEach((piece, pieceIndex) => {
          lines.push({
            key: `${tagIndex}-${pieceIndex}`,
            style: `left: ${px(piece.x)}; top: ${px(piece.y - d.lineWidth / 2)}; width: ${px(piece.length)}; `
              + `height: ${px(d.lineWidth)}; transform: rotate(${Math.round(piece.angle * 100) / 100}deg); `
              + `background-color: ${d.lineColor}`,
          });
        });
      });
      const tags = layout.frames.map((frame, tagIndex) => ({
        index: tagIndex,
        title: state.model.tags[tagIndex].title,
        center: state.model.tags[tagIndex].direction === 'center',
        style: `left: ${px(frame.x)}; top: ${px(frame.y)}; width: ${px(frame.width)}; height: ${px(frame.height)}; `
          + `opacity: ${anim.tagAlpha}`,
      }));
      const side = 2 * d.rippleMaxRadius;
      return {
        key: index,
        hidden: state.hidden,
        ring: `left: ${px(cx - ring)}; top: ${px(cy - ring)}; width: ${px(2 * ring)}; height: ${px(2 * ring)}; `
          + `background-color: ${d.circleColor}`,
        inner: `left: ${px(cx - inner)}; top: ${px(cy - inner)}; width: ${px(2 * inner)}; height: ${px(2 * inner)}; `
          + `background-color: ${d.circleInnerColor}`,
        hit: `left: ${px(cx - hit)}; top: ${px(cy - hit)}; width: ${px(2 * hit)}; height: ${px(2 * hit)}`,
        // The ripple sits on the dot before the display offset (`rippleView.frame` uses cx, cy).
        ripple: this.data.editing ? '' : `left: ${px(layout.base.x - side / 2)}; top: ${px(layout.base.y - side / 2)}; `
          + `width: ${px(side)}; height: ${px(side)}`,
        lines,
        tags,
        label: coreString('CYLImageTagGroup', joinList(state.model.tags.map((tag) => tag.title))),
      };
    },

    _renderOne(index) {
      const state = this._groups[index];
      if (!state || !this._size) return;
      this.setData({ [`groups[${index}]`]: this._renderGroup(state, index) });
    },

    // MARK: Animations

    _show(index, animated) {
      const state = this._groups[index];
      this._stopAnimation(index);
      state.hidden = false;
      if (!animated) {
        state.anim = this._restingValues();
        this._renderOne(index);
        return;
      }
      this._run(index, model.SHOW_DURATION, model.showFrame, () => {
        state.anim = this._restingValues();
      });
    },

    _hide(index, animated) {
      const state = this._groups[index];
      this._stopAnimation(index);
      if (!animated) {
        state.hidden = true;
        this._renderOne(index);
        return;
      }
      this._run(index, model.HIDE_DURATION, model.hideFrame, () => {
        state.hidden = true;
      });
    },

    _run(index, duration, frame, completion) {
      const state = this._groups[index];
      const start = Date.now();
      const step = () => {
        const elapsed = Date.now() - start;
        state.anim = frame(Math.min(elapsed, duration));
        if (elapsed >= duration) {
          this._stopAnimation(index);
          completion();
        }
        this._renderOne(this._groups.indexOf(state));
      };
      step();
      this._timers[index] = setInterval(step, FRAME_INTERVAL);
    },

    _stopAnimation(index) {
      if (this._timers[index]) {
        clearInterval(this._timers[index]);
        delete this._timers[index];
      }
    },

    _stopAnimations() {
      Object.keys(this._timers || {}).forEach((index) => this._stopAnimation(index));
    },

    // MARK: Touches

    onImageTap() {
      this.triggerEvent('imagetap');
    },

    onCircleTap(event) {
      this.triggerEvent('circletap', { index: Number(event.currentTarget.dataset.group) });
    },

    onTagTap(event) {
      const groupIndex = Number(event.currentTarget.dataset.group);
      const tagIndex = Number(event.currentTarget.dataset.tag);
      const state = this._groups[groupIndex];
      if (!state || tagIndex < 0 || tagIndex >= state.model.tags.length) return;
      const tag = state.model.tags[tagIndex];
      if (this.data.editing) {
        // The sample's onTagClicked: the next direction.
        tag.direction = model.nextDirection(tag.direction);
        this._renderOne(groupIndex);
      }
      this.triggerEvent('tagtap', { groupIndex, tagIndex, tag: { ...tag } });
    },

    onLongPress(event) {
      this._drag = null;
      this.triggerEvent('longpress', { index: Number(event.currentTarget.dataset.group) });
    },

    onTouchStart(event) {
      if (!this.data.editing) return;
      const index = Number(event.currentTarget.dataset.group);
      const state = this._groups[index];
      if (!state || !state.layout || !this._rect) return;
      const touch = event.touches[0];
      const point = { x: touch.clientX - this._rect.left, y: touch.clientY - this._rect.top };
      this._drag = { index, offset: { x: state.layout.center.x - point.x, y: state.layout.center.y - point.y } };
    },

    onTouchMove(event) {
      const drag = this._drag;
      if (!drag || !this.data.editing || !this._size) return;
      const state = this._groups[drag.index];
      if (!state) return;
      const touch = event.touches[0];
      const x = touch.clientX - this._rect.left + drag.offset.x;
      const y = touch.clientY - this._rect.top + drag.offset.y;
      const percentPosition = {
        x: Math.min(1, Math.max(0, x / Math.max(1, this._size.width))),
        y: Math.min(1, Math.max(0, y / Math.max(1, this._size.height))),
      };
      state.model.percentPosition = percentPosition;
      this._renderOne(drag.index);
      this.triggerEvent('drag', { index: drag.index, percentPosition: { ...percentPosition } });
    },

    onTouchEnd() {
      this._drag = null;
    },
  },
});
