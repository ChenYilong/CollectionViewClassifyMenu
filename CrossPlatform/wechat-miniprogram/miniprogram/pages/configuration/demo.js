/**
 * The two ways CYLTagConfigurationDemoViewController creates a tag list, without `wx` calls (node tests): from the
 * configuration file Configurations/animated-tags.json (`CYLTagListView(configurationFile:)`, copied as is to
 * data/animations/Configurations by scripts/export-animations.py) and from a dictionary (`init(configuration:)`).
 */

/** The file's path in the iOS app, as the screen shows it. */
const CONFIGURATION_FILE_PATH = 'CYLMenuExample.bundle/Configurations/animated-tags.json';
/** The copy in the Mini Program package. */
const PACKAGE_FILE_PATH = '/data/animations/Configurations/animated-tags.json';

/**
 * `CYLTagListView.configuration(contentsOfFile:)`: the file's dictionary, or an error with the core's messages
 * ("No configuration file at …", "… does not hold a dictionary").
 * @param {(path: string) => string} read returns the file's text, throws when there is none
 * @returns {{configuration: object|null, error: string}}
 */
function readConfiguration(read, path = PACKAGE_FILE_PATH, shownPath = CONFIGURATION_FILE_PATH) {
  let text;
  try {
    text = read(path);
  } catch (error) {
    return { configuration: null, error: `No configuration file at ${shownPath}` };
  }
  let contents;
  try {
    contents = JSON.parse(text);
  } catch (error) {
    return { configuration: null, error: String(error && error.message ? error.message : error) };
  }
  if (!contents || typeof contents !== 'object' || Array.isArray(contents)) {
    return { configuration: null, error: `${shownPath} does not hold a dictionary` };
  }
  return { configuration: contents, error: '' };
}

/** The dictionary of the map example (mapConfiguration()). */
function mapConfiguration(t = (s) => s) {
  const normal = { iconColor: 'systemIndigo', borderColor: 'systemIndigo', borderWidth: 1, cornerRadius: 8 };
  const selected = { backgroundColor: 'systemIndigo', borderColor: 'systemIndigo', iconColor: '#FFFFFF', cornerRadius: 8 };
  const animation = (name) => `CYLMenuExample.bundle/Animations/${name}`;
  return {
    selectionMode: 'multiple',
    foldControl: { position: 'none', content: 'icon' },
    scrollEnabled: false,
    selectedItems: ['0-1'],
    style: {
      backgroundStyle: 'liquidGlass',
      imageSize: '{20, 20}',
      imageTitleSpacing: 4,
      itemHeight: 36,
      layoutCentered: true,
      normal,
      selected,
    },
    sections: [{
      title: t('字典（map）初始化'),
      items: [
        { title: 'Lottie', animation: animation('Lottie/tab_me_animate.json') },
        { title: 'GIF', animation: animation('GIF/cyl_tab_sample_animated.gif') },
        { title: 'Rive', animation: animation('Rive/menu_button.riv') },
        { title: 'SVGA', animation: animation('SVGA/tab_chat.svga') },
        { image: 'system:heart', selectedImage: 'system:heart.fill' },
        'Text only',
      ],
    }],
  };
}

module.exports = { CONFIGURATION_FILE_PATH, PACKAGE_FILE_PATH, readConfiguration, mapConfiguration };
