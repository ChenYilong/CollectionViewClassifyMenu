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
import {
  CylFoldControlContent,
  CylHeaderSeparatorStyle,
  CylSectionBackgroundStyle,
  CylSectionStyle,
  CylTagLongPressActionName,
  CylTagTitleMaxLinesUnlimited,
  type CylTagListConfiguration,
} from '../CylTagListConfiguration';

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
    const onTagLongPress = jest.fn();
    const onSelectionChange = jest.fn();
    const onContentHeightChange = jest.fn();
    const screen = render(
      <CylTagListView
        testID="list"
        configuration={{}}
        onTagTap={onTagTap}
        onTagLongPress={onTagLongPress}
        onSelectionChange={onSelectionChange}
        onContentHeightChange={onContentHeightChange}
      />
    );
    const host = screen.getByTestId('list');
    host.props.onTagTap({ nativeEvent: { section: 1, item: 2, title: '广州' } });
    host.props.onTagLongPress({ nativeEvent: { section: 0, item: 4, title: '北京' } });
    host.props.onSelectionChange({ nativeEvent: { itemsJSON: '[{"section":0,"item":3,"title":"上海"}]' } });
    host.props.onContentHeightChange({ nativeEvent: { height: 180.5 } });
    expect(onTagTap).toHaveBeenCalledWith({ section: 1, item: 2, title: '广州' });
    expect(onTagLongPress).toHaveBeenCalledWith({ section: 0, item: 4, title: '北京' });
    expect(onSelectionChange).toHaveBeenCalledWith([{ section: 0, item: 3, title: '上海' }]);
    expect(onContentHeightChange).toHaveBeenCalledWith(180.5);
  });

  it('sends the long-press action, the subtitles, the fold and the title lines to the native list as they are', () => {
    const configuration: CylTagListConfiguration = {
      longPressAction: [CylTagLongPressActionName.callout],
      defaultVisibleRows: 2,
      style: { titleMaxLines: CylTagTitleMaxLinesUnlimited },
      sections: [
        { title: 'Flows', items: [{ title: 'Switch states', subtitle: 'reloadData #3' }] },
        { title: 'HUD', items: [{ title: 'Progress' }] },
      ],
    };
    const screen = render(<CylTagListView testID="list" configuration={configuration} />);
    const sent = JSON.parse(screen.getByTestId('list').props.configuration);
    expect(sent).toEqual(configuration);
    expect(sent.sections).toHaveLength(2);
    expect(sent.style.titleMaxLines).toBe('unlimited');
    expect(sent.longPressAction).toEqual(['callout']);
  });

  it('sends the typed section style keys to the native list as they are', () => {
    const configuration: CylTagListConfiguration = {
      style: {
        sectionStyle: CylSectionStyle.plain,
        sectionBackgroundColor: '#FFFFFF',
        sectionBackgroundStyle: CylSectionBackgroundStyle.liquidGlass,
        sectionCornerRadius: 16,
        sectionContentInsets: [8, 12, 8, 12],
        headerBackgroundColor: '#EFEFF4',
        headerCornerRadius: 6,
        headerContentInsets: { top: 0, left: 10, bottom: 0, right: 10 },
        headerSeparatorStyle: CylHeaderSeparatorStyle.line,
        headerSeparatorColor: '#000000',
        headerSeparatorThickness: 1,
        headerSeparatorInsets: '{0, 4, 0, 4}',
        tintColor: 'systemBlue',
        titleMaxLines: 2,
      },
      sections: [{ title: 'Flows', items: [{ title: 'Switch states' }] }],
    };
    const screen = render(<CylTagListView testID="list" configuration={configuration} />);
    const sent = JSON.parse(screen.getByTestId('list').props.configuration);
    expect(sent).toEqual(configuration);
    expect(sent.style.sectionStyle).toBe('plain');
    expect(sent.style.sectionBackgroundStyle).toBe('liquidGlass');
    expect(sent.style.headerSeparatorStyle).toBe('line');
    expect(sent.style.sectionContentInsets).toEqual([8, 12, 8, 12]);
    expect(sent.style.tintColor).toBe('systemBlue');
  });

  it('names the section style values as the native parsers read them', () => {
    expect(CylSectionStyle).toEqual({ plain: 'plain', insetGrouped: 'insetGrouped' });
    expect(CylSectionBackgroundStyle).toEqual({ flat: 'flat', liquidGlass: 'liquidGlass' });
    expect(CylHeaderSeparatorStyle).toEqual({ none: 'none', line: 'line' });
  });

  it('sends a configuration without section keys unchanged, so the native defaults apply (card on, divider off)', () => {
    const configuration: CylTagListConfiguration = { sections: [{ title: 'Flows', items: [{ title: 'A' }] }] };
    const screen = render(<CylTagListView testID="list" configuration={configuration} />);
    const sent = JSON.parse(screen.getByTestId('list').props.configuration);
    expect(sent).toEqual(configuration);
    expect(sent.style).toBeUndefined();
  });

  it('sends the typed foldControl unchanged, with titleAndIconAlways', () => {
    const configuration: CylTagListConfiguration = {
      defaultVisibleRows: 2,
      foldControl: {
        position: 'tail',
        content: CylFoldControlContent.titleAndIconAlways,
        title: 'More',
        collapseTitle: 'Less',
        color: '#007AFF',
      },
      sections: [{ title: 'Flows', items: [{ title: 'A' }] }],
    };
    const screen = render(<CylTagListView testID="list" configuration={configuration} />);
    const sent = JSON.parse(screen.getByTestId('list').props.configuration);
    expect(sent).toEqual(configuration);
    expect(sent.foldControl.content).toBe('titleAndIconAlways');
    expect(CylFoldControlContent).toEqual({
      iconAndTitle: 'iconAndTitle',
      title: 'title',
      icon: 'icon',
      titleAndIconAlways: 'titleAndIconAlways',
    });
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
