/**
 * The tag cloud's drawn icons, tinted: the two editing icons of a renamable tag (iOS "square.and.pencil" and "xmark", in
 * a horizontal `CYLAnimatedItemStackView`) and the section header's clear button (the core's `cyl_trash`). A Mini
 * Program `<image>` cannot tint a file, so each icon is an SVG in a data URI drawn in the color asked for.
 */

const BASE64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

/** Base64 of an ASCII string (the Mini Program runtime has no `btoa`). */
function base64(text) {
  let out = '';
  for (let i = 0; i < text.length; i += 3) {
    const a = text.charCodeAt(i);
    const b = i + 1 < text.length ? text.charCodeAt(i + 1) : NaN;
    const c = i + 2 < text.length ? text.charCodeAt(i + 2) : NaN;
    const n = (a << 16) | ((b || 0) << 8) | (c || 0);
    out += BASE64[(n >> 18) & 63] + BASE64[(n >> 12) & 63];
    out += Number.isNaN(b) ? '=' : BASE64[(n >> 6) & 63];
    out += Number.isNaN(c) ? '=' : BASE64[n & 63];
  }
  return out;
}

const PATHS = {
  // A square with a pencil across its top right corner (iOS "square.and.pencil").
  rename: '<path d="M11 4H5.5A1.5 1.5 0 0 0 4 5.5v13A1.5 1.5 0 0 0 5.5 20h13a1.5 1.5 0 0 0 1.5-1.5V13"/>'
    + '<path d="M18.4 3.6a2 2 0 0 1 2.9 2.9L12 15.8l-3.8 1 1-3.8z"/>',
  // A cross (iOS "xmark").
  delete: '<path d="M5 5l14 14M19 5L5 19"/>',
  // A trash can (the core's cyl_trash).
  clear: '<path d="M4 6.5h16M9.5 6.5V4.5h5v2M6.5 6.5l1 13h9l1-13M10.2 10v6.5M13.8 10v6.5"/>',
};

/** The icon `kind` ('rename', 'delete' or 'clear') as a data URI, stroked in `color`. */
function iconImage(kind, color) {
  const stroke = String(color || '#000000').replace(/"/g, '');
  const svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="' + stroke + '" '
    + 'stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">' + PATHS[kind] + '</svg>';
  return 'data:image/svg+xml;base64,' + base64(svg);
}

module.exports = { iconImage, base64 };
