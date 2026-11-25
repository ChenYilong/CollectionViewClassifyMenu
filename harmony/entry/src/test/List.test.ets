import localUnitTest from './LocalUnit.test';
import localizationTest from './Localization.test';
import tagListStateTest from './TagListState.test';
import classifyAndFilterTest from './ClassifyAndFilter.test';
import imageTagAndPlayerTest from './ImageTagAndPlayer.test';
import styleAndModelsTest from './StyleAndModels.test';
import launchOptionsTest from './LaunchOptions.test';
import reviewFilterTapTest from './ReviewFilterTap.test';
import tagButtonTest from './TagButton.test';
import androidParityTest from './AndroidParity.test';
import tagListEditingTest from './TagListEditing.test';
import tagListWordPickerTest from './TagListWordPicker.test';
import tagListTailFoldTest from './TagListTailFold.test';
import tagLongPressActionTest from './TagLongPressAction.test';
import tagTitleMaxLinesTest from './TagTitleMaxLines.test';

export default function testsuite() {
  localUnitTest();
  localizationTest();
  tagListStateTest();
  classifyAndFilterTest();
  imageTagAndPlayerTest();
  styleAndModelsTest();
  launchOptionsTest();
  reviewFilterTapTest();
  tagButtonTest();
  androidParityTest();
  tagListEditingTest();
  tagListWordPickerTest();
  tagListTailFoldTest();
  tagLongPressActionTest();
  tagTitleMaxLinesTest();
}
