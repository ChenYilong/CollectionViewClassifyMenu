/**
 * Copyright (c) 2025 Huawei Technologies Co., Ltd.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import {RNAbility} from '@rnoh/react-native-openharmony';
import { AbilityConstant, Want } from '@kit.AbilityKit';
import { cylRegisterRNAnimationEngines } from '../CYLRNAnimationEngines';

export default class EntryAbility extends RNAbility {
  override onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    super.onCreate(want, launchParam);
    // The core plays no animation itself: the shell registers its Lottie engine before any tag is shown.
    cylRegisterRNAnimationEngines();
  }

  override getPagePath() {
    return 'pages/Index';
  }

  override getRNOHWorkerScriptUrl() {
    return "entry/ets/workers/RNOHWorker.ets"
  }
}
