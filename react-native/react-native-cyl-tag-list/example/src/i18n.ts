import { NativeModules, Platform } from 'react-native';

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
};

function locale(): string {
  const settings = NativeModules.SettingsManager?.settings;
  const ios = settings?.AppleLocale ?? settings?.AppleLanguages?.[0];
  return (Platform.OS === 'ios' ? ios : NativeModules.I18nManager?.localeIdentifier) ?? 'en';
}

const table = locale().startsWith('zh') ? zh : {};

/**
 * Looks a key up in the example's table; English is the key itself.
 */
export function t(key: string): string {
  return table[key] ?? key;
}
