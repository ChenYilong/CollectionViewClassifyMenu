import { forwardRef, useImperativeHandle, useRef, type ElementRef } from 'react';
import type { HostComponent, ViewProps } from 'react-native';
import NativeCylTagListView, {
  Commands,
  type NativeProps,
  type TagEvent,
} from './CylTagListViewNativeComponent';

export type CylTagListProps = ViewProps & {
  configuration: Record<string, unknown>;
  animationSpeed?: number;
  animationLoops?: boolean;
  onTagTap?: (tag: TagEvent) => void;
  onSelectionChange?: (items: ReadonlyArray<TagEvent>) => void;
  onContentHeightChange?: (height: number) => void;
};

export type CylTagListHandle = { playAll: () => void };

export const CylTagListView = forwardRef<CylTagListHandle, CylTagListProps>(
  function CylTagListView(
    { configuration, onTagTap, onSelectionChange, onContentHeightChange, ...rest },
    ref
  ) {
    const native = useRef<ElementRef<HostComponent<NativeProps>>>(null);
    useImperativeHandle(ref, () => ({
      playAll: () => native.current && Commands.playAll(native.current),
    }));
    return (
      <NativeCylTagListView
        {...rest}
        ref={native}
        configuration={JSON.stringify(configuration)}
        onTagTap={onTagTap && ((e) => onTagTap(e.nativeEvent))}
        onSelectionChange={onSelectionChange && ((e) => onSelectionChange(JSON.parse(e.nativeEvent.itemsJSON)))}
        onContentHeightChange={
          onContentHeightChange && ((e) => onContentHeightChange(e.nativeEvent.height))
        }
      />
    );
  }
);
