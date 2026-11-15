/**
 * What the three Android sample ports share (CYLAndroidSampleSupport.swift): the toast's duration, the buttons'
 * colors and the pictures of the TagViewGroup sample (images/samples/picture-<n>.jpg, drawn by
 * scripts/draw-sample-images.py as `CYLAndroidSample.picture(_:)` draws them: a diagonal gradient and a large
 * white symbol — shoes, a bag, a shirt). No `wx` calls.
 */
const { t } = require('./i18n.js');

/** Android's Toast.LENGTH_SHORT, as `CYLAndroidSample.toast`. */
const TOAST_DURATION = 2000;
/** The toast's fade-out. */
const TOAST_FADE = 250;

/** The UIKit colors of the samples' buttons. */
const COLORS = { systemPink: '#FF2D55', systemOrange: '#FF9500', systemGray: '#8E8E93', blue: '#00BFFF' };

/** The pictures: their file and the label VoiceOver reads (the image's accessibilityLabel). */
const PICTURES = [
  { src: '/images/samples/picture-0.jpg', label: '鞋子图片' },
  { src: '/images/samples/picture-1.jpg', label: '包图片' },
  { src: '/images/samples/picture-2.jpg', label: '衣服图片' },
];

/** `CYLAndroidSample.picture(_:)`: `index` chooses the colors and the symbol. */
function picture(index) {
  const entry = PICTURES[((index % PICTURES.length) + PICTURES.length) % PICTURES.length];
  return { src: entry.src, label: t(entry.label) };
}

module.exports = { TOAST_DURATION, TOAST_FADE, COLORS, PICTURES, picture };
