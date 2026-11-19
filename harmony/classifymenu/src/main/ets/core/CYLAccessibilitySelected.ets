import { deviceInfo } from '@kit.BasicServicesKit';

/**
 * Sets the accessibility selected state where the system has it (API 13 and later); the library targets API 12,
 * where the attribute does not exist and the state is left out.
 */
export class CYLAccessibilitySelectedModifier<T extends CommonMethod<T>> implements AttributeModifier<T> {
  private selected: boolean;

  constructor(selected: boolean) {
    this.selected = selected;
  }

  applyNormalAttribute(instance: T): void {
    if (deviceInfo.sdkApiVersion >= 13) {
      instance.accessibilitySelected(this.selected);
    }
  }
}
