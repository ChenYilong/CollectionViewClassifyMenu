/**
 * The configuration of a tag list, the same JSON as the Flutter and React Native components (docs/cross-platform.md).
 */
export type CYLSelectionMode = 'none' | 'single' | 'multiple';

export interface CYLIndexPath {
  section: number;
  item: number;
}

export interface CYLTagItem {
  title: string;
  image?: string;
  /** A Lottie animation shown before the title: `asset:<path>` (a rawfile of the app) or the JSON text. */
  animation?: string;
  /** An item that clears the other selected items of its section (the "全部" of a filter). */
  exclusive?: boolean;
}

export interface CYLTagSection {
  title?: string;
  items: CYLTagItem[];
}

export interface CYLTagStateStyle {
  textColor: string;
  backgroundColor: string;
  borderColor: string;
  borderWidth: number;
  cornerRadius: number;
}

export interface CYLTagStyle {
  itemHeight: number;
  fontSize: number;
  spacing: number;
  /** The side of an animated icon, in vp (`imageSize` "{w, h}" of the shared configuration: its width). */
  imageSize: number;
  normal: CYLTagStateStyle;
  selected: CYLTagStateStyle;
}

export interface CYLTagListConfiguration {
  selectionMode: CYLSelectionMode;
  /** Rows of tags shown per section before the fold control; 0 shows every row. */
  defaultVisibleRows: number;
  sections: CYLTagSection[];
  selected: CYLIndexPath[];
  style: CYLTagStyle;
}

export interface CYLTagTap {
  section: number;
  item: number;
  title: string;
}

function str(value: Object | undefined | null, fallback: string): string {
  return typeof value === 'string' ? value as string : fallback;
}

function num(value: Object | undefined | null, fallback: number): number {
  return typeof value === 'number' ? value as number : fallback;
}

function stateStyle(raw: Record<string, Object> | undefined, base: CYLTagStateStyle): CYLTagStateStyle {
  if (raw === undefined) {
    return base;
  }
  return {
    textColor: str(raw['textColor'], base.textColor),
    backgroundColor: str(raw['backgroundColor'], base.backgroundColor),
    borderColor: str(raw['borderColor'], base.borderColor),
    borderWidth: num(raw['borderWidth'], base.borderWidth),
    cornerRadius: num(raw['cornerRadius'], base.cornerRadius)
  };
}

const NORMAL: CYLTagStateStyle = {
  textColor: '#333333', backgroundColor: '#FFFFFF', borderColor: '#D1D1D6', borderWidth: 1, cornerRadius: 4
};
const SELECTED: CYLTagStateStyle = {
  textColor: '#2AB9A0', backgroundColor: '#E6F8F5', borderColor: '#2AB9A0', borderWidth: 1, cornerRadius: 4
};

function imageSide(value: Object | undefined): number {
  if (typeof value === 'number') {
    return value as number;
  }
  const match = typeof value === 'string' ? (value as string).match(/[\d.]+/) : null;
  return match !== null ? Number(match[0]) : 18;
}

/**
 * Plays the animated icons of a `CYLTagListView` again; pass it as the view's `controller`.
 */
export class CYLTagListController {
  private handler?: () => void;

  /** Called by the view it is passed to. */
  attach(handler: () => void): void {
    this.handler = handler;
  }

  /** Plays every animated icon of the list from progress 0. */
  playAll(): void {
    this.handler?.();
  }
}

/** Reads a configuration from its JSON text or object; unknown keys are ignored, missing ones take defaults. */
export function parseConfiguration(json: string | Record<string, Object>): CYLTagListConfiguration {
  const raw: Record<string, Object> = typeof json === 'string' ? JSON.parse(json) as Record<string, Object> : json;
  const mode = str(raw['selectionMode'], 'none');
  const style = (raw['style'] ?? {}) as Record<string, Object>;
  const normal = stateStyle(style['normal'] as Record<string, Object> | undefined, NORMAL);
  const sections = ((raw['sections'] ?? []) as Record<string, Object>[]).map((section): CYLTagSection => ({
    title: section['title'] as string | undefined,
    items: ((section['items'] ?? []) as Record<string, Object>[]).map((item): CYLTagItem => ({
      title: str(item['title'], ''),
      image: item['image'] as string | undefined,
      animation: item['animation'] as string | undefined,
      exclusive: item['exclusive'] === true
    }))
  }));
  const selected = ((raw['selected'] ?? []) as Record<string, Object>[]).map((path): CYLIndexPath => ({
    section: num(path['section'], 0), item: num(path['item'], 0)
  }));
  return {
    selectionMode: mode === 'single' || mode === 'multiple' ? mode : 'none',
    defaultVisibleRows: num(raw['defaultVisibleRows'], 0),
    sections: sections,
    selected: selected,
    style: {
      itemHeight: num(style['itemHeight'], 32),
      fontSize: num(style['fontSize'], 14),
      spacing: num(style['spacing'], 8),
      imageSize: imageSide(style['imageSize']),
      normal: normal,
      selected: stateStyle(style['selected'] as Record<string, Object> | undefined, SELECTED)
    }
  };
}

/**
 * The selected items of a tag list. Single: one item, tapping it again clears it. Multiple: any items; an exclusive
 * item clears its section's other items, and any other item clears the section's exclusive items.
 */
export class CYLTagSelection {
  private items: CYLIndexPath[] = [];
  private mode: CYLSelectionMode;
  private sections: CYLTagSection[];

  constructor(mode: CYLSelectionMode, sections: CYLTagSection[], initial: CYLIndexPath[] = []) {
    this.mode = mode;
    this.sections = sections;
    initial.forEach((path) => this.toggle(path));
  }

  get selected(): CYLIndexPath[] {
    return this.items.slice();
  }

  isSelected(path: CYLIndexPath): boolean {
    return this.items.some((p) => p.section === path.section && p.item === path.item);
  }

  /** Applies a tap; returns whether the selection changed. */
  toggle(path: CYLIndexPath): boolean {
    if (this.mode === 'none') {
      return false;
    }
    if (this.isSelected(path)) {
      this.items = this.items.filter((p) => !(p.section === path.section && p.item === path.item));
      return true;
    }
    if (this.mode === 'single') {
      this.items = [path];
      return true;
    }
    const exclusive = this.sections[path.section]?.items[path.item]?.exclusive === true;
    this.items = this.items.filter((p) => {
      if (p.section !== path.section) {
        return true;
      }
      const other = this.sections[p.section]?.items[p.item]?.exclusive === true;
      return exclusive ? false : !other;
    });
    this.items.push(path);
    return true;
  }

  clear(): void {
    this.items = [];
  }
}

/** The height of a section folded to `rows` rows of tags; 0 rows means unfolded (no limit). */
export function foldedHeight(rows: number, itemHeight: number, spacing: number): number {
  return rows <= 0 ? -1 : rows * itemHeight + (rows - 1) * spacing;
}
