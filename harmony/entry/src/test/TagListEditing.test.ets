import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import {
  CYLFont, CYLIndexPath, CYLMenuDataSource, CYLMenuDelegate, CYLMenuFoldStyle, CYLMenuSelectionMode, CYLTagButtonMetrics,
  CYLTagListCachePolicy, CYLTagListDataOrigin, CYLTagListLoadPolicy, CYLTagListRemoteSource, CYLTagListState,
  CYLTagListStore, CYLTextMeasurer
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

  constructor(sections: string[][]) {
    this.sections = sections;
  }

  numberOfSectionsInMenu = (): number => this.sections.length;
  menuNumberOfItemsInSection = (section: number): number => this.sections[section].length;
  menuTitleForSection = (section: number): string => `Section ${section}`;
  menuTitleForItem = (indexPath: CYLIndexPath): string => this.sections[indexPath.section][indexPath.item];
  menuSectionAllowsEditing = (section: number): boolean =>
    this.editableSections === undefined || this.editableSections.includes(section);
  menuRemoveItem = (indexPath: CYLIndexPath): void => {
    this.sections[indexPath.section].splice(indexPath.item, 1);
  };
  menuMoveItem = (from: CYLIndexPath, to: CYLIndexPath): void => {
    const title = this.sections[from.section].splice(from.item, 1)[0];
    this.sections[to.section].splice(to.item, 0, title);
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
    (menu as CYLTagListState).reloadMenuData();
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
  });
}
