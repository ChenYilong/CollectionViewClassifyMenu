import { CYLMenuLocalizedString } from '../core/CYLMenuResources';

/**
 * `CYLTagListAddItemView`: the "add tag" control of `CYLTagListState` in editing mode, a text field and an Add button,
 * which `CYLTagListView` draws below the last section. A submitted name is reported through
 * `menuDidRequestNewItemWithName`. ArkUI views are structs, so this is the control's model: the view binds `text` to
 * its `TextInput` and calls `submit()` from the Add button and the keyboard's Done key.
 */
export class CYLTagListAddItemView {
  /** The identifier of the text field ("CYLTagListAddItemField", its `id`). */
  static readonly textFieldIdentifier: string = 'CYLTagListAddItemField';
  /** The identifier of the Add button ("CYLTagListAddItemButton", its `id`). */
  static readonly addButtonIdentifier: string = 'CYLTagListAddItemButton';

  /** The field's text (the view keeps it in sync with its `TextInput`). */
  text: string = '';
  /** The field's placeholder and accessibility text: the localized "Tag name" (`CYLMenuAddTagPlaceholder`). */
  placeholder: string = CYLMenuLocalizedString('CYLMenuAddTagPlaceholder');
  /** The Add button's title (`CYLMenuAddTag`); the button is enabled while the field has a name. */
  addTitle: string = CYLMenuLocalizedString('CYLMenuAddTag');
  /** Called with the trimmed name when the Add button or the keyboard's Done key is tapped; the field is cleared. */
  submitHandler?: (name: string) => void;
  /** Called after `text` changes in code (`submit()` clears it), so the view shows it. */
  textChangeHandler?: () => void;
  /** The height of the control, vp: 44 by default, larger with a larger font scale. */
  fontScale: number = 1;

  get preferredHeight(): number {
    return Math.max(44, Math.ceil(17 * 1.2 * this.fontScale) + 20);
  }

  /** The trimmed name in the field. */
  get name(): string {
    return this.text.trim();
  }

  /**
   * Submits the name in the field (as the Add button does): calls `submitHandler` and clears the field. An empty name
   * does nothing. Returns the announcement for screen readers ("Tag added: <name>", `CYLMenuTagAdded`), or ''.
   */
  submit(): string {
    const name = this.name;
    if (name.length === 0) {
      return '';
    }
    this.text = '';
    this.textChangeHandler?.();
    this.submitHandler?.(name);
    return CYLMenuLocalizedString('CYLMenuTagAdded').replace('%@', name);
  }
}
