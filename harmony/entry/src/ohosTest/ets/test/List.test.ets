import abilityTest from './Ability.test';
import exampleUiTest from './ExampleUi.test';
import queryScenariosTest from './QueryScenarios.test';
import stylesAndAnimationsTest from './StylesAndAnimations.test';
import samplesTest from './Samples.test';

export default function testsuite() {
  abilityTest();
  exampleUiTest();
  queryScenariosTest();
  stylesAndAnimationsTest();
  samplesTest();
}
