/**
 * The core's resources, as iOS `CYLMenuResources`: its images (the pod's Images.xcassets, copied to the HAR's media)
 * and its strings in English, Simplified and Traditional Chinese (CYLCoreStrings.ets, generated from the pod's
 * CYLClassifyMenu.strings). The language is `preferredLanguage` when set, else the system's, else English.
 */
import { i18n } from '@kit.LocalizationKit';
import { CYL_CORE_STRINGS } from './CYLCoreStrings';

const FALLBACK_LANGUAGE: string = 'en';

/** The images of the pod's asset catalog by name ($r needs a literal, so each one is listed). */
const IMAGES: Map<string, Resource> = new Map<string, Resource>([
  ['btn_slide_normal', $r('app.media.btn_slide_normal')],
  ['btn_slide_selected', $r('app.media.btn_slide_selected')],
  ['cyl_filter_modified', $r('app.media.cyl_filter_modified')],
  ['cyl_filter_normal', $r('app.media.cyl_filter_normal')],
  ['cyl_fold_chevron', $r('app.media.cyl_fold_chevron')],
  ['cyl_more', $r('app.media.cyl_more')],
  ['cyl_trash', $r('app.media.cyl_trash')],
  ['cyl_tag_plus', $r('app.media.cyl_tag_plus')],
  ['home_btn_cosmetic', $r('app.media.home_btn_cosmetic')],
  ['home_btn_more_normal', $r('app.media.home_btn_more_normal')],
  ['home_btn_more_selected', $r('app.media.home_btn_more_selected')],
  ['home_btn_shrink', $r('app.media.home_btn_shrink')],
  ['icon_slide_people', $r('app.media.icon_slide_people')],
  ['icon_slide_sort', $r('app.media.icon_slide_sort')],
  ['icon_slide_type', $r('app.media.icon_slide_type')],
  ['tag_btn_background_highlighted', $r('app.media.tag_btn_background_highlighted')],
  ['tag_btn_background_normal', $r('app.media.tag_btn_background_normal')],
  ['tag_btn_background_selected', $r('app.media.tag_btn_background_selected')],
  ['unread_icon', $r('app.media.unread_icon')],
]);

function systemLanguage(): string {
  try {
    return i18n.System.getSystemLanguage();
  } catch (error) {
    return FALLBACK_LANGUAGE;
  }
}

function match(preference: string, available: string[]): string | undefined {
  const exact = available.find((language: string) => language.toLowerCase() === preference.toLowerCase());
  if (exact !== undefined) {
    return exact;
  }
  const lower = preference.toLowerCase();
  let tag: string;
  if (lower.startsWith('zh-hant') || lower.startsWith('zh-tw') || lower.startsWith('zh-hk') ||
    lower.startsWith('zh-mo')) {
    tag = 'zh-Hant';
  } else if (lower.startsWith('zh')) {
    tag = 'zh-Hans';
  } else {
    tag = preference.split('-')[0].split('_')[0];
  }
  return available.find((language: string) => language.toLowerCase() === tag.toLowerCase());
}

export class CYLMenuResources {
  /** A language of `availableLanguages` used instead of the system's; undefined for the system's. */
  static preferredLanguage: string | undefined = undefined;

  /** The name of the resource bundle on iOS; on HarmonyOS the resources live in the classifymenu HAR. */
  static readonly bundle: string = 'classifymenu';

  /** An image of the core by its asset name ("cyl_more", "cyl_fold_chevron", ...), or undefined. */
  static image(name: string): Resource | undefined {
    return IMAGES.get(name);
  }

  /** The languages the core has strings for, sorted. */
  static get availableLanguages(): string[] {
    return Object.keys(CYL_CORE_STRINGS).filter((language: string) =>
    Object.keys(CYL_CORE_STRINGS[language]).length > 0).sort();
  }

  /** The preferred language when set, else the system language, else English. */
  static get currentLanguage(): string {
    const preference = CYLMenuResources.preferredLanguage ?? systemLanguage();
    return match(preference, CYLMenuResources.availableLanguages) ?? FALLBACK_LANGUAGE;
  }

  /** The string of `key` in the current language. */
  static localizedString(key: string, language?: string): string {
    const candidates: string[] = [language ?? CYLMenuResources.currentLanguage, FALLBACK_LANGUAGE];
    for (const candidate of candidates) {
      const table: Record<string, string> | undefined = CYL_CORE_STRINGS[candidate];
      const value: string | undefined = table === undefined ? undefined : table[key];
      if (value !== undefined && value.length > 0) {
        return value;
      }
    }
    return key;
  }
}

/** `CYLMenuLocalizedString(_:)`: the core string of `key` in the current language. */
export function CYLMenuLocalizedString(key: string): string {
  return CYLMenuResources.localizedString(key);
}
