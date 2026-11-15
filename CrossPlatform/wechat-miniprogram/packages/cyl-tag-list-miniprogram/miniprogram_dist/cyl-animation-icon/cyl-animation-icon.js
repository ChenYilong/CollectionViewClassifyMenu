/**
 * The default `cyl-animation-icon` of cyl-tag-list: an empty slot, for an app that links no animation engine. An app
 * that plays animations gives cyl-tag-list its own icon component (generic:cyl-animation-icon="…") with the same
 * properties (animation, options, size, height, speed, loops, selected, restingProgress, disabled) and `play()`.
 */
Component({
  properties: {
    animation: { type: String, value: '' },
    options: { type: null, value: null },
    size: { type: Number, value: 18 },
    height: { type: Number, value: 0 },
    speed: { type: Number, value: 1 },
    loops: { type: Boolean, value: false },
    selected: { type: Boolean, value: false },
    restingProgress: { type: Number, value: 0 },
    disabled: { type: Boolean, value: false },
  },
  methods: {
    play() {},
  },
});
