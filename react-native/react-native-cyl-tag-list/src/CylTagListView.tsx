import { forwardRef } from 'react';
import { View } from 'react-native';
import type { CylTagListHandle, CylTagListProps } from './CylTagListView.native';

/** Web: the native tag list exists only on iOS and Android. */
export const CylTagListView = forwardRef<CylTagListHandle, CylTagListProps>(function CylTagListView({ style }, _ref) {
  return <View style={style} />;
});
