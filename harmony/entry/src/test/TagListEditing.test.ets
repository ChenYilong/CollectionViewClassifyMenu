import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import {
  CYLFont, CYLIndexPath, CYLMenuDataSource, CYLMenuDelegate, CYLMenuFoldStyle, CYLMenuSelectionMode, CYLTagButtonMetrics,
  CYLTagListCachePolicy, CYLTagListDataOrigin, CYLTagListLoadPolicy, CYLTagListRemoteSource, CYLTagListState,
  CYLTagListStore, CYLTextMeasurer, CYLTagListCacheItem, CYLTagButton, CYLMenuStyle, CYLEdgeInsets, CYLSize,
  CYLTagListCell
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;

function path(section: number, item: number): CYLIndexPath {
  return { section: section, item: item };
}

/** Sections of tags that can be removed, moved and added to; `editableSections` alone take part in editing. */
class CYLEditableTagSource implements CYLMenuDataSource, CYLMenuDelegate {
  sections: string[][];
  editableSections?: number[];
  events: string[] = [];
  /** Each item's stable id ("id-<first title>"), moved with it and kept by a rename. */
  identifiers: string[][];
  finishedItems?: Map<string, CYLTagListCacheItem[]>;

  constructor(sections: string[][]) {
    this.sections = sections;
    this.identifiers = sections.map((titles: string[]) => titles.map((title: string) => `id-${title}`));
  }

  menuIdentifierForItem = (indexPath: CYLIndexPath): string => this.identifiers[indexPath.section][indexPath.item];
  menuShowsClearButtonForSection = (section: number): boolean => section === 0;
  menuDidRenameItem = (menu: Object, indexPath: CYLIndexPath, title: string): void => {
    this.events.push(`rename ${indexPath.item}-${indexPath.section} ${title}`);
  };
  menuDidTapClearButtonInSection = (menu: Object, section: number): void => {
    this.events.push(`clear ${section}`);
  };
  menuDidFinishEditingWithItems = (menu: Object, items: Map<string, CYLTagListCacheItem[]>): void => {
    this.finishedItems = items;
  };

  numberOfSectionsInMenu = (): number => this.sections.length;
  menuNumberOfItemsInSection = (section: number): number => this.sections[section].length;
  menuTitleForSection = (section: number): string => `Section ${section}`;
  menuTitleForItem = (indexPath: CYLIndexPath): string => this.sections[indexPath.section][indexPath.item];
  menuSectionAllowsEditing = (section: number): boolean =>
    this.editableSections === undefined || this.editableSections.includes(section);
  menuRemoveItem = (indexPath: CYLIndexPath): void => {
    this.sections[indexPath.section].splice(indexPath.item, 1);
    this.identifiers[indexPath.section].splice(indexPath.item, 1);
  };
  menuMoveItem = (from: CYLIndexPath, to: CYLIndexPath): void => {
    const title = this.sections[from.section].splice(from.item, 1)[0];
    this.sections[to.section].splice(to.item, 0, title);
    const identifier = this.identifiers[from.section].splice(from.item, 1)[0];
    this.identifiers[to.section].splice(to.item, 0, identifier);
  };
  menuDidSelectItem = (menu: Object, indexPath: CYLIndexPath): void => {
    this.events.push(`select ${indexPath.item}-${indexPath.section}`);
  };
  menuDidChangeEditing = (menu: Object, editing: boolean): void => {
    this.events.push(editing ? 'edit' : 'done');
  };
  menuDidRequestNewItemWithName = (menu: Object, name: string, indexPath: CYLIndexPath): void => {
    this.events.push(`add ${name} at ${indexPath.item}-${indexPath.section}`);
    this.sections[indexPath.section].splice(indexPath.item, 0, name);
    this.identifiers[indexPath.section].splice(indexPath.item, 0, `id-${name}`);
    (menu as CYLTagListState).reloadMenuData();
  };
}

/** `CYLEditableTagSource` that renames (iOS: it responds to `menuRenameItem(at:to:)`). */
class CYLRenamableTagSource extends CYLEditableTagSource {
  menuRenameItem = (indexPath: CYLIndexPath, title: string): void => {
    this.sections[indexPath.section][indexPath.item] = title;
  };
}

/** A remote source that answers with fixed items. */
class CYLFakeItemsRemoteSource implements CYLTagListRemoteSource {
  items: Map<string, CYLTagListCacheItem[]>;

  constructor(items: Map<string, CYLTagListCacheItem[]>) {
    this.items = items;
  }

  fetchSectionsWithKeys(keys: string[], completion: (sections: Map<string, string[]> | undefined,
    error: Error | undefined) => void): void {
    const sections = new Map<string, string[]>();
    this.items.forEach((items: CYLTagListCacheItem[], key: string) =>
      sections.set(key, items.map((item: CYLTagListCacheItem) => item.title)));
    completion(sections, undefined);
  }

  fetchItemsWithKeys = (keys: string[], completion: (items: Map<string, CYLTagListCacheItem[]> | undefined,
    error: Error | undefined) => void): void => {
    completion(this.items, undefined);
  };
}

/** A remote source that answers at once with fixed sections, or fails. */
class CYLFakeRemoteSource implements CYLTagListRemoteSource {
  private titles?: string[];

  constructor(titles: string[] | undefined) {
    this.titles = titles;
  }

  fetchSectionsWithKeys(keys: string[], completion: (sections: Map<string, string[]> | undefined,
    error: Error | undefined) => void): void {
    if (this.titles === undefined) {
      completion(undefined, new Error('CYLFake'));
      return;
    }
    const sections = new Map<string, string[]>();
    sections.set('mine', this.titles);
    completion(sections, undefined);
  }
}

function makeList(source: CYLEditableTagSource): CYLTagListState {
  const list = new CYLTagListState();
  list.menuDataSource = source;
  list.menuDelegate = source;
  list.selectionMode = CYLMenuSelectionMode.multiple;
  list.setLayoutWidth(320);
  list.reloadMenuData();
  return list;
}

/**
 * CYLTagListState's editing mode and its cache, as iOS CYLTagListEditingTests and Android CYLTagListEditingTest. Host
 * tests have no app context, so the stores keep their titles in memory for the process (a new store of the same policy
 * and name reads them back, as after a relaunch on a device).
 */
export default function tagListEditingTest() {
  let saved: CYLTextMeasurer = FIXED;

  describe('CYLTagListEditing', () => {
    beforeEach(() => {
      saved = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = FIXED;
    });

    afterEach(() => {
      CYLTagButtonMetrics.textMeasurer = saved;
    });

    it('showsDeleteIndicatorsAndTheAddControlOnlyWhileEditing', 0, () => {
      const source = new CYLEditableTagSource([['Recent A', 'Recent B'], ['Family', 'Friends', 'Clients']]);
      source.editableSections = [1];
      const list = makeList(source);
      expect(list.isEditing).assertFalse();
      expect(list.isDeletable(path(1, 0))).assertFalse();
      const heightBefore = list.contentHeight;
      list.setEditing(true, false);
      expect(list.isEditing).assertTrue();
      expect(source.events.join(',')).assertEqual('edit');
      expect(list.isDeletable(path(1, 0))).assertTrue();
      expect(list.isDeletable(path(0, 0))).assertFalse();
      const frame = list.addItemViewFrame;
      expect(frame !== undefined && frame.height > 0).assertTrue();
      expect(list.contentHeight > heightBefore).assertTrue();
      list.setEditing(false, false);
      expect(list.addItemViewFrame === undefined).assertTrue();
      expect(Math.abs(list.contentHeight - heightBefore) < 0.5).assertTrue();
      expect(list.isDeletable(path(1, 0))).assertFalse();
      expect(source.events.join(',')).assertEqual('edit,done');
    });

    it('tapReportsWithoutSelectingAndDeleteRemoves', 0, () => {
      const source = new CYLEditableTagSource([['Family', 'Friends', 'Clients']]);
      const list = makeList(source);
      list.setEditing(true, false);
      list.tapItem(path(0, 1));
      expect(source.events[source.events.length - 1]).assertEqual('select 1-0');
      expect(list.selectedIndexPaths.length).assertEqual(0);
      list.deleteItem(path(0, 0));
      expect(source.sections[0].join(',')).assertEqual('Friends,Clients');
    });

    it('unfoldsAndAddsThroughTheAddControl', 0, () => {
      const titles: string[] = [];
      for (let i = 0; i < 30; i++) {
        titles.push(`Tag ${i}`);
      }
      const source = new CYLEditableTagSource([titles]);
      const list = makeList(source);
      list.showsSectionHeaders = false;
      list.defaultVisibleRows = 2;
      list.foldStyle = CYLMenuFoldStyle.footerChevron;
      expect(list.canFoldSection(0)).assertTrue();
      expect(list.numberOfVisibleItems(0) < 30).assertTrue();
      list.setEditing(true, false);
      expect(list.canFoldSection(0)).assertFalse();
      expect(list.numberOfVisibleItems(0)).assertEqual(30);
      list.addItemView.text = '  Book Club  ';
      list.addItemView.submit();
      expect(source.events[source.events.length - 1]).assertEqual('add Book Club at 30-0');
      expect(source.sections[0][30]).assertEqual('Book Club');
      expect(list.addItemView.text).assertEqual('');
      list.setEditing(false, false);
      expect(list.canFoldSection(0)).assertTrue();
    });

    it('enablesReorderingOfEditableSections', 0, () => {
      const source = new CYLEditableTagSource([['Recent A', 'Recent B'], ['Family', 'Friends']]);
      source.editableSections = [1];
      const list = makeList(source);
      expect(list.allowsReordering).assertFalse();
      expect(list.canMoveItem(path(1, 0))).assertFalse();
      list.setEditing(true, false);
      expect(list.canMoveItem(path(1, 0))).assertTrue();
      expect(list.canMoveItem(path(0, 0))).assertFalse();
      list.setEditing(false, false);
      expect(list.canMoveItem(path(1, 0))).assertFalse();
    });

    it('finishingEditingReportsTheEditedSectionsForUploading', 0, () => {
      const source = new CYLEditableTagSource([['Recent A'], ['Family', 'Friends', 'Clients']]);
      source.editableSections = [1];
      const list = makeList(source);
      let reported: Map<string, string[]> | undefined = undefined;
      list.editingFinishHandler = (titles: Map<string, string[]>) => {
        reported = titles;
      };
      list.setEditing(true, false);
      list.moveItem(path(1, 2), path(1, 0));
      expect(reported === undefined).assertTrue();
      list.setEditing(false, false);
      const titles = reported as Map<string, string[]> | undefined;
      expect(titles !== undefined && titles.size === 1).assertTrue();
      expect((titles?.get('1') ?? []).join(',')).assertEqual('Clients,Family,Friends');
    });

    it('loadPoliciesOrderTheCacheAndTheServer', 0, () => {
      const loads = (policy: CYLTagListLoadPolicy, cached: string[] | undefined, remote: string[] | undefined): string[] => {
        const store = new CYLTagListStore(CYLTagListCachePolicy.userDefaults, 'TagListEditingTest.load');
        store.removeAllTitles();
        if (cached !== undefined) {
          store.saveTitles(cached, 'mine');
        }
        const list = new CYLTagListState();
        list.cache = store;
        list.remoteSource = new CYLFakeRemoteSource(remote);
        list.loadPolicy = policy;
        const events: string[] = [];
        list.loadSectionsWithKeys(['mine'], (sections: Map<string, string[]>, origin: CYLTagListDataOrigin) => {
          events.push(`${origin === CYLTagListDataOrigin.cache ? 'cache' : 'network'} ${(sections.get('mine') ?? []).join(',')}`);
        });
        if (remote !== undefined && policy === CYLTagListLoadPolicy.cacheThenNetwork) {
          // A download is saved to the cache.
          expect((store.cachedTitles('mine') ?? []).join(',')).assertEqual(remote.join(','));
        }
        store.removeAllTitles();
        return events;
      };
      expect(loads(CYLTagListLoadPolicy.cacheThenNetwork, ['A', 'B'], ['B', 'A', 'C']).join('|'))
        .assertEqual('cache A,B|network B,A,C');
      expect(loads(CYLTagListLoadPolicy.cacheThenNetwork, ['A'], undefined).join('|')).assertEqual('cache A');
      expect(loads(CYLTagListLoadPolicy.cacheFirst, ['A'], ['B']).join('|')).assertEqual('cache A');
      expect(loads(CYLTagListLoadPolicy.cacheFirst, undefined, ['B']).join('|')).assertEqual('network B');
      expect(loads(CYLTagListLoadPolicy.networkFirst, ['A'], ['B']).join('|')).assertEqual('network B');
      expect(loads(CYLTagListLoadPolicy.networkFirst, ['A'], undefined).join('|')).assertEqual('cache A');
      expect(new CYLTagListState().loadPolicy).assertEqual(CYLTagListLoadPolicy.cacheThenNetwork);
    });

    it('savesEditsInEveryCachePolicy', 0, () => {
      const policies = [CYLTagListCachePolicy.database, CYLTagListCachePolicy.userDefaults, CYLTagListCachePolicy.sandboxFile];
      policies.forEach((policy: CYLTagListCachePolicy) => {
        const name = `CYLTagListEditingTest.${policy}`;
        new CYLTagListStore(policy, name).removeAllTitles();
        const source = new CYLEditableTagSource([['Recent A'], ['Family', 'Friends', 'Clients']]);
        source.editableSections = [1];
        const list = makeList(source);
        list.cacheName = name;
        list.cachePolicy = policy;
        expect(list.cachedTitlesInSection(1) === undefined).assertTrue();
        list.setEditing(true, false);
        list.moveItem(path(1, 2), path(1, 0));
        expect((list.cachedTitlesInSection(1) ?? []).join(',')).assertEqual('Clients,Family,Friends');
        list.deleteItem(path(1, 1));
        list.addItemView.text = 'Book Club';
        list.addItemView.submit();
        expect(list.cachedTitlesInSection(0) === undefined).assertTrue();
        const reopened = new CYLTagListStore(policy, name);
        expect((reopened.cachedTitles('1') ?? []).join(',')).assertEqual('Clients,Friends,Book Club');
        reopened.saveTitles([], '1');
        expect(reopened.cachedTitles('1') !== undefined && reopened.cachedTitles('1')!.length === 0).assertTrue();
        reopened.removeAllTitles();
        expect(reopened.cachedTitles('1') === undefined).assertTrue();
        expect(CYLTagListStore.cache(CYLTagListCachePolicy.none, name) === undefined).assertTrue();
      });
    });
    it('renamingShowsTwoIconsRenamesAndKeepsTheIdentifier', 0, () => {
      const name = 'CYLTagListEditingTest.rename';
      new CYLTagListStore(CYLTagListCachePolicy.userDefaults, name).removeAllTitles();
      const plain = makeList(new CYLEditableTagSource([['Recent A'], ['Family', 'Friends', 'Clients']]));
      plain.setEditing(true, false);
      expect(plain.isRenamable(path(1, 0))).assertFalse();
      const source = new CYLRenamableTagSource([['Recent A'], ['Family', 'Friends', 'Clients']]);
      source.editableSections = [1];
      const list = makeList(source);
      list.cacheName = name;
      list.cachePolicy = CYLTagListCachePolicy.userDefaults;
      expect(list.isRenamable(path(1, 0))).assertFalse();
      list.setEditing(true, false);
      expect(list.isRenamable(path(1, 0))).assertTrue();
      expect(list.isRenamable(path(0, 0))).assertFalse();
      expect(list.renamesOnTitleTapWhileEditing).assertTrue();

      // The button: two icons from the stack model, the defaults of iOS 3af1b7cd.
      const defaults = new CYLMenuStyle();
      expect(defaults.editingIndicatorSpacing).assertEqual(10);
      expect(defaults.editingIndicatorInsets.left).assertEqual(4);
      expect(defaults.editingIndicatorInsets.right).assertEqual(0);
      const button = new CYLTagButton();
      button.title = 'Family';
      button.showsDeleteIndicator = true;
      button.showsRenameIndicator = true;
      const size = button.intrinsicSize();
      button.setBounds(size.width, size.height);
      expect(button.editingIndicatorsView.items.length).assertEqual(2);
      expect(button.editingIconFrames.length).assertEqual(2);
      expect(button.renameIndicatorHitFrame.width > 0).assertTrue();
      expect(button.renameIndicatorHitFrame.maxX).assertEqual(button.deleteIndicatorHitFrame.x);
      expect(button.editingIconFrames[1].x - button.editingIconFrames[0].maxX).assertEqual(10);
      expect(button.editingIndicatorsView.axis).assertEqual('horizontal');
      expect(button.editingIndicatorsView.spacing).assertEqual(10);
      expect(button.editingIndicatorsFrame.width).assertEqual(button.editingIconFrames[1].maxX - button.editingIconFrames[0].x);
      const wider = new CYLMenuStyle();
      wider.editingIndicatorSpacing = 20;
      expect(CYLTagButton.widthWithRenameIndicator('Family', CYLSize.ZERO, true, true, wider) -
        CYLTagButton.widthWithRenameIndicator('Family', CYLSize.ZERO, true, true, defaults)).assertEqual(10);
      const padded = new CYLMenuStyle();
      padded.editingIndicatorInsets = new CYLEdgeInsets(2, 10, 2, 6);
      expect(CYLTagButton.widthWithRenameIndicator('Family', CYLSize.ZERO, true, true, padded) -
        CYLTagButton.widthWithRenameIndicator('Family', CYLSize.ZERO, true, true, defaults)).assertEqual(12);
      const cell = new CYLTagListCell();
      cell.configure('Family', undefined, undefined, undefined, defaults, false, true);
      cell.isDeletable = true;
      cell.isRenamable = true;
      cell.renamesOnTitleTap = true;
      expect(cell.button.showsRenameIndicator).assertTrue();
      expect(cell.renameAccessibilityLabel.length > 0).assertTrue();
      // A physical tap reaches the cell through the list's gesture: the pencil and the title rename, the cross deletes.
      let renames = 0;
      let deletes = 0;
      cell.renameHandler = () => {
        renames++;
      };
      cell.deleteHandler = () => {
        deletes++;
      };
      const cellSize = cell.button.intrinsicSize();
      cell.button.setBounds(cellSize.width, cellSize.height);
      const pencil = cell.button.renameIndicatorHitFrame;
      const cross = cell.button.deleteIndicatorHitFrame;
      const titleArea = cell.renameTitleFrame;
      expect(cell.performTapAt(pencil.x + pencil.width / 2, pencil.y + pencil.height / 2)).assertTrue();
      expect(renames).assertEqual(1);
      expect(cell.performTapAt(cross.x + cross.width / 2, cross.y + cross.height / 2)).assertTrue();
      expect(deletes).assertEqual(1);
      expect(cell.performTapAt(titleArea.x + 1, titleArea.y + titleArea.height / 2)).assertTrue();
      expect(renames).assertEqual(2);
      cell.renamesOnTitleTap = false;
      expect(cell.performTapAt(titleArea.x + 1, titleArea.y + titleArea.height / 2)).assertFalse();
      cell.prepareForReuse();
      expect(cell.isRenamable).assertFalse();
      expect(cell.performTapAt(pencil.x + pencil.width / 2, pencil.y + pencil.height / 2)).assertFalse();

      list.beginRenaming(path(1, 0));
      expect(list.renamingIndexPath?.item).assertEqual(0);
      list.finishRenaming('Family');
      expect(list.renamingIndexPath === undefined).assertTrue();
      list.moveItem(path(1, 1), path(1, 0));
      list.beginRenaming(path(1, 0));
      expect(list.addItemView.isRenaming).assertTrue();
      expect(list.addItemView.text).assertEqual('Friends');
      list.addItemView.text = 'Best Friends';
      list.addItemView.submit();
      expect(list.renamingIndexPath === undefined).assertTrue();
      expect(list.addItemView.isRenaming).assertFalse();
      expect(source.sections[1].join(',')).assertEqual('Best Friends,Family,Clients');
      expect(source.events[source.events.length - 1]).assertEqual('rename 0-1 Best Friends');
      const items = new CYLTagListStore(CYLTagListCachePolicy.userDefaults, name).cachedItems('1') ?? [];
      expect(items.map((item: CYLTagListCacheItem) => item.identifier).join(',')).assertEqual('id-Friends,id-Family,id-Clients');
      expect(items.map((item: CYLTagListCacheItem) => item.title).join(',')).assertEqual('Best Friends,Family,Clients');
      list.setEditing(false, false);
      const first = source.finishedItems?.get('1');
      expect(first !== undefined && first.length > 0 ? first[0].toString() : '').assertEqual('id-Friends:Best Friends');
      new CYLTagListStore(CYLTagListCachePolicy.userDefaults, name).removeAllTitles();
    });

    it('loadItemsKeepsIdentifiersFromTheServer', 0, () => {
      const store = new CYLTagListStore(CYLTagListCachePolicy.sandboxFile, 'CYLTagListEditingTest.items');
      store.removeAllTitles();
      store.saveItems([new CYLTagListCacheItem('t1', 'Family')], 'mine');
      expect((store.cachedTitles('mine') ?? []).join(',')).assertEqual('Family');
      const list = new CYLTagListState();
      list.cache = store;
      const server = new Map<string, CYLTagListCacheItem[]>();
      server.set('mine', [new CYLTagListCacheItem('t2', 'Work'), new CYLTagListCacheItem('t1', 'Home')]);
      list.remoteSource = new CYLFakeItemsRemoteSource(server);
      const events: string[] = [];
      list.loadItemsWithKeys(['mine'], (items: Map<string, CYLTagListCacheItem[]>, origin: CYLTagListDataOrigin) => {
        const from = origin === CYLTagListDataOrigin.cache ? 'cache' : 'network';
        events.push(`${from} ${(items.get('mine') ?? []).map((item: CYLTagListCacheItem) => item.toString()).join(',')}`);
      });
      expect(events.join('|')).assertEqual('cache t1:Family|network t2:Work,t1:Home');
      expect((store.cachedItems('mine') ?? []).map((item: CYLTagListCacheItem) => item.toString()).join(','))
        .assertEqual('t2:Work,t1:Home');
      store.saveTitles(['A'], 'mine');
      expect((store.cachedItems('mine') ?? [])[0].identifier).assertEqual('A');
      store.removeAllTitles();
    });

    it('anExternalEditorRenamesAndAdds', 0, () => {
      const source = new CYLRenamableTagSource([['Family', 'Friends']]);
      const list = makeList(source);
      list.showsAddItemViewWhileEditing = false;
      let request = '';
      list.renameRequestHandler = (indexPath: CYLIndexPath, title: string) => {
        request = `${indexPath.item}-${indexPath.section} ${title}`;
      };
      list.setEditing(true, false);
      expect(list.showsAddItemView).assertFalse();
      list.beginRenaming(path(0, 1));
      expect(request).assertEqual('1-0 Friends');
      expect(list.showsAddItemView).assertFalse();
      list.finishRenaming('Pals');
      expect(source.sections[0].join(',')).assertEqual('Family,Pals');
      list.beginRenaming(path(0, 0));
      list.cancelRenaming();
      expect(list.renamingIndexPath === undefined).assertTrue();
      expect(source.sections[0].join(',')).assertEqual('Family,Pals');
      list.submitNewItem('  Clients ');
      expect(source.sections[0].join(',')).assertEqual('Family,Pals,Clients');
    });

    it('theHeaderClearButtonIsBuiltIn', 0, () => {
      const source = new CYLEditableTagSource([['Coworkers', 'Clients'], ['Family']]);
      const list = makeList(source);
      let handled = -1;
      list.clearButtonHandler = (section: number) => {
        handled = section;
      };
      expect(list.showsClearButton(0)).assertTrue();
      expect(list.showsClearButton(1)).assertFalse();
      expect(list.clearButtonLabel(0).endsWith('Section 0')).assertTrue();
      list.tapClearButton(0);
      expect(source.events[source.events.length - 1]).assertEqual('clear 0');
      expect(handled).assertEqual(0);
    });
  });
}
