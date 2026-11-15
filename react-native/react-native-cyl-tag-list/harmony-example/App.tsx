/**
 * The React Native example on HarmonyOS NEXT (React Native for OpenHarmony 0.86): the Tags screen of
 * react-native/react-native-cyl-tag-list/example with its playback controls, over the ArkTS CYLTagListView.
 */
import { SafeAreaView, StyleSheet } from 'react-native';
import TagListPage from './src/TagListPage';

export default function App() {
  return (
    <SafeAreaView style={styles.root}>
      <TagListPage />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({ root: { flex: 1, backgroundColor: '#FFFFFF' } });
