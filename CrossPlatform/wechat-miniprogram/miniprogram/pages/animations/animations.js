/**
 * Animated icons: a tag list from one configuration (the Flutter example's `TagListPage`) and the playback controls of
 * docs/example-demo-rules.md: Play all (every animation from progress 0, once), a speed slider (0.25x to 4x in steps
 * of 0.25, the value next to it) and a loop switch. They combine and act at once on animations that are playing.
 */
const MIN_SPEED = 0.25;
const MAX_SPEED = 4;

function speedText(speed) {
  return `${speed}×`;
}

function configuration() {
  const item = (title, image) => ({ title, image });
  // CYLTabBarController's Lottie tab icons (data/lottie-registry.js).
  const animated = (title, name) => ({ title, animation: `asset:${name}` });
  return {
    selectionMode: 'multiple',
    defaultVisibleRows: 3,
    foldControl: { position: 'tail', content: 'icon' },
    style: {
      itemHeight: 36,
      imageSize: '{18, 18}',
      normal: { cornerRadius: 0, borderColor: '#D1D1D6', borderWidth: 1 },
      selected: { cornerRadius: 0, backgroundColor: '#E6F8F5', textColor: '#2AB9A0', borderColor: '#2AB9A0' },
    },
    sections: [
      {
        title: 'Lottie · lottie-miniprogram',
        items: [
          animated('Home', 'home'),
          animated('Messages', 'message'),
          animated('Search', 'search'),
          animated('Me', 'me'),
        ],
      },
      {
        title: 'Tags',
        items: [
          item('Home', 'system:house'),
          item('Search', 'system:magnifyingglass'),
          item('Messages', 'system:message'),
          item('Profile', 'system:person'),
          item('Favorites', 'system:star'),
          item('Settings', 'system:gearshape'),
          item('Camera', 'system:camera'),
          item('Music', 'system:music.note'),
          item('Maps', 'system:map'),
          item('Calendar', 'system:calendar'),
        ],
      },
    ],
  };
}

Page({
  data: {
    configuration: configuration(),
    minSpeed: MIN_SPEED,
    maxSpeed: MAX_SPEED,
    speed: 1,
    speedText: speedText(1),
    loops: false,
    lastTap: '',
  },

  onShow() {
    // The custom tab bar (CYLTabBarController's cyl-tab-bar) selects the tab of this page.
    if (typeof this.getTabBar === 'function' && this.getTabBar()) this.getTabBar().syncWithRoute(this.route);
  },

  onLoad(options) {
    // `?autoplay=1` (a compile condition) applies 2x, loop and Play all after a second, for screenshots.
    if (options && options.autoplay) {
      setTimeout(() => {
        this.setData({ speed: 2, speedText: speedText(2), loops: true });
        this.playAll();
      }, 1000);
    }
  },

  onSpeedChanging(event) {
    const speed = Number(event.detail.value);
    this.setData({ speed, speedText: speedText(speed) });
  },

  onLoopChange(event) {
    this.setData({ loops: event.detail.value });
  },

  playAll() {
    const list = this.selectComponent('#tags');
    if (list) list.playAll();
  },

  onTagTap(event) {
    const { title, selected } = event.detail;
    this.setData({ lastTap: `${title} · ${selected ? 'selected' : 'deselected'}` });
  },
});

