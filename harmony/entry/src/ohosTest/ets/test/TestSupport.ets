import { abilityDelegatorRegistry, Component, Driver, ON } from '@kit.TestKit';
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
 * Taps the component with `id`, scrolling the first scrollable list until it is found.
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
