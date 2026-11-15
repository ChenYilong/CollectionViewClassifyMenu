/**
 * The React Native example on HarmonyOS NEXT (React Native for OpenHarmony 0.86): the pages of
 * react-native/react-native-cyl-tag-list/example. The tab bar is CYLTabBarController's HarmonyOS library (ArkTS), as
 * the iOS/Android example uses CYLTabBarController's React Native component: each tab shows one of these apps.
 */
import { SafeAreaView, StyleSheet, Text, View } from 'react-native';
import TagListPage from './src/TagListPage';
import ClassifyPage from './src/ClassifyPage';
import { t } from './src/i18n';

export function TagsApp() {
  return (
    <SafeAreaView style={styles.root}>
      <TagListPage />
    </SafeAreaView>
  );
}

export function ClassifyApp() {
  return (
    <SafeAreaView style={styles.root}>
      <ClassifyPage />
    </SafeAreaView>
  );
}

/**
 * The page of the raised plus button (the iOS/Android example's placeholder).
 */
export function PostApp() {
  return (
    <View testID="plusPage" style={styles.placeholder}>
      <Text>{t('The plus button page')}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#FFFFFF' },
  placeholder: { flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: '#FFFFFF' },
});
