import { describe, expect, it, jest } from '@jest/globals';

jest.mock('react-native', () => ({
  I18nManager: { getConstants: () => ({ localeIdentifier: 'en_US' }) },
  NativeModules: {},
  Platform: { OS: 'android' },
}));

import { dataTitle, language, shortTitle } from '../i18n';

describe('the example language and the shared data titles', () => {
  it('picks the iOS bundle language for a locale', () => {
    expect(language('en_US')).toBe('en');
    expect(language('zh-Hans-CN')).toBe('zh-Hans');
    expect(language('zh_CN')).toBe('zh-Hans');
    expect(language('zh-Hant-TW')).toBe('zh-Hant');
    expect(language('zh_HK')).toBe('zh-Hant');
  });

  it('shows the source titles of data.json and the places database in each language', () => {
    expect(dataTitle('川菜 扩展文字😀✨', 'en')).toBe('Sichuan extended text😀✨');
    expect(dataTitle('川菜 扩展文字😀✨', 'zh-Hant')).toBe('川菜 擴展文字😀✨');
    expect(dataTitle('川菜 扩展文字😀✨', 'zh-Hans')).toBe('川菜 扩展文字😀✨');
    expect(shortTitle('北京 🏙️ 扩展文字', 'en')).toBe('Beijing');
    expect(shortTitle('广州', 'zh-Hant')).toBe('廣州');
  });
});
