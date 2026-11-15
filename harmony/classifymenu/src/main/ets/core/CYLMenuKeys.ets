/**
 * The keys of a classify-menu data source's dictionaries, as iOS `CYLMenuKeys.swift` (data.json: `Items`,
 * `Item_Title`, `Picture`).
 */
export const kDataSourceSectionKey: string = 'Items';
export const kDataSourceCellTextKey: string = 'Item_Title';
export const kDataSourceCellPictureKey: string = 'Picture';

/** The same keys as static members, as iOS `CYLMenuKeys`. */
export class CYLMenuKeys {
  static readonly dataSourceSectionKey: string = kDataSourceSectionKey;
  static readonly dataSourceCellTextKey: string = kDataSourceCellTextKey;
  static readonly dataSourceCellPictureKey: string = kDataSourceCellPictureKey;
}
