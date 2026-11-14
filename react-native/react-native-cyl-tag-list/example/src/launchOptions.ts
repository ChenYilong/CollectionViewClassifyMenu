import { Platform, Settings } from 'react-native';

/**
 * Launch arguments for screenshots and checks without taps (iOS: `simctl launch <app> -CYLTab 1 -CYLSelect 0-1
 * -CYLFilter 0-3,1-0`, read from the argument domain of user defaults), like the Flutter example's --dart-define values.
 */
function value(key: string): string | undefined {
  if (Platform.OS !== 'ios') return undefined;
  const found = Settings.get(key);
  return found == null ? undefined : String(found);
}

export const launchTab = value('CYLTab');
export const launchSelection = value('CYLSelect');
export const launchFilter = value('CYLFilter');
