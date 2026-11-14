import path from 'node:path';
import { defineConfig, mergeConfig } from 'vite';

import config from 'react-native-builder-bob/vite-config';
import pack from '../package.json' with { type: 'json' };

export default defineConfig((env) =>
  mergeConfig(config(env), {
    resolve: {
      alias: {
        [pack.name]: path.resolve(import.meta.dirname, '..'),
      },
      conditions: ['react-native-cyl-tag-list-source'],
      dedupe: Object.keys(pack.peerDependencies),
    },
  })
);
