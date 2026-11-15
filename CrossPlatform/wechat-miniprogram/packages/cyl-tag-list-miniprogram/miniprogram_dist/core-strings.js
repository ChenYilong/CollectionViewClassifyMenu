/**
 * The core library's own strings (CollectionViewClassifyMenu/Resources/Localization/*.lproj/CYLClassifyMenu.strings),
 * read by `CYLMenuLocalizedString` in the core: the accessibility names of the tag views and the image tag view. They
 * follow the language of locale.js. No `wx` calls.
 */
const locale = require('./locale.js');

const TABLES = {
  'zh-Hans': {
    CYLMenuDeleteTag: '删除',
    CYLMenuLongPress: '长按',
    CYLMenuMoveTagEarlier: '前移',
    CYLMenuMoveTagLater: '后移',
    CYLMenuTagMoved: '已移到第 %ld 个',
    CYLImageTagGroup: '标签组：%@',
    CYLImageTagPicture: '图片',
    CYLImageTagTurnHint: '轻点两下改变方向',
    CYLImageTagMoveUp: '上移',
    CYLImageTagMoveDown: '下移',
    CYLImageTagMoveLeft: '左移',
    CYLImageTagMoveRight: '右移',
  },
  'zh-Hant': {
    CYLMenuDeleteTag: '刪除',
    CYLMenuLongPress: '長按',
    CYLMenuMoveTagEarlier: '前移',
    CYLMenuMoveTagLater: '後移',
    CYLMenuTagMoved: '已移到第 %ld 個',
    CYLImageTagGroup: '標籤組：%@',
    CYLImageTagPicture: '圖片',
    CYLImageTagTurnHint: '點兩下改變方向',
    CYLImageTagMoveUp: '上移',
    CYLImageTagMoveDown: '下移',
    CYLImageTagMoveLeft: '左移',
    CYLImageTagMoveRight: '右移',
  },
  en: {
    CYLMenuDeleteTag: 'Delete',
    CYLMenuLongPress: 'Long press',
    CYLMenuMoveTagEarlier: 'Move earlier',
    CYLMenuMoveTagLater: 'Move later',
    CYLMenuTagMoved: 'Moved to position %ld',
    CYLImageTagGroup: 'Tag group: %@',
    CYLImageTagPicture: 'Picture',
    CYLImageTagTurnHint: 'Double-tap to turn it',
    CYLImageTagMoveUp: 'Move up',
    CYLImageTagMoveDown: 'Move down',
    CYLImageTagMoveLeft: 'Move left',
    CYLImageTagMoveRight: 'Move right',
  },
};

/** The list separator of `ListFormatter` for the current language ("A, B and C" / "A、B和C"). */
function joinList(items) {
  const list = items.filter((item) => item);
  const language = locale.language();
  if (list.length <= 1) return list.join('');
  if (language === 'en') {
    if (list.length === 2) return `${list[0]} and ${list[1]}`;
    return `${list.slice(0, -1).join(', ')}, and ${list[list.length - 1]}`;
  }
  return `${list.slice(0, -1).join('、')}${language === 'zh-Hant' ? '和' : '和'}${list[list.length - 1]}`;
}

/** The core string `key` in the current language, with `args` filled in. */
function coreString(key, ...args) {
  const table = TABLES[locale.language()] || TABLES['zh-Hans'];
  const text = table[key] || TABLES['zh-Hans'][key] || key;
  return args.length ? locale.format(text, args) : text;
}

module.exports = { coreString, joinList, TABLES };
