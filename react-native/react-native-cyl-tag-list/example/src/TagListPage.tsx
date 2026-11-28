import { useRef, useState } from 'react';
import { Button, ScrollView, StyleSheet, Switch, Text, View } from 'react-native';
import Slider from './Slider';
import { t } from './i18n';
import { CylTagListView, type CylTagListHandle } from 'react-native-cyl-tag-list';

const item = (title: string, image?: string) => ({ title, image });
// Lottie files of CYLTabBarController's tab icons, in the app bundle: the engine plays them.
const animated = (title: string, file: string) => ({ title, animation: `asset:${file}` });

const configuration = {
  selectionMode: 'multiple',
  defaultVisibleRows: 3,
  foldControl: { position: 'tail', content: 'icon' },
  style: {
    backgroundStyle: 'liquidGlass',
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
      title: 'Rive · pod CYLTabBarController/Rive',
      items: [
        // Rive state machines and inputs, as on the other platforms: without them the player drives the default input
        // "active", which these files do not have, so nothing plays.
        {
          ...animated('Home', 'house.riv'),
          // house.riv moves when its number input Rooms changes (Android since CYLTabBarController 3f262501).
          animationOptions: { stateMachine: 'State Machine 1', numberInput: 'Rooms', values: '3,4,5,6' },
        },
        {
          ...animated('Done', 'check.riv'),
          animationOptions: { stateMachine: 'State Machine 1', triggerInput: 'Check' },
        },
        {
          ...animated('Menu', 'menu_button.riv'),
          animationOptions: { stateMachine: 'State Machine', input: 'isOpen', duration: '0' },
        },
      ],
    },
    {
      // SVGA, as the iOS example's svga section: it plays once at its own speed (CYLTabBarController's SVGA player has
      // no speed or loop API yet).
      title: 'SVGA · pod CYLAnimatedItem/SVGA',
      items: [
        animated('Home', 'tab_home.svga'),
        animated('Search', 'tab_search.svga'),
        animated('Messages', 'tab_chat.svga'),
        animated('Me', 'tab_profile.svga'),
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

export default function TagListPage() {
  const list = useRef<CylTagListHandle>(null);
  const [speed, setSpeed] = useState(1);
  const [loops, setLoops] = useState(false);
  const [height, setHeight] = useState(1);
  const [status, setStatus] = useState('');
  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        <CylTagListView
          ref={list}
          testID="tagList"
          style={{ height }}
          configuration={configuration}
          animationSpeed={speed}
          animationLoops={loops}
          onContentHeightChange={setHeight}
          onTagTap={(tag) => setStatus(`${t('Tapped')} ${tag.title}`)}
          onSelectionChange={(items) => setStatus(`${t('Selected')}: ${items.map((i) => i.title).join(', ')}`)}
        />
        <View style={styles.controls}>
          <Text testID="speedLabel">
            {t('Speed')} {speed.toFixed(2)}x
          </Text>
          <Slider value={speed} onChange={setSpeed} />
          <View style={styles.row}>
            <Text>{t('Loop')}</Text>
            <Switch testID="loopSwitch" value={loops} onValueChange={setLoops} />
          </View>
          <Button testID="playAll" title={t('Play all')} onPress={() => list.current?.playAll()} />
          <Text testID="status">{status}</Text>
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  // Room for the tab bar and its raised plus button below the page.
  content: { paddingBottom: 120 },
  controls: { padding: 16, gap: 8 },
  row: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
});
