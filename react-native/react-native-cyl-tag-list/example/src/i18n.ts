import { I18nManager, NativeModules, Platform } from 'react-native';

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

const table = locale().startsWith('zh') ? zh : {};

/**
 * Looks a key up in the example's table; English is the key itself.
 */
export function t(key: string): string {
  return table[key] ?? key;
}
