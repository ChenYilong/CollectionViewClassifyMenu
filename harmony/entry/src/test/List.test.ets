import localUnitTest from './LocalUnit.test';
import svgaDecoderTest from './SVGADecoder.test';
import localizationTest from './Localization.test';

export default function testsuite() {
  localUnitTest();
  svgaDecoderTest();
  localizationTest();
}
