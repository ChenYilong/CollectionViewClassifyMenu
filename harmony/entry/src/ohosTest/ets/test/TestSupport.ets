import { abilityDelegatorRegistry, Component, Driver, ON, On } from '@kit.TestKit';
import { Want } from '@kit.AbilityKit';

export const BUNDLE = 'com.cyl.classifymenu.example';

/**
 * Starts the example (again) at its root tab bar.
 */
export async function cylLaunchExample(): Promise<Driver> {
  const want: Want = { bundleName: BUNDLE, abilityName: 'EntryAbility' };
  await abilityDelegatorRegistry.getAbilityDelegator().startAbility(want);
  const driver = Driver.create();
  await driver.delayMs(2000);
  return driver;
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
      const component = await list.scrollSearch(matcher);
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
      component = await list.scrollSearch(ON.id(id));
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
