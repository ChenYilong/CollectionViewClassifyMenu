import { common } from '@kit.AbilityKit';
import { CYLIndexPath, CYLTagListView, CYLTagTap } from '@cyl/classifymenu';
import { Place, PlacesDatabase, REGIONS } from '../data/PlacesDatabase';

const CLASSIFY = 'menu.classify';
const FILTER = 'menu.filter';
const ALL = '全部';

function key(p: CYLIndexPath): string {
  return `${p.section}-${p.item}`;
}

function path(k: string): CYLIndexPath {
  const parts = k.split('-');
  return { section: Number(parts[0]), item: Number(parts[1]) };
}

function selectedJSON(keys: string[]): CYLIndexPath[] {
  return keys.map(path);
}

interface ItemJSON {
  title: string;
  exclusive?: boolean;
}

interface SectionJSON {
  title: string;
  items: ItemJSON[];
}

interface CornerJSON {
  cornerRadius: number;
}

interface StyleJSON {
  itemHeight: number;
  normal: CornerJSON;
  selected: CornerJSON;
}

interface ConfigJSON {
  selectionMode: string;
  defaultVisibleRows?: number;
  selected?: CYLIndexPath[];
  style?: StyleJSON;
  sections: SectionJSON[];
}

function items(titles: string[]): ItemJSON[] {
  return titles.map((t): ItemJSON => ({ title: t }));
}

/** The example's screens, one bottom tab each (tab bars stay at the bottom, AGENTS.md). */
@Entry
@Component
struct Index {
  @State tab: number = 0;

  @Builder
  tabBar(title: string, symbol: string, index: number) {
    Column() {
      Text(symbol).fontSize(22)
      Text(title).fontSize(11).fontColor(this.tab === index ? '#2AB9A0' : '#8E8E93')
    }.id(`tab-${title}`)
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.tab }) {
      TabContent() {
        TagsPage()
      }.tabBar(this.tabBar('Tags', '🏷️', 0))

      TabContent() {
        ClassifyPage()
      }.tabBar(this.tabBar('Classify', '🗂️', 1))
    }
    .onChange((index: number) => this.tab = index)
  }
}

/** A tag list from one configuration: multiple selection, two rows folded. */
@Component
struct TagsPage {
  @State lastTap: string = '';

  private configuration(): string {
    const titles = ['Home', 'Search', 'Messages', 'Profile', 'Favorites', 'Settings', 'Camera', 'Music', 'Maps',
      'Calendar', 'A long tag that starts a new line', '你好，这是一个TAG。'];
    const config: ConfigJSON = {
      selectionMode: 'multiple',
      defaultVisibleRows: 2,
      style: { itemHeight: 36, normal: { cornerRadius: 0 }, selected: { cornerRadius: 0 } },
      sections: [{ title: 'Tags', items: items(titles) }]
    };
    return JSON.stringify(config);
  }

  build() {
    Column() {
      Text('Tags').fontSize(24).fontWeight(FontWeight.Bold).padding(16).width('100%')
      CYLTagListView({
        configuration: this.configuration(),
        onTagTap: (tap: CYLTagTap) => this.lastTap = `Tapped ${tap.title}`
      })
      if (this.lastTap !== '') {
        Text(this.lastTap).padding(16).width('100%').id('lastTap')
      }
    }.height('100%').alignItems(HorizontalAlign.Start)
  }
}

/**
 * The classify menu (single choice) and the multiple filter of the iOS example's menu linkage screen: the selected tag
 * and the filter's regions and dishes select the places listed below, best rated first, saved in the database.
 */
@Component
struct ClassifyPage {
  @State categories: string[] = [];
  @State categoryTags: string[][] = [];
  @State dishes: string[] = [];
  @State classify: string[] = [];
  @State filter: string[] = [];
  @State draft: string[] = [];
  @State places: Place[] = [];
  @State showFilter: boolean = false;
  private db?: PlacesDatabase;

  async aboutToAppear(): Promise<void> {
    this.db = await PlacesDatabase.open(getContext(this) as common.UIAbilityContext);
    const categories = await this.db.categories();
    this.categories = Array.from(categories.keys());
    this.categoryTags = this.categories.map((c) => categories.get(c) ?? []);
    this.dishes = await this.db.tags();
    this.classify = (await this.db.savedSelection(CLASSIFY)) ?? [];
    this.filter = (await this.db.savedSelection(FILTER)) ?? [];
    await this.reload();
  }

  private selectedTag(): string | null {
    if (this.classify.length === 0) {
      return null;
    }
    const p = path(this.classify[0]);
    return this.categoryTags[p.section]?.[p.item] ?? null;
  }

  private filterTitles(section: number, titles: string[]): string[] {
    return this.filter.map(path).filter((p) => p.section === section && p.item > 0).map((p) => titles[p.item - 1]);
  }

  private async reload(): Promise<void> {
    await this.db?.saveSelection(CLASSIFY, this.classify);
    await this.db?.saveSelection(FILTER, this.filter);
    this.places = (await this.db?.places(this.selectedTag(), this.filterTitles(0, REGIONS),
      this.filterTitles(1, this.dishes))) ?? [];
  }

  private classifyJSON(): string {
    const config: ConfigJSON = {
      selectionMode: 'single',
      defaultVisibleRows: 2,
      selected: selectedJSON(this.classify),
      sections: this.categories.map((c, i): SectionJSON => ({ title: c, items: items(this.categoryTags[i]) }))
    };
    return JSON.stringify(config);
  }

  private filterJSON(): string {
    const all: ItemJSON = { title: ALL, exclusive: true };
    const section = (title: string, titles: string[]): SectionJSON => ({ title: title, items: [all].concat(items(titles)) });
    const config: ConfigJSON = {
      selectionMode: 'multiple',
      selected: selectedJSON(this.draft),
      sections: [section('Regions', REGIONS), section('Dishes', this.dishes)]
    };
    return JSON.stringify(config);
  }

  private summary(): string {
    const parts: string[] = [this.selectedTag() ?? ALL];
    parts.push(...this.filterTitles(0, REGIONS), ...this.filterTitles(1, this.dishes));
    return `${parts.join(' · ')}: ${this.places.length} places`;
  }

  @Builder
  filterSheet() {
    Column() {
      Scroll() {
        CYLTagListView({
          configuration: this.filterJSON(),
          onSelectionChange: (selected: CYLIndexPath[]) => this.draft = selected.map(key)
        })
      }.layoutWeight(1)
      Button('OK').id('filterOK').width('90%').margin(16).onClick(() => {
        this.filter = this.draft;
        this.showFilter = false;
        this.reload();
      })
    }.height('100%')
  }

  build() {
    Column() {
      Row() {
        Text('Reset').fontColor('#2AB9A0').id('reset').onClick(() => {
          this.classify = [];
          this.filter = [];
          this.reload();
        })
        Text('Classify').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
        Text(this.filter.length > 0 ? 'Filter ●' : 'Filter').fontColor('#2AB9A0').id('filter').onClick(() => {
          this.draft = this.filter;
          this.showFilter = true;
        })
      }.width('100%').padding(16)
      List() {
        ListItem() {
          CYLTagListView({
            configuration: this.classifyJSON(),
            onSelectionChange: (selected: CYLIndexPath[]) => {
              this.classify = selected.map(key);
              this.reload();
            }
          })
        }
        ListItem() {
          Text(this.summary()).fontSize(13).fontColor('#8E8E93').padding(16).id('summary')
        }
        if (this.places.length === 0) {
          ListItem() {
            Text('No places match').padding(16).id('empty')
          }
        }
        ForEach(this.places, (place: Place) => {
          ListItem() {
            Row() {
              Column() {
                Text(place.name).fontSize(15)
                Text(place.region).fontSize(12).fontColor('#8E8E93')
              }.alignItems(HorizontalAlign.Start).layoutWeight(1)
              Text(`★ ${place.rating.toFixed(1)} · ¥${place.price}`).fontSize(13)
            }.padding({ left: 16, right: 16, top: 8, bottom: 8 })
          }
        }, (place: Place) => `${place.name}-${place.region}`)
      }.layoutWeight(1)
    }
    .height('100%')
    .bindSheet($$this.showFilter, this.filterSheet(), { height: SheetSize.LARGE, title: { title: 'Filter' } })
  }
}
