/**
 * The example's animation engines: `cylRegisterExampleAnimationEngines()` registers CYLTabBarController's engine views
 * (`CYLAnimatedItemLottie`, `CYLAnimatedItemPAG`, `CYLAnimatedItemRive`, `CYLAnimatedItemGIF`, `CYLAnimatedItemSVGA`), so every
 * tag's animated icon plays through `CYLAnimatedItemView`'s default engine view (the tag drives the player: resting
 * progress, Play all, speed, loop). The example's own players and views are gone (docs/animated-item-migration.md):
 * every engine fix now lives in CYLTabBarController and is shared by the apps that use it.
 */
import { CYLAnimatedItemEngines, CYLAnimatedItemGIF, CYLAnimatedItemSVGA } from 'cylanimateditem';
import { CYLAnimatedItemLottie } from 'cylanimateditem_lottie';
import { CYLAnimatedItemPAG } from 'cylanimateditem_pag';
import { CYLAnimatedItemRive } from 'cylanimateditem_rive';

/**
 * Registers the engines the example plays (Lottie, PAG, Rive, GIF, SVGA). Called once, before any tag is shown
 * (`EntryAbility.onCreate`). With the ability's context, the x86_64 debug engine kit is read first (PAG and Rive then play on
 * the x86_64 emulator in debug builds).
 */
export function cylRegisterExampleAnimationEngines(context?: Context): void {
  if (context !== undefined) {
    CYLAnimatedItemEngines.loadX86_64DebugEngines(context);
  }
  CYLAnimatedItemLottie.register();
  CYLAnimatedItemPAG.register();
  CYLAnimatedItemRive.register();
  CYLAnimatedItemGIF.register();
  CYLAnimatedItemSVGA.register();
}
