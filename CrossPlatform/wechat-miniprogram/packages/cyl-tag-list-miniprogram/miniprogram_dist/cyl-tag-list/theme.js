/**
 * The system color mode of the Mini Program (`theme` of wx.getAppBaseInfo(), 'light' or 'dark') and a way to follow its
 * changes, so the list's defaults (the tag fill and title, the one tint of the header and fold controls) follow dark mode
 * as iOS's dynamic colors do.
 */
function isDark() {
  try {
    const info = wx.getAppBaseInfo ? wx.getAppBaseInfo() : wx.getSystemInfoSync();
    return info.theme === 'dark';
  } catch (error) {
    return false;
  }
}

/** Calls `callback(dark)` when the system theme changes; returns the function that stops it. */
function onChange(callback) {
  if (typeof wx === 'undefined' || typeof wx.onThemeChange !== 'function') return () => {};
  const listener = (result) => callback(!!result && result.theme === 'dark');
  wx.onThemeChange(listener);
  return () => {
    if (typeof wx.offThemeChange === 'function') wx.offThemeChange(listener);
  };
}

module.exports = { isDark, onChange };
