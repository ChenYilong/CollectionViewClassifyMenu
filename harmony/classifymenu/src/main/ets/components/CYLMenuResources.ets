/*
 * CYLMenuResources.ets
 * The core module's localized strings (resources/<locale>/element/string.json: base, en_US, zh_CN, zh_TW), the
 * HarmonyOS counterpart of the iOS core's CYLClassifyMenuResources.bundle and CYLMenuLocalizedString.
 */
import { i18n } from '@kit.LocalizationKit';

/**
 * The core's resource lookups. Keys are the iOS table's, prefixed `cyl_menu_` (a HAR's resources join the app's
 * resource table, so the prefix keeps them apart from the app's own names).
 */
export class CYLMenuResources {
  /**
   * The string of `key` in the system language, or `key` itself when it is missing.
   */
  static localizedString(context: Context, key: string): string {
    try {
      return context.resourceManager.getStringByNameSync(key);
    } catch (error) {
      return key;
    }
  }

  /**
   * The system language (for example "zh-Hans"), as the iOS `CYLMenuResources.currentLanguage`.
   */
  static currentLanguage(): string {
    return i18n.System.getSystemLanguage();
  }
}

/**
 * The core's lookup function (the iOS core's CYLMenuLocalizedString): every user-facing string of the core goes
 * through it, never a literal.
 */
export function CYLMenuLocalizedString(context: Context, key: string): string {
  return CYLMenuResources.localizedString(context, key);
}
