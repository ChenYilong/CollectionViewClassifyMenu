import { I18nManager, NativeModules, Platform } from 'react-native';
import { DATA_STRINGS } from './dataStrings';

/**
 * The example's strings (the example-level table; the core and CYLTabBarController keep their own).
 */
const zh: Record<string, string> = {
  'Tags': '标签',
  'Classify': '分类',
  'Post': '发布',
  'Speed': '速度',
  'Loop': '循环',
  'Play all': '全部播放',
  'Tapped': '点击',
  'Selected': '已选',
  'The plus button page': '加号按钮的页面',
  'The raised plus button has a page of its own (pageIdentifier: plus); tap a tab to go back':
    '凸起的加号按钮有自己的页面（pageIdentifier: plus）；点击任意 Tab 返回',
  'Classify menu': '分类菜单',
  'Regions': '地区过滤',
  'Dishes': '菜品过滤',
  'All': '全部',
  'OK': '确定',
  'Reset': '重置筛选条件',
  'Filter': '筛选',
  'No places match; try other conditions': '没有符合条件的地点，换个条件试试',
};

function locale(): string {
  const settings = NativeModules.SettingsManager?.settings;
  const ios = settings?.AppleLocale ?? settings?.AppleLanguages?.[0];
  // Android and HarmonyOS (React Native for OpenHarmony: a turbo module that NativeModules does not reach).
  const other = I18nManager.getConstants?.()?.localeIdentifier ?? NativeModules.I18nManager?.localeIdentifier;
  return (Platform.OS === 'ios' ? ios : other) ?? 'en';
}

/**
 * The same strings in Traditional Chinese.
 */
const zhHant: Record<string, string> = {
  'Tags': '標籤',
  'Classify': '分類',
  'Post': '發布',
  'Speed': '速度',
  'Loop': '循環',
  'Play all': '全部播放',
  'Tapped': '點擊',
  'Selected': '已選',
  'The plus button page': '加號按鈕的頁面',
  'The raised plus button has a page of its own (pageIdentifier: plus); tap a tab to go back':
    '凸起的加號按鈕有自己的頁面（pageIdentifier: plus）；點擊任意 Tab 返回',
  'Classify menu': '分類選單',
  'Regions': '地區過濾',
  'Dishes': '菜品過濾',
  'All': '全部',
  'OK': '確定',
  'Reset': '重設篩選條件',
  'Filter': '篩選',
  'No places match; try other conditions': '沒有符合條件的地點，換個條件試試',
};

/**
 * `en`, `zh-Hans` or `zh-Hant`, as iOS picks among the example bundle's `.lproj` folders.
 */
export function language(identifier: string = locale()): 'en' | 'zh-Hans' | 'zh-Hant' {
  const id = identifier.replace('_', '-');
  if (!id.startsWith('zh')) {
    return 'en';
  }
  return /Hant|-TW|-HK|-MO/.test(id) ? 'zh-Hant' : 'zh-Hans';
}

const current = language();
const table = current === 'zh-Hant' ? zhHant : current === 'zh-Hans' ? zh : {};

/**
 * Looks a key up in the example's table; English is the key itself.
 */
export function t(key: string): string {
  return table[key] ?? key;
}

/**
 * The sample suffixes of the shared data's long titles ("川菜 扩展文字😀✨"); data.json and the places database keep the
 * source titles, the screens show them in the device language.
 */
const SAMPLE_SUFFIXES = [' 扩展文字😀✨', ' 🏙️ 扩展文字']; // NOLOCALIZE: source suffixes

function shortSource(title: string): string {
  const suffix = SAMPLE_SUFFIXES.find((s) => title.endsWith(s));
  return suffix ? title.slice(0, title.length - suffix.length) : title;
}

/**
 * A data word in the device language (Simplified Chinese: the source itself).
 */
export function dataString(key: string, lang: string = current): string {
  return DATA_STRINGS[lang]?.[key] ?? key;
}

/**
 * A source title in the device language: the name and the sample suffix each looked up
 * ("川菜 扩展文字😀✨" → "Sichuan extended text😀✨").
 */
export function dataTitle(title: string, lang: string = current): string {
  const short = shortSource(title);
  if (short === title) {
    return dataString(title, lang);
  }
  return dataString(short, lang) + title.slice(short.length).replace('扩展文字', dataString('扩展文字', lang));
}

/**
 * A source title without the sample suffix, in the device language ("北京 🏙️ 扩展文字" → "Beijing").
 */
export function shortTitle(title: string, lang: string = current): string {
  return dataString(shortSource(title), lang);
}
