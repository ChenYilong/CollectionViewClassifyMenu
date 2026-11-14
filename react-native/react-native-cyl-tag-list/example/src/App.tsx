import { useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { CYLTabBar, type CYLTabBarItem, type CYLTabBarPlusButton } from 'react-native-cyltabbar';
import TagListPage from './TagListPage';
import { t } from './i18n';

/**
 * The example's shell is CYLTabBarController's React Native component, as the iOS and Flutter examples use
 * CYLTabBarController: each tab is a page of the tag list demos.
 */
const ITEMS: CYLTabBarItem[] = [
  { title: t('Tags'), image: 'system:tag', selectedImage: 'system:tag.fill', identifier: 'tags' },
  { title: t('Classify'), image: 'system:square.grid.2x2', selectedImage: 'system:square.grid.2x2.fill', identifier: 'classify' },
];

// The raised plus button with a page of its own (CYLTabBarController's example: CYLPlusButtonSubclass).
const PLUS_BUTTON: CYLTabBarPlusButton = {
  title: t('Post'),
  image: require('./assets/post_normal.png'),
  selectedImage: require('./assets/post_highlight.png'),
  titleFont: 9.5,
  index: 1,
  size: [55, 80],
  imageSize: [55, 55],
  centerYOffset: -14,
  alignsTitle: true,
  identifier: 'plus',
  pageIdentifier: 'plus',
};

export default function App() {
  const [selectedIndex, setSelectedIndex] = useState(0);
  const [plusSelected, setPlusSelected] = useState(false);
  let page;
  if (plusSelected) {
    page = <Placeholder testID="plusPage" text={t('The plus button page')} />;
  } else if (selectedIndex === 1) {
    page = <Placeholder testID="classifyPage" text={t('Classify')} />;
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

function Placeholder({ text, testID }: { text: string; testID: string }) {
  return (
    <View testID={testID} style={styles.placeholder}>
      <Text>{text}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  page: { flex: 1, paddingTop: 60 },
  tabBar: { position: 'absolute', left: 0, right: 0, bottom: 0 },
  placeholder: { flex: 1, alignItems: 'center', justifyContent: 'center' },
});
