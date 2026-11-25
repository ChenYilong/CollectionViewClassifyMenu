'use strict';

// The fold control's fourth content "titleAndIcon" (configuration string "titleAndIconAlways"): the title and the chevron in
// both states ("More v" folded, "Less ^" expanded). Written statically, not yet run (docs/tag-section-style.md).
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const model = require('cyl-tag-list-miniprogram/cyl-tag-list/model.js');

const DIR = path.join(__dirname, '..', 'packages', 'cyl-tag-list-miniprogram', 'miniprogram_dist', 'cyl-tag-list');
const WXML = fs.readFileSync(path.join(DIR, 'cyl-tag-list.wxml'), 'utf8');
const WXSS = fs.readFileSync(path.join(DIR, 'cyl-tag-list.wxss'), 'utf8');

test('the configuration string "titleAndIconAlways" is the content titleAndIcon, in any case', () => {
  assert.equal(model.foldControlValue({ position: 'tail', content: 'titleAndIconAlways' }).content, 'titleAndIcon');
  assert.equal(model.foldControlValue({ position: 'footer', content: 'TitleAndIconAlways' }).content, 'titleAndIcon');
  assert.equal(model.foldControlValue({ position: 'headerTrailing', content: 'titleandiconalways' }).content, 'titleAndIcon');
});

test('the old aliases and the other contents keep their meaning', () => {
  assert.equal(model.foldControlValue({ position: 'tail', content: 'titleAndIcon' }).content, 'iconAndTitle');
  assert.equal(model.foldControlValue({ position: 'tail', content: 'iconAndTitle' }).content, 'iconAndTitle');
  assert.equal(model.foldControlValue({ position: 'tail', content: 'icon' }).content, 'icon');
  assert.equal(model.foldControlValue({ position: 'tail', content: 'title' }).content, 'title');
  // Unset: the tail and the footer show the icon only, the header icon and title.
  assert.equal(model.foldControlValue('tail').content, 'icon');
  assert.equal(model.foldControlValue('headerTrailing').content, 'iconAndTitle');
});

test('custom title and collapseTitle are kept with titleAndIconAlways', () => {
  const control = model.foldControlValue({ position: 'tail', content: 'titleAndIconAlways', title: 'More', collapseTitle: 'Less' });
  assert.equal(control.title, 'More');
  assert.equal(control.collapseTitle, 'Less');
});

test('the folded title is the expand title and the expanded one the collapse title', () => {
  assert.equal(model.foldTitle(false), model.EXPAND_TITLE);
  assert.equal(model.foldTitle(true), model.COLLAPSE_TITLE);
  assert.equal(model.FOLD_CONTENT_TITLE_AND_ICON, 'titleAndIcon');
});

test('the control is sized by the longer of the two titles', () => {
  assert.equal(model.longerFoldTitle('More', 'Less'), 'More');
  assert.equal(model.longerFoldTitle('More', 'Collapse'), 'Collapse');
  assert.equal(model.longerFoldTitle('Expand all', 'Hide'), 'Expand all');
});

test('the header, footer and tail controls show the title and the chevron for titleAndIcon, with a hidden sizer', () => {
  assert.equal(WXML.split("foldContent === 'titleAndIcon'").length - 1, 3);
  assert.equal(WXML.split('class="cyl-fold-sizer"').length - 1, 3);
  // The chevron shows for every content but title; the plain title for title and iconAndTitle only.
  assert.equal(WXML.split("foldContent !== 'title'").length - 1, 3);
  assert.ok(!WXML.includes("foldContent !== 'icon'"));
  assert.match(WXSS, /\.cyl-fold-sizer \{[^}]*visibility: hidden/);
});

test('the header fold control shows only on foldable sections and reserves no header space on an unfoldable one', () => {
  assert.match(WXML, /wx:if="\{\{section\.canFold && foldPosition === 'headerTrailing'\}\}" class="cyl-fold-header"/);
  // The header itself shows for a title, or for a foldable section (never only for an unfoldable section's control).
  assert.match(WXML, /<view wx:if="\{\{section\.showsHeader \|\| \(section\.canFold && foldPosition === 'headerTrailing'\)\}\}" class="cyl-header"/);
});

test('the header fold control is at most 40% of the header and its font is capped; the section title truncates', () => {
  assert.equal(model.FOLD_HEADER_MAX_WIDTH_PERCENT, 40);
  assert.equal(model.foldHeaderWidthCSS(), 'max-width: 40%');
  assert.match(WXML, /class="cyl-fold-header" style="[^"]*\{\{foldFontStyle\}\}; \{\{foldHeaderStyle\}\};"/);
  assert.equal(model.foldControlFontCSS(), `font-size: min(${model.FOLD_CONTROL_FONT_SIZE}px, ${model.FOLD_CONTROL_MAX_FONT_SIZE}px)`);
  assert.match(WXSS, /\.cyl-header-title \{[^}]*overflow: hidden; text-overflow: ellipsis; white-space: nowrap/);
  assert.match(WXSS, /\.cyl-header-title \{ flex: 0 1 auto; min-width: 0; \}/);
});
