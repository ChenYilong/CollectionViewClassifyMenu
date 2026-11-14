import { useCallback, useEffect, useRef, useState } from 'react';
import { ActivityIndicator, Button, FlatList, Modal, Pressable, StyleSheet, Text, View, useWindowDimensions } from 'react-native';
import { CylTagListView, type TagEvent } from 'react-native-cyl-tag-list';
import { PlacesDatabase } from './PlacesDatabase';
import { t } from './i18n';
import { launchFilter, launchSelection } from './launchOptions';

/**
 * The saved selections' scenarios: the iOS example's `CYLMenuLinkageClassifyScenario` / `…FilterScenario`.
 */
const CLASSIFY = 'menu.classify';
const FILTER = 'menu.filter';
const FILTER_ALL = ['0-0', '1-0'];

const STYLE = {
  itemHeight: 32,
  normal: { cornerRadius: 16, borderColor: '#D1D1D6', borderWidth: 1 },
  selected: { cornerRadius: 16, backgroundColor: '#E6F8F5', textColor: '#2AB9A0', borderColor: '#2AB9A0' },
};

type Place = Record<string, unknown>;

/**
 * The menu linkage screen of the iOS, Android and Flutter examples: one section per category (single choice); the
 * selected tag, the regions and the dishes of the filter select the places listed below (best rated first).
 */
export default function ClassifyPage() {
  const { height: windowHeight } = useWindowDimensions();
  const database = useRef<PlacesDatabase | null>(null);
  const [categories, setCategories] = useState<[string, string[]][]>([]);
  const [tags, setTags] = useState<string[]>([]);
  const [classifyItems, setClassifyItems] = useState<string[]>([]);
  const [filterItems, setFilterItems] = useState<string[]>(FILTER_ALL);
  const [places, setPlaces] = useState<Place[]>([]);
  const [menuHeight, setMenuHeight] = useState(1);
  const [filterVisible, setFilterVisible] = useState(false);
  const pendingFilter = useRef<string[]>(FILTER_ALL);
  const [ready, setReady] = useState(false);
  const [generation, setGeneration] = useState(0);

  const title = (item: string | undefined, titles: (section: number) => string[] | undefined) => {
    const [section, index] = (item ?? '').split('-').map(Number);
    return section == null || index == null || Number.isNaN(section) ? null : (titles(section)?.[index] ?? null);
  };
  const selectedTag = title(classifyItems[0], (s) => categories[s]?.[1]);
  // Item 0 of each filter section is 全部.
  const filterTitles = (section: number, titles: string[]) =>
    filterItems
      .filter((item) => item.startsWith(`${section}-`) && item !== `${section}-0`)
      .map((item) => title(item, () => ['', ...titles]))
      .filter((value): value is string => value != null);
  const selectedRegions = filterTitles(0, PlacesDatabase.regions);
  const selectedDishes = filterTitles(1, tags);

  useEffect(() => {
    (async () => {
      const db = await PlacesDatabase.open();
      database.current = db;
      setCategories(await db.categories());
      setTags(await db.tags());
      setClassifyItems(launchSelection ? [launchSelection] : ((await db.savedSelection(CLASSIFY)) ?? []));
      const filter = launchFilter ? launchFilter.split(',') : await db.savedSelection(FILTER);
      if (filter && filter.length) setFilterItems(filter);
      setReady(true);
    })();
  }, []);

  const tagKey = selectedTag ?? '';
  const regionsKey = selectedRegions.join('\n');
  const dishesKey = selectedDishes.join('\n');
  useEffect(() => {
    if (!ready || !database.current) return;
    database.current
      .places(tagKey || null, regionsKey ? regionsKey.split('\n') : [], dishesKey ? dishesKey.split('\n') : [])
      .then(setPlaces);
  }, [ready, tagKey, regionsKey, dishesKey]);

  const select = useCallback(
    (tag: TagEvent) => {
      const item = `${tag.section}-${tag.item}`;
      const next = classifyItems.includes(item) ? [] : [item];
      setClassifyItems(next);
      database.current?.saveSelection(CLASSIFY, next);
    },
    [classifyItems]
  );

  const confirmFilter = () => {
    setFilterVisible(false);
    setFilterItems(pendingFilter.current);
    database.current?.saveSelection(FILTER, pendingFilter.current);
  };

  const reset = () => {
    setClassifyItems([]);
    setFilterItems(FILTER_ALL);
    database.current?.saveSelection(CLASSIFY, []);
    database.current?.saveSelection(FILTER, FILTER_ALL);
    // A new list, so it shows the cleared selection.
    setGeneration((g) => g + 1);
  };

  if (!ready) return <ActivityIndicator style={styles.loading} />;

  const configuration = {
    selectionMode: 'single',
    allowsEmptySelection: true,
    selectedItems: classifyItems,
    defaultVisibleRows: 1,
    foldControl: { position: 'headerTrailing', content: 'iconAndTitle' },
    style: STYLE,
    sections: categories.map(([category, items]) => ({ title: category, items: items.map((name) => ({ title: name })) })),
  };
  const filterConfiguration = {
    selectionMode: 'multiple',
    selectedItems: filterItems,
    defaultVisibleRows: 2,
    foldControl: { position: 'headerTrailing', content: 'iconAndTitle' },
    style: STYLE,
    sections: [
      [t('Regions'), PlacesDatabase.regions],
      [t('Dishes'), tags],
    ].map(([sectionTitle, titles]) => ({
      title: sectionTitle as string,
      items: [{ title: t('All'), exclusive: true }, ...(titles as string[]).map((name) => ({ title: name }))],
    })),
  };
  const names = (values: string[]) => (values.length ? values.join('、') : t('All'));
  const filtered = selectedRegions.length > 0 || selectedDishes.length > 0;

  return (
    <View testID="classifyPage" style={styles.container}>
      <View style={styles.toolbar}>
        <Text style={styles.heading}>{t('Classify menu')}</Text>
        <Pressable testID="resetConditions" accessibilityRole="button" accessibilityLabel={t('Reset')} onPress={reset} style={styles.toolButton}>
          <Text style={styles.toolText}>↺</Text>
        </Pressable>
        <Pressable
          testID="openFilter"
          accessibilityRole="button"
          accessibilityLabel={t('Filter')}
          accessibilityState={{ selected: filtered }}
          onPress={() => {
            pendingFilter.current = filterItems;
            setFilterVisible(true);
          }}
          style={styles.toolButton}
        >
          <Text style={[styles.filterText, filtered && styles.toolTextOn]}>{filtered ? `${t('Filter')} ●` : t('Filter')}</Text>
        </Pressable>
      </View>
      <CylTagListView
        key={`menu-${generation}`}
        testID="classifyMenu"
        style={{ height: Math.min(Math.max(menuHeight, 1), windowHeight / 2) }}
        configuration={configuration}
        onTagTap={select}
        onContentHeightChange={setMenuHeight}
      />
      <View style={styles.divider} />
      <Text testID="placesSummary" style={styles.summary}>
        {`${selectedTag ?? t('All')} · ${names(selectedRegions)} · ${names(selectedDishes)} · ${places.length}`}
      </Text>
      <FlatList
        data={places}
        keyExtractor={(place, index) => `${place.name}-${index}`}
        contentContainerStyle={styles.list}
        ListEmptyComponent={<Text testID="noPlaces" style={styles.empty}>{t('No places match; try other conditions')}</Text>}
        renderItem={({ item }) => (
          <View style={styles.row}>
            <View style={styles.rowText}>
              <Text>{item.name as string}</Text>
              <Text style={styles.region}>{item.region as string}</Text>
            </View>
            <Text>{`★ ${(item.rating as number).toFixed(1)} · ¥${item.price}`}</Text>
          </View>
        )}
      />
      <Modal visible={filterVisible} animationType="slide" transparent onRequestClose={() => setFilterVisible(false)}>
        <View style={styles.sheetBackdrop}>
          <View style={[styles.sheet, { height: windowHeight * 0.6 }]}>
            <CylTagListView
              testID="filterMenu"
              style={styles.flex}
              configuration={filterConfiguration}
              onSelectionChange={(items) => {
                pendingFilter.current = items.map((i) => `${i.section}-${i.item}`);
              }}
            />
            <Button testID="confirmFilter" title={t('OK')} onPress={confirmFilter} />
          </View>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  loading: { flex: 1 },
  flex: { flex: 1 },
  toolbar: { flexDirection: 'row', alignItems: 'center', paddingHorizontal: 16, paddingBottom: 4 },
  heading: { flex: 1, fontSize: 20, fontWeight: '600' },
  toolButton: { minWidth: 44, minHeight: 44, alignItems: 'center', justifyContent: 'center' },
  toolText: { fontSize: 22 },
  toolTextOn: { color: '#2AB9A0' },
  // A word, not a symbol: Android's fonts lack the funnel glyphs.
  filterText: { fontSize: 17, color: '#007AFF' },
  divider: { height: StyleSheet.hairlineWidth, backgroundColor: '#C6C6C8' },
  summary: { paddingHorizontal: 16, paddingTop: 8, paddingBottom: 4, fontWeight: '600' },
  // Room for the tab bar and its raised plus button.
  list: { paddingBottom: 120 },
  empty: { padding: 24 },
  row: { flexDirection: 'row', alignItems: 'center', paddingHorizontal: 16, paddingVertical: 8 },
  rowText: { flex: 1 },
  region: { color: '#8E8E93', fontSize: 12 },
  sheetBackdrop: { flex: 1, justifyContent: 'flex-end', backgroundColor: 'rgba(0,0,0,0.3)' },
  sheet: { backgroundColor: '#fff', paddingBottom: 32, borderTopLeftRadius: 16, borderTopRightRadius: 16, overflow: 'hidden' },
});
