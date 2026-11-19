/**
 * The key of the filter settings in `CYLFilterParamsTool.filterParamsDictionary` (iOS / Android `kMultipleFilterSetting`).
 */
export const kMultipleFilterSetting: string = 'kMultipleFilterSetting';

/**
 * The key of the "modified" flag in `CYLFilterParamsTool.filterParamsDictionary` (`kMultipleFilterSettingModified`).
 */
export const kMultipleFilterSettingModified: string = 'kMultipleFilterSettingModified';

/**
 * `CYLFilterParamsTool`: the state of the multiple filter, the titles per section (`dataSources`) and a selected flag per
 * item (`filterParamsArray`, the first item of each section selected by default). Every value is made on first use and
 * can be replaced, as on iOS and Android.
 */
export class CYLFilterParamsTool {
  /** The titles, one array per section. */
  dataSources: string[][] = [];
  /** The folder `filename` defaults to (an app sets its context's `filesDir`; Android `filesDir`). */
  filesDir: string = '';

  private storedFilterParamsArray?: boolean[][];
  private storedFilterParamsDictionary?: Record<string, Object>;
  private storedFilterParamsContentDictionary?: Record<string, Object>;
  private storedFilename?: string;

  /** One selected flag per item; made from `dataSources` on first use, with the first item of each section selected. */
  get filterParamsArray(): boolean[][] {
    if (this.storedFilterParamsArray === undefined) {
      this.storedFilterParamsArray = this.dataSources.map((section: string[]) =>
        section.map((title: string, index: number) => index === 0));
    }
    return this.storedFilterParamsArray;
  }

  set filterParamsArray(value: boolean[][]) {
    this.storedFilterParamsArray = value;
  }

  /** The settings (`kMultipleFilterSetting`: `filterParamsArray`) and the modified flag (false), made on first use. */
  get filterParamsDictionary(): Record<string, Object> {
    if (this.storedFilterParamsDictionary === undefined) {
      const made: Record<string, Object> = {};
      made[kMultipleFilterSettingModified] = false;
      made[kMultipleFilterSetting] = this.filterParamsArray;
      this.storedFilterParamsDictionary = made;
    }
    return this.storedFilterParamsDictionary;
  }

  set filterParamsDictionary(value: Record<string, Object>) {
    this.storedFilterParamsDictionary = value;
  }

  /** Free-form content of the filter; `{ skilled: [] }` by default, as the original. */
  get filterParamsContentDictionary(): Record<string, Object> {
    if (this.storedFilterParamsContentDictionary === undefined) {
      const made: Record<string, Object> = {};
      made['skilled'] = [] as Object[];
      this.storedFilterParamsContentDictionary = made;
    }
    return this.storedFilterParamsContentDictionary;
  }

  set filterParamsContentDictionary(value: Record<string, Object>) {
    this.storedFilterParamsContentDictionary = value;
  }

  /** Where the settings are archived: `<filesDir>/kMultipleFilterSetting` by default (iOS: the Documents folder). */
  get filename(): string {
    if (this.storedFilename !== undefined) {
      return this.storedFilename;
    }
    return this.filesDir.length > 0 ? `${this.filesDir}/${kMultipleFilterSetting}` : kMultipleFilterSetting;
  }

  set filename(value: string) {
    this.storedFilename = value;
  }
}
