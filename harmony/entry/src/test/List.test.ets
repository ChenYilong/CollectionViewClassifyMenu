import localUnitTest from './LocalUnit.test';
import svgaDecoderTest from './SVGADecoder.test';
import localizationTest from './Localization.test';
import tagListStateTest from './TagListState.test';
import classifyAndFilterTest from './ClassifyAndFilter.test';
import imageTagAndPlayerTest from './ImageTagAndPlayer.test';
import styleAndModelsTest from './StyleAndModels.test';
import launchOptionsTest from './LaunchOptions.test';

export default function testsuite() {
  localUnitTest();
  svgaDecoderTest();
  localizationTest();
  tagListStateTest();
  classifyAndFilterTest();
  imageTagAndPlayerTest();
  styleAndModelsTest();
  launchOptionsTest();
}
