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
  // The footer and the tail show the box for titleAndIcon only; the header shows it for every text content (title room does not change when toggled).
  assert.equal(WXML.split("foldContent === 'titleAndIcon'").length - 1, 2);
  assert.equal(WXML.split("foldContent !== 'icon'").length - 1, 1);
  assert.equal(WXML.split('class="cyl-fold-sizer"').length - 1, 3);
  // The chevron shows for every content but title; the plain title for title and iconAndTitle only.
  assert.equal(WXML.split("foldContent !== 'title'").length - 1, 3);
  assert.match(WXSS, /\.cyl-fold-sizer \{[^}]*visibility: hidden/);
});

test('the header fold control shows only on foldable sections and reserves no header space on an unfoldable one', () => {
  assert.match(WXML, /wx:if="\{\{section\.canFold && foldPosition === 'headerTrailing'\}\}" class="cyl-fold-header"/);
  // The header itself shows for a title, or for a foldable section (never only for an unfoldable section's control).
  assert.match(WXML, /<view wx:if="\{\{section\.showsHeader \|\| \(section\.canFold && foldPosition === 'headerTrailing'\)\}\}" class="cyl-header"/);
});

test('the header fold control is at most 40% of the header and its font is capped; the section title truncates', () => {
  assert.equal(model.HEADER_FOLD_ALONE_MAX_FRACTION, 0.4);
  assert.equal(model.HEADER_FOLD_SHARED_MAX_FRACTION, 0.3);
  assert.equal(model.foldHeaderWidthCSS(), `flex: none; max-width: 40%; margin-left: ${model.HEADER_ITEM_SPACING}px; margin-right: 0`);
  assert.equal(model.foldHeaderWidthCSS({ shared: true }), `flex: none; max-width: 30%; margin-left: ${model.HEADER_ITEM_SPACING}px; margin-right: 0`);
  assert.match(WXML, /class="cyl-fold-header" style="[^"]*\{\{foldFontStyle\}\}; \{\{foldHeaderStyle\}\};"/);
  assert.equal(model.foldControlFontCSS(), `font-size: min(${model.FOLD_CONTROL_FONT_SIZE}px, ${model.FOLD_CONTROL_MAX_FONT_SIZE}px)`);
  assert.match(WXSS, /\.cyl-header-title \{[^}]*overflow: hidden; text-overflow: ellipsis; white-space: nowrap/);
  // The title is the view that shrinks (never below one em); the fold control never shrinks.
  assert.match(WXSS, /\.cyl-header-title \{ flex: 0 1 auto; min-width: 1em; \}/);
  assert.match(WXSS, /\.cyl-fold-header \{[^}]*flex: none;/);
  assert.equal(model.HEADER_TITLE_MIN_EM, 1);
});

// The header room model: pure functions of the inner width and the parts present (docs/tag-section-style.md). Written statically.
const LIST_WIDTH = 400;
const COLLAPSED_WIDTH = 50;
const EXPANDED_WIDTH = 120;
const NATURAL_NARROW = 60;
const NATURAL_WIDE = 300;
const MORE_WIDTH = 40;
const CLEAR_WIDTH = 24;
const ACCESSORY_WIDTH = 60;
const TITLE_TEXT_WIDTH = 700;
const CLOSE = 1e-9;
const near = (actual, expected) => assert.ok(Math.abs(actual - expected) < CLOSE, `${actual} vs ${expected}`);
const styleOf = (style = {}) => model.normalize({ style, sections: [{ title: 'T', items: ['a'] }] }, { pixelRatio: 2 }).sections[0].style;

test('room 1: no fold control, the title room is the inner width', () => {
  const style = styleOf();
  const inner = model.headerInnerWidth(style, LIST_WIDTH);
  const edges = model.headerEdges(style);
  assert.equal(inner, LIST_WIDTH - edges.left - edges.right);
  assert.equal(model.headerTitleMaxWidth(style, inner), inner);
  assert.equal(model.headerTitleMaxWidth(style, inner, []), inner);
});

test('room 2: fold control only, room = inner - fold width - spacing, fold width <= 0.4 x inner', () => {
  const style = styleOf();
  const inner = model.headerInnerWidth(style, LIST_WIDTH);
  const fold = model.headerFoldWidth(inner, NATURAL_NARROW, NATURAL_WIDE);
  assert.equal(fold, model.HEADER_FOLD_ALONE_MAX_FRACTION * inner);
  assert.ok(fold <= model.HEADER_FOLD_ALONE_MAX_FRACTION * inner);
  near(model.headerTitleMaxWidth(style, inner, [fold]), inner - fold - model.HEADER_ITEM_SPACING);
  // A control narrower than the cap keeps its natural (wider-state) width.
  const small = model.headerFoldWidth(inner, COLLAPSED_WIDTH, EXPANDED_WIDTH);
  assert.equal(small, EXPANDED_WIDTH);
  near(model.headerTitleMaxWidth(style, inner, [small]), inner - EXPANDED_WIDTH - model.HEADER_ITEM_SPACING);
});

test('room 3: fold + More + clear + accessory fit the inner width with their gaps; the fold is at most 0.3 x inner', () => {
  const style = styleOf();
  const inner = model.headerInnerWidth(style, LIST_WIDTH);
  const fold = model.headerFoldWidth(inner, NATURAL_NARROW, NATURAL_WIDE, true);
  assert.equal(fold, model.HEADER_FOLD_SHARED_MAX_FRACTION * inner);
  const parts = [fold, MORE_WIDTH, CLEAR_WIDTH, ACCESSORY_WIDTH];
  const room = model.headerTitleMaxWidth(style, inner, parts);
  const total = room + parts.reduce((a, b) => a + b, 0) + model.HEADER_ITEM_SPACING * parts.length;
  assert.ok(room > style.headerFont.size);
  assert.ok(total <= inner + CLOSE);
  // The title ends one spacing before the fold control starts.
  near(room + model.HEADER_ITEM_SPACING, inner - parts.reduce((a, b) => a + b, 0) - model.HEADER_ITEM_SPACING * (parts.length - 1));
});

test('room 3b: the title keeps one em when the fixed parts leave no room', () => {
  const style = styleOf();
  assert.equal(model.headerTitleMaxWidth(style, 100, [200]), style.headerFont.size * model.HEADER_TITLE_MIN_EM);
});

test('room 4: collapsed and expanded give the same fold width and the same title room', () => {
  const style = styleOf();
  const inner = model.headerInnerWidth(style, LIST_WIDTH);
  const fold = model.headerFoldWidth(inner, COLLAPSED_WIDTH, EXPANDED_WIDTH);
  assert.equal(fold, model.headerFoldWidth(inner, EXPANDED_WIDTH, COLLAPSED_WIDTH));
  const swapped = model.headerFoldWidth(inner, EXPANDED_WIDTH, COLLAPSED_WIDTH);
  assert.equal(model.headerTitleMaxWidth(style, inner, [fold]), model.headerTitleMaxWidth(style, inner, [swapped]));
  // The header renders the hidden sizer (the wider title) for every text content, so the DOM keeps this one width.
  assert.match(WXML, /<view wx:if="\{\{foldContent !== 'icon'\}\}" class="cyl-fold-title-box">/);
});

test('room 5: headerMaxLines 2 and unlimited grow the header by the line count at the room width', () => {
  const unlimited = model.HEADER_TITLE_MAX_LINES.unlimited;
  const inner = model.headerInnerWidth(styleOf(), LIST_WIDTH);
  const fold = model.headerFoldWidth(inner, COLLAPSED_WIDTH, EXPANDED_WIDTH);
  const room = model.headerTitleMaxWidth(styleOf(), inner, [fold]);
  const lines2 = model.headerTitleLines(TITLE_TEXT_WIDTH, room, 2);
  const linesAll = model.headerTitleLines(TITLE_TEXT_WIDTH, room, unlimited);
  assert.equal(lines2, 2);
  assert.equal(linesAll, Math.ceil(TITLE_TEXT_WIDTH / room));
  assert.ok(linesAll > lines2);
  const line = model.lineHeight(styleOf().headerFont.size);
  // Plain style with a divider keeps the fixed minimum; compare two wrapping headers a whole number of lines apart.
  const wrap = (maxLines) => styleOf({ headerMaxLines: maxLines, headerSeparatorStyle: 'line' });
  const heightAt = (maxLines, lines) => model.headerHeightForLines(wrap(maxLines), lines);
  assert.equal(heightAt(unlimited, linesAll + 1) - heightAt(unlimited, linesAll), line);
  assert.equal(heightAt(unlimited, linesAll) - heightAt(unlimited, linesAll - 1), line);
  assert.equal(heightAt(2, lines2), 2 * line + 2 * model.HEADER_WRAP_VERTICAL_PADDING);
  // A one-line default header keeps headerHeightOf exactly.
  assert.equal(model.headerHeightForLines(styleOf({ headerSeparatorStyle: 'line' }), 1), model.headerHeightOf(styleOf({ headerSeparatorStyle: 'line' })));
});

test('room 6: the header fold control mirrors its margin right to left', () => {
  const rtl = model.foldHeaderWidthCSS({ rtl: true });
  assert.equal(rtl, `flex: none; max-width: 40%; margin-right: ${model.HEADER_ITEM_SPACING}px; margin-left: 0`);
  assert.equal(model.foldHeaderWidthCSS({ rtl: true, shared: true }), `flex: none; max-width: 30%; margin-right: ${model.HEADER_ITEM_SPACING}px; margin-left: 0`);
  // The inner width is the same mirrored: the leading and trailing edges swap, their sum does not.
  const ltrInner = model.headerInnerWidth(styleOf({ sectionContentInsets: [0, 4, 0, 20] }), LIST_WIDTH);
  const rtlInner = model.headerInnerWidth(styleOf({ direction: 'rtl', sectionContentInsets: [0, 4, 0, 20] }), LIST_WIDTH);
  assert.equal(ltrInner, rtlInner);
});

test('room 7: a default single-line header with a short title is unchanged (no wrapping CSS, same height)', () => {
  const style = styleOf();
  const layout = model.sectionLayout(style);
  assert.equal(layout.headerTitleStyle, undefined);
  assert.equal(model.headerHeightForLines(style, 1), model.headerHeightOf(style));
  // The 12 px spacing is what the control's padding was: the control's text sits where it did.
  assert.equal(model.HEADER_ITEM_SPACING, 12);
});
