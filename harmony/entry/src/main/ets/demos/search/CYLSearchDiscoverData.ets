/**
 * The data of the search history and discover demo (iOS CYLSearchDiscoverData.swift, from
 * CYLMenuExample.bundle/zh-Hans.lproj/search-discover.json): recent searches, and a pool of discover topics from which
 * the More button picks another random selection.
 */
export interface CYLDiscoverTopic {
  title: string;
  /** "hot": the hot icon (discover-hot.png, 热) after the title. */
  icon?: string;
}

export class CYLSearchDiscoverData {
  version: number = 1;
  /** How many topics the discover grid shows at a time. */
  discoverCount: number = 6;
  recentSearches: string[] = [];
  discover: CYLDiscoverTopic[] = [];

  static bundled(): CYLSearchDiscoverData {
    const data = new CYLSearchDiscoverData();
    data.recentSearches = ['swift 并发', 'SwiftUI 动画', 'iOS 26 液态玻璃适配', '标签云布局', 'Xcode 27 新功能',
      'CocoaPods 私有库', '折叠菜单交互设计', 'VoiceOver 测试清单', '暗黑模式配色', '为什么越想早睡越睡不着'];
    const hot = ['春季露营装备清单', '城市骑行路线推荐', '读书笔记怎么做才不会忘', '空气炸锅食谱'];
    data.discover = ['春季露营装备清单', '旧手机改造成家庭服务器的完整教程', '手冲咖啡入门', '番茄工作法', '低糖早餐做法',
      '周末短途自驾路线', '城市骑行路线推荐', '开源项目贡献指南', '极简桌面布置', '雨天室内运动', '胶片相机入门', '猫咪换粮指南',
      '自制酸奶', '读书笔记怎么做才不会忘', '阳台种菜', '新手钓鱼装备', '高铁出行省钱技巧', '儿童编程启蒙', '城市夜景拍摄参数',
      '居家收纳技巧', '空气炸锅食谱', '第一次跑半程马拉松的训练计划', '设计师常用配色', '徒步登山安全须知']
      .map((title: string): CYLDiscoverTopic => hot.includes(title) ? { title: title, icon: 'hot' } : { title: title });
    return data;
  }

  /** The first selection: the first `discoverCount` topics, so the first screen is always the same. */
  get initialTopics(): CYLDiscoverTopic[] {
    return this.discover.slice(0, Math.max(0, this.discoverCount));
  }

  /** Another random selection of `discoverCount` topics; it differs from `current` whenever the pool allows. */
  randomTopics(current: CYLDiscoverTopic[], random: () => number = Math.random): CYLDiscoverTopic[] {
    const count = Math.min(Math.max(0, this.discoverCount), this.discover.length);
    const titles = current.map((t: CYLDiscoverTopic) => t.title);
    const shuffle = (list: CYLDiscoverTopic[]): CYLDiscoverTopic[] => {
      const copy = list.slice();
      for (let i = copy.length - 1; i > 0; i--) {
        const j = Math.floor(random() * (i + 1));
        const t = copy[i];
        copy[i] = copy[j];
        copy[j] = t;
      }
      return copy;
    };
    // Prefer topics that are not shown now; fill up with the others when the pool is small.
    const picked = shuffle(this.discover.filter((t: CYLDiscoverTopic) => !titles.includes(t.title))).slice(0, count);
    if (picked.length < count) {
      const rest = shuffle(this.discover.filter((t: CYLDiscoverTopic) => !picked.includes(t)));
      rest.slice(0, count - picked.length).forEach((t: CYLDiscoverTopic) => picked.push(t));
    }
    return picked;
  }
}
