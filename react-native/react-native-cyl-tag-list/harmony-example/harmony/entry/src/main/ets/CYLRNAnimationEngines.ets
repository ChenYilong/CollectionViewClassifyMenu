/**
 * The animation engines of this React Native for OpenHarmony shell. The core (`@cyl/classifymenu`) draws tag icons with
 * CYLTabBarController's `CYLAnimatedItemView`; the shared Tags page plays Lottie (the `tab_*.json` rawfiles), Rive
 * (`house.riv`, `check.riv`, `menu_button.riv`) and SVGA (`tab_*.svga`), so the shell registers CYLTabBarController's
 * engines (`cylanimateditem` with GIF and SVGA, `cylanimateditem_lottie`, `cylanimateditem_rive`, vendored in `harmony/`),
 * which play them through the component's default engine view. The shell has no player of its own
 * (docs/animated-item-migration.md).
 */
import { CYLAnimatedItemGIF, CYLAnimatedItemSVGA } from 'cylanimateditem';
import { CYLAnimatedItemLottie } from 'cylanimateditem_lottie';
import { CYLAnimatedItemRive } from 'cylanimateditem_rive';

/**
 * Registers the engines before any tag is shown (`EntryAbility.onCreate`).
 */
export function cylRegisterRNAnimationEngines(): void {
  CYLAnimatedItemLottie.register();
  CYLAnimatedItemRive.register();
  CYLAnimatedItemGIF.register();
  CYLAnimatedItemSVGA.register();
}
