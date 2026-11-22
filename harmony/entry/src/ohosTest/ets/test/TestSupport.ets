import { abilityDelegatorRegistry, Component, Driver, ON, On } from '@kit.TestKit';
import { Want } from '@kit.AbilityKit';

export const BUNDLE = 'com.cyl.classifymenu.example';

/** A control of the root tab bar, hidden on pushed pages. */
const ROOT_TAB_ID = 'tab-plus';
const ROOT_BACK_LIMIT = 6;

/**
 * Starts the example (again) at its root tab bar.
 */
export async function cylLaunchExample(): Promise<Driver> {
  const want: Want = { bundleName: BUNDLE, abilityName: 'EntryAbility' };
  const delegator = abilityDelegatorRegistry.getAbilityDelegator();
  await delegator.startAbility(want);
  const driver = Driver.create();
  await driver.delayMs(2000);
  // The tests share one app process, and starting the ability again keeps the page the previous test left (a pushed
  // page hides the tab bar): go back until the root tab bar shows, and start again if back left the app.
  for (let i = 0; i < ROOT_BACK_LIMIT && await driver.findComponent(ON.id(ROOT_TAB_ID)) === null; i++) {
    await driver.pressBack();
    await driver.delayMs(800);
  }
  if (await driver.findComponent(ON.id(ROOT_TAB_ID)) === null) {
    await delegator.startAbility(want);
    await driver.delayMs(2000);
  }
  return driver;
}

/**
 * Scrolls `list` to its top, then searches it for `matcher`. A list that is gone or too small to scroll (an earlier
 * scroll rebuilt it) gives null instead of failing the test.
 */
async function cylScrollSearch(list: Component, matcher: On): Promise<Component | null> {
  try {
    await list.scrollToTop();
    return await list.scrollSearch(matcher);
  } catch (e) {
    return null;
  }
}

/**
 * Finds a control the way a screen reader user does: by its localized accessibility label (`ON.text`, which UiTest
 * matches against the text and the accessibility text), then by its accessibility description, and only then by
 * `fallbackId`, scrolling the scrollable lists when it is not on screen. Rule: AGENTS.md "Accessibility-first UI
 * tests".
 */
export async function cylFindAccessible(driver: Driver, label: string, fallbackId?: string): Promise<Component> {
  const matchers: On[] = [ON.text(label), ON.description(label)];
  if (fallbackId !== undefined) {
    matchers.push(ON.id(fallbackId));
  }
  for (const matcher of matchers) {
    const component = await driver.findComponent(matcher);
    if (component !== null) {
      return component;
    }
  }
  const lists = await driver.findComponents(ON.scrollable(true));
  for (const list of lists ?? []) {
    for (const matcher of matchers) {
      const component = await cylScrollSearch(list, matcher);
      if (component !== null) {
        return component;
      }
    }
  }
  const suffix = fallbackId !== undefined ? ` or with id ${fallbackId}` : '';
  throw new Error(`No control labeled "${label}"${suffix}`);
}

/**
 * Taps the control labeled `label` (see `cylFindAccessible`), then waits.
 */
export async function cylTapAccessible(driver: Driver, label: string, fallbackId?: string,
  waitMs: number = 800): Promise<void> {
  await (await cylFindAccessible(driver, label, fallbackId)).click();
  await driver.delayMs(waitMs);
}

/**
 * Taps the component with `id`, scrolling the scrollable lists until it is found. Only for controls without a
 * distinctive label (rows of generated data); prefer `cylTapAccessible`.
 */
export async function cylTap(driver: Driver, id: string, waitMs: number = 800): Promise<void> {
  let component: Component | null = await driver.findComponent(ON.id(id));
  if (component === null) {
    const lists = await driver.findComponents(ON.scrollable(true));
    for (const list of lists ?? []) {
      component = await cylScrollSearch(list, ON.id(id));
      if (component !== null) {
        break;
      }
    }
  }
  if (component === null) {
    throw new Error(`No component with id ${id}`);
  }
  await component.click();
  await driver.delayMs(waitMs);
}

/**
 * The text of the component with `id`.
 */
export async function cylText(driver: Driver, id: string): Promise<string> {
  const component = await driver.findComponent(ON.id(id));
  if (component === null) {
    throw new Error(`No component with id ${id}`);
  }
  return await component.getText();
}

/**
 * Goes back one page with the system back key.
 */
export async function cylBack(driver: Driver): Promise<void> {
  await driver.pressBack();
  await driver.delayMs(800);
}
