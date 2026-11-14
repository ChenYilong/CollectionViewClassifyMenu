import {
  codegenNativeComponent,
  codegenNativeCommands,
  type HostComponent,
  type ViewProps,
  type CodegenTypes,
} from 'react-native';

export type TagEvent = Readonly<{
  section: CodegenTypes.Int32;
  item: CodegenTypes.Int32;
  title: string;
}>;

export type SelectionEvent = Readonly<{
  /** JSON array of { section, item, title } (codegen has no arrays of objects in events here). */
  itemsJSON: string;
}>;

export type ContentHeightEvent = Readonly<{
  height: CodegenTypes.Double;
}>;

export interface NativeProps extends ViewProps {
  /** The configuration dictionary of the native CYLTagListView, as JSON ("asset:<name>" = a file of the app bundle). */
  configuration: string;
  /** Animation speed; 0 keeps each animation's own speed. */
  animationSpeed?: CodegenTypes.WithDefault<CodegenTypes.Float, 0>;
  animationLoops?: CodegenTypes.WithDefault<boolean, false>;
  onTagTap?: CodegenTypes.DirectEventHandler<TagEvent>;
  onSelectionChange?: CodegenTypes.DirectEventHandler<SelectionEvent>;
  onContentHeightChange?: CodegenTypes.DirectEventHandler<ContentHeightEvent>;
}

interface NativeCommands {
  playAll: (viewRef: React.ElementRef<HostComponent<NativeProps>>) => void;
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ['playAll'],
});

export default codegenNativeComponent<NativeProps>('CylTagListView');
