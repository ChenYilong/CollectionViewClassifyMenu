import { createRef } from 'react';
import { describe, expect, it, jest } from '@jest/globals';
import { render } from '@testing-library/react-native';

const mockPlayAll = jest.fn();

// The host component and its command: the wrapper's job is to translate props and events, tested without native code.
jest.mock('../CylTagListViewNativeComponent', () => {
  const { forwardRef, createElement } = require('react');
  const NativeView = forwardRef((props: object, ref: unknown) => createElement('CylTagListView', { ...props, ref }));
  return { __esModule: true, default: NativeView, Commands: { playAll: (...args: unknown[]) => mockPlayAll(...args) } };
});

import { CylTagListView, type CylTagListHandle } from '../CylTagListView.native';

describe('CylTagListView', () => {
  it('sends the configuration as JSON and the playback props as they are', () => {
    const configuration = { selectionMode: 'single', sections: [{ title: '吃', items: [{ title: '川菜' }] }] };
    const screen = render(
      <CylTagListView testID="list" configuration={configuration} animationSpeed={2} animationLoops />
    );
    const host = screen.getByTestId('list');
    expect(JSON.parse(host.props.configuration)).toEqual(configuration);
    expect(host.props.animationSpeed).toBe(2);
    expect(host.props.animationLoops).toBe(true);
  });

  it('unwraps the native events', () => {
    const onTagTap = jest.fn();
    const onSelectionChange = jest.fn();
    const onContentHeightChange = jest.fn();
    const screen = render(
      <CylTagListView
        testID="list"
        configuration={{}}
        onTagTap={onTagTap}
        onSelectionChange={onSelectionChange}
        onContentHeightChange={onContentHeightChange}
      />
    );
    const host = screen.getByTestId('list');
    host.props.onTagTap({ nativeEvent: { section: 1, item: 2, title: '广州' } });
    host.props.onSelectionChange({ nativeEvent: { itemsJSON: '[{"section":0,"item":3,"title":"上海"}]' } });
    host.props.onContentHeightChange({ nativeEvent: { height: 180.5 } });
    expect(onTagTap).toHaveBeenCalledWith({ section: 1, item: 2, title: '广州' });
    expect(onSelectionChange).toHaveBeenCalledWith([{ section: 0, item: 3, title: '上海' }]);
    expect(onContentHeightChange).toHaveBeenCalledWith(180.5);
  });

  it('runs the playAll command on the native view', () => {
    const ref = createRef<CylTagListHandle>();
    // The test renderer has no native views: a stand-in node for the host component's ref.
    const node = { native: true };
    render(<CylTagListView ref={ref} configuration={{}} />, { createNodeMock: () => node });
    ref.current?.playAll();
    expect(mockPlayAll).toHaveBeenCalledTimes(1);
    expect(mockPlayAll).toHaveBeenCalledWith(node);
  });
});
