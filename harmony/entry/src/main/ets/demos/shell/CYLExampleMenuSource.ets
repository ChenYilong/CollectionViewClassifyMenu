/**
 * A plain data source for the example's tag lists: sections of items (iOS CYLExampleMenuSource.swift).
 */
import { CYLImage, CYLIndexPath, CYLMenuDataSource } from '@cyl/classifymenu';

export class CYLExampleMenuItem {
  title: string;
  image?: CYLImage;
  selectedImage?: CYLImage;
  isEnabled: boolean = true;
  isExclusive: boolean = false;
  /** Free-form value for the host, such as a filter. */
  value?: Object;

  constructor(title: string) {
    this.title = title;
  }
}

export class CYLExampleMenuSection {
  title: string;
  image?: CYLImage;
  items: CYLExampleMenuItem[];

  constructor(title: string, items: CYLExampleMenuItem[]) {
    this.title = title;
    this.items = items;
  }

  /** One plain item per title. */
  static withTitles(title: string, titles: string[]): CYLExampleMenuSection {
    return new CYLExampleMenuSection(title, titles.map((t: string) => new CYLExampleMenuItem(t)));
  }
}

export class CYLExampleMenuSource implements CYLMenuDataSource {
  sections: CYLExampleMenuSection[];

  constructor(sections: CYLExampleMenuSection[]) {
    this.sections = sections;
  }

  item(indexPath: CYLIndexPath): CYLExampleMenuItem {
    return this.sections[indexPath.section].items[indexPath.item];
  }

  numberOfSectionsInMenu(): number {
    return this.sections.length;
  }

  menuNumberOfItemsInSection(section: number): number {
    return this.sections[section].items.length;
  }

  menuTitleForSection(section: number): string {
    return this.sections[section].title;
  }

  menuTitleForItem(indexPath: CYLIndexPath): string {
    return this.item(indexPath).title;
  }

  menuImageForItem: (indexPath: CYLIndexPath) => CYLImage | undefined =
    (indexPath: CYLIndexPath) => this.item(indexPath).image;
  menuSelectedImageForItem: (indexPath: CYLIndexPath) => CYLImage | undefined =
    (indexPath: CYLIndexPath) => this.item(indexPath).selectedImage;
  menuImageForSection: (section: number) => CYLImage | undefined = (section: number) => this.sections[section].image;
  menuItemIsEnabled: (indexPath: CYLIndexPath) => boolean = (indexPath: CYLIndexPath) => this.item(indexPath).isEnabled;
  menuItemIsExclusive: (indexPath: CYLIndexPath) => boolean =
    (indexPath: CYLIndexPath) => this.item(indexPath).isExclusive;
}
