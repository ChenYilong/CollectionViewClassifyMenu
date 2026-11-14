import { useRef, useState } from 'react';
import { Button, SafeAreaView, ScrollView, StyleSheet, Switch, Text, View } from 'react-native';
import Slider from './Slider';
import { CylTagListView, type CylTagListHandle } from 'react-native-cyl-tag-list';

const item = (title: string, image?: string) => ({ title, image });
// Lottie files of CYLTabBarController's tab icons, in the app bundle: the engine plays them.
const animated = (title: string, file: string) => ({ title, animation: `asset:${file}` });

const configuration = {
  selectionMode: 'multiple',
  defaultVisibleRows: 3,
  foldControl: { position: 'tail', content: 'icon' },
  style: {
    itemHeight: 36,
    imageSize: '{18, 18}',
    normal: { cornerRadius: 0, borderColor: '#D1D1D6', borderWidth: 1 },
    selected: { cornerRadius: 0, backgroundColor: '#E6F8F5', textColor: '#2AB9A0', borderColor: '#2AB9A0' },
  },
  sections: [
    {
      title: 'Lottie · pod CYLTabBarController/Lottie',
      items: [
        animated('Home', 'tab_home_animate.json'),
        animated('Messages', 'tab_message_animate.json'),
        animated('Search', 'tab_search_animate.json'),
        animated('Me', 'tab_me_animate.json'),
      ],
    },
    {
      title: 'Tags',
      items: [
        item('Home', 'system:house'),
        item('Search', 'system:magnifyingglass'),
        item('Messages', 'system:message'),
        item('Profile', 'system:person'),
        item('Favorites', 'system:star'),
        item('Settings', 'system:gearshape'),
        item('Camera', 'system:camera'),
        item('Music', 'system:music.note'),
        item('Maps', 'system:map'),
        item('Calendar', 'system:calendar'),
      ],
    },
  ],
};

export default function App() {
  const list = useRef<CylTagListHandle>(null);
  const [speed, setSpeed] = useState(1);
  const [loops, setLoops] = useState(false);
  const [height, setHeight] = useState(1);
  const [status, setStatus] = useState('');
  return (
    <SafeAreaView style={styles.container}>
      <ScrollView>
        <CylTagListView
          ref={list}
          testID="tagList"
          style={{ height }}
          configuration={configuration}
          animationSpeed={speed}
          animationLoops={loops}
          onContentHeightChange={setHeight}
          onTagTap={(tag) => setStatus(`Tapped ${tag.title}`)}
          onSelectionChange={(items) => setStatus(`Selected: ${items.map((i) => i.title).join(', ')}`)}
        />
        <View style={styles.controls}>
          <Text testID="speedLabel">Speed {speed.toFixed(2)}x</Text>
          <Slider value={speed} onChange={setSpeed} />
          <View style={styles.row}>
            <Text>Loop</Text>
            <Switch testID="loopSwitch" value={loops} onValueChange={setLoops} />
          </View>
          <Button testID="playAll" title="Play all" onPress={() => list.current?.playAll()} />
          <Text testID="status">{status}</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  controls: { padding: 16, gap: 8 },
  row: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
});
