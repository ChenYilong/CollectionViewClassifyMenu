/**
 * Stand-ins for the SF Symbols the examples use (`image: "system:<name>"`), drawn as SVG so that they are tinted like
 * template images (`iconColor` of the state, else its text color), as `UIImage(systemName:)` is on iOS. A Mini Program
 * has no SF Symbols; these are simple 24 × 24 drawings of the same shapes. Names without a drawing fall back to an
 * emoji (GLYPHS), as before. No `wx` calls: the tests run it under Node.
 */

const STROKE = 'fill="none" stroke="C" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"';
const FILL = 'fill="C"';

const HOUSE_FILL = 'M12 3 2.6 11.1l1.2 1.4L5 11.5v9h5V15h4v5.5h5v-9l1.2 1 1.2-1.4z';
const BUBBLE = 'M12 4c-5 0-9 3.1-9 7 0 2.2 1.2 4.1 3.1 5.4L5.2 20l4.1-2.1c.9.2 1.8.3 2.7.3 5 0 9-3.1 9-7s-4-7.2-9-7.2z';
const STAR = 'M12 2.8l2.8 6 6.5.7-4.9 4.4 1.4 6.5L12 17.1l-5.8 3.3 1.4-6.5-4.9-4.4 6.5-.7z';
const HEART = 'M12 20.3s-8.3-5-8.3-10.8A4.6 4.6 0 0 1 12 6.8a4.6 4.6 0 0 1 8.3 2.7c0 5.8-8.3 10.8-8.3 10.8z';
const PERSON_HEAD = 'M12 4.2a3.8 3.8 0 1 1 0 7.6 3.8 3.8 0 0 1 0-7.6z';
const PERSON_BODY = 'M4.5 20.3c0-3.9 3.4-6.3 7.5-6.3s7.5 2.4 7.5 6.3z';
const SPARKLE = 'M10 3.2l1.7 5.1 5.1 1.7-5.1 1.7L10 16.8l-1.7-5.1L3.2 10l5.1-1.7z';

/** name -> the SVG content, "C" standing for the color. */
const DRAWINGS = {
  house: `<path ${STROKE} d="M3.2 11.4 12 3.8l8.8 7.6M5.6 9.6v10.6H10v-5.5h4v5.5h4.4V9.6"/>`,
  'house.fill': `<path ${FILL} d="${HOUSE_FILL}"/>`,
  'mappin.and.ellipse': `<g ${STROKE}><circle cx="12" cy="7.8" r="4.2"/><path d="M12 12v6"/><ellipse cx="12" cy="18.6" rx="7.5" ry="2.6"/></g>`,
  'mappin.circle.fill': '<mask id="m"><rect width="24" height="24" fill="#fff"/><circle cx="12" cy="9.4" r="3" fill="#000"/>'
    + '<path d="M12 12v5.2" stroke="#000" stroke-width="1.8" stroke-linecap="round"/></mask>'
    + `<circle ${FILL} cx="12" cy="12" r="10" mask="url(#m)"/>`,
  message: `<path ${STROKE} d="${BUBBLE}"/>`,
  'message.fill': `<path ${FILL} d="${BUBBLE}"/>`,
  person: `<g ${STROKE}><path d="${PERSON_HEAD}"/><path d="${PERSON_BODY}"/></g>`,
  'person.fill': `<g ${FILL}><path d="${PERSON_HEAD}"/><path d="${PERSON_BODY}"/></g>`,
  star: `<path ${STROKE} d="${STAR}"/>`,
  'star.fill': `<path ${FILL} d="${STAR}"/>`,
  nosign: `<g ${STROKE}><circle cx="12" cy="12" r="8.6"/><path d="M5.9 5.9l12.2 12.2"/></g>`,
  heart: `<path ${STROKE} d="${HEART}"/>`,
  'heart.fill': `<path ${FILL} d="${HEART}"/>`,
  sparkles: `<path ${STROKE} d="${SPARKLE}"/>`
    + `<path ${FILL} d="M18.2 13.6l.9 2.2 2.2.9-2.2.9-.9 2.2-.9-2.2-2.2-.9 2.2-.9zM18 2.6l.7 1.7 1.7.7-1.7.7-.7 1.7-.7-1.7-1.7-.7 1.7-.7z"/>`,
  'play.circle': `<circle ${STROKE} cx="12" cy="12" r="9"/><path ${FILL} d="M10 8.2v7.6l6-3.8z"/>`,
  'play.fill': `<path ${FILL} d="M7 4.6v14.8c0 .8.9 1.3 1.6.9l11.6-7.4c.6-.4.6-1.3 0-1.7L8.6 3.7C7.9 3.3 7 3.8 7 4.6z"/>`,
  'circle.hexagongrid': `<g ${FILL}>${[[12, 12], [12, 6], [12, 18], [6.8, 9], [17.2, 9], [6.8, 15], [17.2, 15]]
    .map(([x, y]) => `<circle cx="${x}" cy="${y}" r="2.2"/>`).join('')}</g>`,
  photo: `<g ${STROKE}><rect x="3" y="5" width="18" height="14" rx="2.2"/><path d="M3.8 17.2l5-5 4 4 2.8-2.8 4.6 4.6"/></g>`
    + `<circle ${FILL} cx="15.5" cy="9.3" r="1.6"/>`,
  magnifyingglass: `<g ${STROKE}><circle cx="10.4" cy="10.4" r="6.2"/><path d="M15 15l5.6 5.6"/></g>`,
};

/** Emoji stand-ins for the names without a drawing (they keep their own colors). */
const GLYPHS = {
  house: '🏠', magnifyingglass: '🔍', message: '💬', person: '👤', star: '⭐', gearshape: '⚙️',
  camera: '📷', 'music.note': '🎵', map: '🗺️', calendar: '📅',
};

const BASE64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

/** Base64 of an ASCII string (a Mini Program has no btoa). */
function base64(text) {
  let out = '';
  for (let i = 0; i < text.length; i += 3) {
    const a = text.charCodeAt(i);
    const b = i + 1 < text.length ? text.charCodeAt(i + 1) : NaN;
    const c = i + 2 < text.length ? text.charCodeAt(i + 2) : NaN;
    const n = (a << 16) | ((b || 0) << 8) | (c || 0);
    out += BASE64[(n >> 18) & 63] + BASE64[(n >> 12) & 63]
      + (Number.isNaN(b) ? '=' : BASE64[(n >> 6) & 63]) + (Number.isNaN(c) ? '=' : BASE64[n & 63]);
  }
  return out;
}

function hasSymbol(name) {
  return Object.prototype.hasOwnProperty.call(DRAWINGS, name);
}

/** The symbol tinted with `color` as an SVG data URI, or '' when there is no drawing for it. */
function symbolURI(name, color) {
  if (!hasSymbol(name)) return '';
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">${DRAWINGS[name].replace(/"C"/g, `"${color}"`)}</svg>`;
  return `data:image/svg+xml;base64,${base64(svg)}`;
}

function glyph(name) {
  return GLYPHS[name] || '•';
}

module.exports = { DRAWINGS, GLYPHS, base64, hasSymbol, symbolURI, glyph };
