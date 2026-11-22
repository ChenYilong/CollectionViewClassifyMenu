/**
 * The animation engine of this React Native for OpenHarmony shell. The core (`@cyl/classifymenu`) draws tag icons with
 * CYLTabBarController's `CYLAnimatedItemView`; the shell's tags play Lottie (the `tab_*.json` rawfiles), so it registers
 * CYLTabBarController's Lottie engine (`cylanimateditem_lottie`, vendored in `harmony/`), which plays them through the
 * component's default engine view. The shell has no player of its own (docs/animated-item-migration.md).
 */
import { CYLAnimatedItemLottie } from 'cylanimateditem_lottie';

/**
 * Registers the Lottie engine before any tag is shown (`EntryAbility.onCreate`).
 */
export function cylRegisterRNAnimationEngines(): void {
  CYLAnimatedItemLottie.register();
}
