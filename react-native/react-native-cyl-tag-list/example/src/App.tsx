import { useState } from 'react';
import { Platform, StyleSheet, Text, View } from 'react-native';
import { CYLTabBar, type CYLTabBarItem, type CYLTabBarPlusButton } from 'react-native-cyltabbar';
import TagListPage from './TagListPage';
import ClassifyPage from './ClassifyPage';
import { t } from './i18n';
import { launchTab } from './launchOptions';

/**
 * The example's shell is CYLTabBarController's React Native component, as the iOS and Flutter examples use
 * CYLTabBarController: each tab is a page of the tag list demos.
 */
// SF Symbols on iOS; on Android, vector drawables of the example (res/drawable/cyl_tab_*.xml).
const icon = (symbol: string, drawable: string) => (Platform.OS === 'ios' ? symbol : drawable);
const ITEMS: CYLTabBarItem[] = [
  {
    title: t('Tags'),
    image: icon('system:tag', 'cyl_tab_tag'),
    selectedImage: icon('system:tag.fill', 'cyl_tab_tag'),
    identifier: 'tags',
  },
  {
    title: t('Classify'),
    image: icon('system:square.grid.2x2', 'cyl_tab_classify'),
    selectedImage: icon('system:square.grid.2x2.fill', 'cyl_tab_classify'),
    identifier: 'classify',
  },
];

// The raised plus button with a page of its own (CYLTabBarController's example: CYLPlusButtonSubclass).
const PLUS_BUTTON: CYLTabBarPlusButton = {
  title: t('Post'),
  image: require('./assets/post_normal.png'),
  selectedImage: require('./assets/post_highlight.png'),
  // The tab titles' size, so the plus button's title sits on their baseline.
  titleFont: 10,
  index: 1,
  size: [55, 80],
  imageSize: [55, 55],
  centerYOffset: -14,
  alignsTitle: true,
  identifier: 'plus',
  pageIdentifier: 'plus',
};

export default function App() {
  const [selectedIndex, setSelectedIndex] = useState(Number(launchTab ?? 0));
  const [plusSelected, setPlusSelected] = useState(false);
  let page;
  if (plusSelected) {
    page = (
      <Placeholder
        testID="plusPage"
        title={t('Post')}
        text={t('The plus button page')}
        detail={t('The raised plus button has a page of its own (pageIdentifier: plus); tap a tab to go back')}
      />
    );
  } else if (selectedIndex === 1) {
    page = <ClassifyPage />;
  } else {
    page = <TagListPage />;
  }
  return (
    <View style={styles.container}>
      <View style={styles.page}>{page}</View>
      <CYLTabBar
        style={styles.tabBar}
        items={ITEMS}
        plusButton={PLUS_BUTTON}
        selectedIndex={plusSelected ? -1 : selectedIndex}
        onTabSelect={(index) => {
          setPlusSelected(index < 0);
          if (index >= 0) setSelectedIndex(index);
        }}
      />
    </View>
  );
}

function Placeholder({ title, text, detail, testID }: { title: string; text: string; detail: string; testID: string }) {
  return (
    <View testID={testID} style={styles.placeholder}>
      <Text accessibilityRole="header" style={styles.placeholderTitle}>
        {title}
      </Text>
      <Text style={styles.placeholderText}>{text}</Text>
      <Text style={styles.placeholderDetail}>{detail}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  page: { flex: 1, paddingTop: 60 },
  tabBar: { position: 'absolute', left: 0, right: 0, bottom: 0 },
  placeholder: { flex: 1, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 32 },
  placeholderTitle: { fontSize: 22, fontWeight: '600', marginBottom: 12 },
  placeholderText: { fontSize: 16, marginBottom: 8 },
  placeholderDetail: { fontSize: 14, color: '#6B6B70', textAlign: 'center' },
});
