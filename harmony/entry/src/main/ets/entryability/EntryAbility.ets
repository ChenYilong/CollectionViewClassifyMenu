import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { CYLMenuResources } from '@cyl/classifymenu';
import { CYLLaunchOptions } from '../data/CYLLaunchOptions';
import { CYLDemoNav } from '../demos/DemoNav';
import { cylRegisterExampleAnimationEngines } from '../animation/CYLExampleAnimationViews';

const DOMAIN = 0x0000;
/** The AppStorage key of the app's color mode that `cylanimateditem` reads (see `syncGlassColorMode`). */
const GLASS_COLOR_MODE_KEY: string = 'cyl_colorMode';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // The library plays no animation by itself: the example registers the engines it bundles (Lottie, PAG, Rive, SVGA,
    // GIF) and the views that play them, before any tag is shown.
    cylRegisterExampleAnimationEngines(this.context);
    CYLLaunchOptions.read(want);
    this.applyLaunchOptions();
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    CYLLaunchOptions.read(want);
    this.applyLaunchOptions();
    const screen = CYLLaunchOptions.takeScreen();
    if (screen !== '') {
      // The root page opens it: a tab's route selects the tab, any other route is pushed.
      AppStorage.setOrCreate('cylLaunchScreen', screen);
    }
  }

  /** The language and color mode of the launch options (the system's when not given). */
  private applyLaunchOptions(): void {
    if (CYLLaunchOptions.language !== '') {
      CYLMenuResources.preferredLanguage = CYLLaunchOptions.language;
    }
    const mode = CYLLaunchOptions.colorMode === 'dark' ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK :
      CYLLaunchOptions.colorMode === 'light' ? ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT :
      ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
    try {
      this.context.getApplicationContext().setColorMode(mode);
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set the color mode: %{public}s', JSON.stringify(error));
    }
    this.syncGlassColorMode(mode);
  }

  /**
   * The Liquid Glass of `cylanimateditem` (tint, edge) and the library's icon lift read the app's color mode from AppStorage
   * `cyl_colorMode` ('dark' / 'light'); CYLTabBarController's `cyl_updateColorMode` sets it, and this example has no tab bar
   * module, so it sets the key itself. Without it every glass is drawn in its light variant, also in dark mode.
   * `launchMode`: the mode the launch options asked for; "not set" follows the system.
   */
  private syncGlassColorMode(launchMode: ConfigurationConstant.ColorMode): void {
    const effective = launchMode === ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET ?
      this.context.config.colorMode : launchMode;
    AppStorage.setOrCreate<string>(GLASS_COLOR_MODE_KEY,
      effective === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? 'dark' : 'light');
  }

  /** The system's light / dark switch while the app runs (unless the launch options pinned a mode). */
  onConfigurationUpdate(config: Configuration): void {
    if (CYLLaunchOptions.colorMode === '') {
      AppStorage.setOrCreate<string>(GLASS_COLOR_MODE_KEY,
        config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? 'dark' : 'light');
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}