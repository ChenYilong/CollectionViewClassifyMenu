import { i18n } from '@kit.LocalizationKit';
import { CYL_EXAMPLE_STRINGS } from './CYLExampleStrings';

/**
 * The language of the example's strings: zh-Hant for Traditional Chinese (zh-Hant, zh-TW, zh-HK, zh-MO), zh-Hans
 * for other Chinese, en otherwise; as iOS picks among the example bundle's `.lproj` folders.
 */
export function cylExampleLanguage(system?: string): string {
  let language = system ?? '';
  if (system === undefined) {
    try {
      language = i18n.System.getSystemLanguage();
    } catch (error) {
      language = 'en';
    }
  }
  const lower = language.toLowerCase();
  if (lower.startsWith('zh')) {
    return /hant|tw|hk|mo/.test(lower) ? 'zh-Hant' : 'zh-Hans';
  }
  return 'en';
}

/**
 * `CYLExampleLocalizedString(_:)`: the example string of `key` (its Simplified Chinese text) in the system language;
 * the key itself in Simplified Chinese or when no translation exists.
 */
export function CYLExampleLocalizedString(key: string, language?: string): string {
  const table: Record<string, string> | undefined = CYL_EXAMPLE_STRINGS[language ?? cylExampleLanguage()];
  const value: string | undefined = table === undefined ? undefined : table[key];
  return value !== undefined && value.length > 0 ? value : key;
}
