/**
 * @format
 * One app per tab: CYLTabBarController (ArkTS, harmony/entry/src/main/ets/pages/Index.ets) shows each as the page of
 * its tab, on one React Native instance.
 */
import { AppRegistry } from 'react-native';
import { ClassifyApp, PostApp, TagsApp } from './App';

AppRegistry.registerComponent('Tags', () => TagsApp);
AppRegistry.registerComponent('Classify', () => ClassifyApp);
AppRegistry.registerComponent('Post', () => PostApp);
