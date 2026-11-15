import { Want } from '@kit.AbilityKit';

/**
 * Launch parameters for screenshots and UI checks (iOS: the example's launch arguments), passed with
 * `hdc shell aa start -b <bundle> -a EntryAbility --ps <key> <value>`:
 * - `cylScreen`: a route (the iOS class name, e.g. `CYLTagAnimationDemoViewController`), pushed at launch;
 * - `cylScreenParam`: the route's parameter as JSON (e.g. `{"selectedFilterIndex":0,"mode":"network"}`);
 * - `cylLanguage`: `en`, `zh-Hans` or `zh-Hant`, instead of the system language (core and example strings);
 * - `cylColorMode`: `dark` or `light`, instead of the system's.
 */
export class CYLLaunchOptions {
  static screen: string = '';
  static screenParam: Object | undefined = undefined;
  static language: string = '';
  static colorMode: string = '';

  /**
   * Reads the parameters of `want`; a missing one keeps its value.
   */
  static read(want: Want | undefined): void {
    const parameters = want?.parameters;
    if (parameters === undefined) {
      return;
    }
    const text = (key: string): string => {
      const value = parameters[key];
      return typeof value === 'string' ? value : '';
    };
    if (text('cylScreen') !== '') {
      CYLLaunchOptions.screen = text('cylScreen');
      CYLLaunchOptions.screenParam = CYLLaunchOptions.parse(text('cylScreenParam'));
    }
    if (text('cylLanguage') !== '') {
      CYLLaunchOptions.language = text('cylLanguage');
    }
    if (text('cylColorMode') !== '') {
      CYLLaunchOptions.colorMode = text('cylColorMode');
    }
  }

  /**
   * The screen to push once, then forgotten.
   */
  static takeScreen(): string {
    const screen = CYLLaunchOptions.screen;
    CYLLaunchOptions.screen = '';
    return screen;
  }

  private static parse(json: string): Object | undefined {
    if (json === '') {
      return undefined;
    }
    try {
      return JSON.parse(json) as Object;
    } catch (error) {
      return undefined;
    }
  }
}
