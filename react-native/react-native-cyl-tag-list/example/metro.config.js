const path = require('path');
const { getDefaultConfig } = require('@react-native/metro-config');
const { withMetroConfig } = require('react-native-monorepo-config');

const root = path.resolve(__dirname, '..');

/**
 * Metro configuration
 * https://facebook.github.io/metro/docs/configuration
 *
 * @type {import('metro-config').MetroConfig}
 */
const config = withMetroConfig(getDefaultConfig(__dirname), {
  root,
  dirname: __dirname,
  conditions: ['react-native-cyl-tag-list-source', 'react-native-cyltabbar-source'],
});

// react-native-cyltabbar comes from a checkout of CYLTabBarController (scripts/fetch-cyltabbar.sh): Metro reads its
// sources (the condition above) and watches the checkout, whose files are outside this project.
const cyltabbar = path.join(root, '.deps/CYLTabBarController/CrossPlatform/react-native-cyltabbar');
config.watchFolders = [...(config.watchFolders ?? []), cyltabbar];
const resolveRequest = config.resolver.resolveRequest;
config.resolver.resolveRequest = (context, moduleName, platform) =>
  moduleName === 'react-native-cyltabbar'
    ? { type: 'sourceFile', filePath: path.join(cyltabbar, 'src/index.tsx') }
    : (resolveRequest ?? context.resolveRequest)(context, moduleName, platform);

module.exports = config;
