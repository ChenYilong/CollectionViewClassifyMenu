import { describe, it, expect } from '@ohos/hypium';
import {
  CYLAnimatedItemPlaybackHost, CYLAnimatedItemPlayer, CYLAnimationEngine, CYLAnimationSource, cylTagItemBuilderURL,
  CYLImageTagDirection, CYLImageTagDirections, CYLImageTagGeometry, CYLImageTagGroup,
  CYLImageTagMetrics, CYLImageTagPlacement, CYLPoint, CYLRect, CYLSize, CYLTagListState
} from '@cyl/classifymenu';
import { CYLSVGAPlayer } from '../main/ets/animation/CYLExampleAnimationPlayers';
import { CYLSVGAMovie } from '../main/ets/animation/svga/CYLSVGAMovie';

function movie(frames: number, fps: number): CYLSVGAMovie {
  const m = new CYLSVGAMovie();
  m.viewBoxWidth = 96;
  m.viewBoxHeight = 96;
  m.frames = frames;
  m.fps = fps;
  return m;
}

/**
 * The image tag geometry (TagViewGroup's TagGroupUtils), the timed animation player behind SVGA (and GIF, PAG), and
 * the JSON configuration of CYLTagListState.
 */
export default function imageTagAndPlayerTest() {
  describe('CYLImageTagGeometry', () => {
    it('turnsThroughTheTenLineDirections', 0, () => {
      let d = CYLImageTagDirection.leftCenter;
      const seen = new Set<number>();
      for (let i = 0; i < 10; i++) {
        seen.add(d as number);
        d = CYLImageTagDirections.next(d);
      }
      expect(seen.size).assertEqual(10);
      expect(d).assertEqual(CYLImageTagDirection.leftCenter);
      expect(CYLImageTagDirections.next(CYLImageTagDirection.center)).assertEqual(CYLImageTagDirection.leftCenter);
    });

    it('givesNewTagsTheSamplesDirections', 0, () => {
      expect(CYLImageTagGroup.defaultDirections(0).length).assertEqual(0);
      expect(CYLImageTagGroup.defaultDirections(1)[0]).assertEqual(CYLImageTagDirection.rightCenter);
      expect(CYLImageTagGroup.defaultDirections(9).length).assertEqual(6);
    });

    it('keepsTheGroupInsideThePicture', 0, () => {
      const metrics = new CYLImageTagMetrics();
      const directions = [CYLImageTagDirection.rightTop, CYLImageTagDirection.rightBottom];
      const sizes = [new CYLSize(80, 24), new CYLSize(60, 24)];
      // The dot at the right edge: the group moves left so the tags stay inside 300 × 300.
      const result = CYLImageTagGeometry.layout(metrics, 300, 300, new CYLPoint(0.98, 0.5), new CYLPoint(0, 0),
        directions, sizes);
      expect(result.placements.length).assertEqual(2);
      result.placements.forEach((p: CYLImageTagPlacement) => {
        expect(p.frame.x >= 0).assertTrue();
        expect(p.frame.maxX <= 300 + 0.5).assertTrue();
        expect(p.line.length).assertEqual(3);
      });
      expect(result.centerPoint.x < 300 * 0.98).assertTrue();
    });

    it('drawsPartOfALine', 0, () => {
      const line = [new CYLPoint(0, 0), new CYLPoint(10, 0), new CYLPoint(10, 10)];
      const half = CYLImageTagGeometry.partialLine(line, 0.5);
      expect(half.length).assertEqual(2);
      expect(half[1].x).assertEqual(10);
      const quarter = CYLImageTagGeometry.partialLine(line, 0.25);
      expect(quarter[1].x).assertEqual(5);
      expect(CYLImageTagGeometry.partialLine(line, 1).length).assertEqual(3);
    });

    it('separatesOverlappingGroups', 0, () => {
      const placed = [new CYLRect(0, 100, 100, 40)];
      const dy = CYLImageTagGeometry.separationOffset(new CYLRect(0, 110, 100, 40), placed, 400, 4);
      expect(dy !== 0).assertTrue();
      expect(CYLImageTagGeometry.separationOffset(new CYLRect(0, 300, 100, 40), placed, 400, 4)).assertEqual(0);
    });

    it('joinsTitlesInTheLanguage', 0, () => {
      expect(CYLImageTagGeometry.joinTitles(['鞋', '包', '衣服'], 'zh-Hans')).assertEqual('鞋、包和衣服');
      expect(CYLImageTagGeometry.joinTitles(['a', 'b'], 'en')).assertEqual('a and b');
      expect(CYLImageTagGeometry.joinTitles([], 'en')).assertEqual('');
    });
  });

  describe('CYLSVGAPlayer', () => {
    it('restsOnAProgressAndTheLastFrame', 0, () => {
      const frames: number[] = [];
      const player = new CYLSVGAPlayer(CYLAnimationSource.parse('asset:svga/tab_home.svga'), movie(30, 30));
      player.onFrame = (i: number) => frames.push(i);
      expect(player.supportsSpeed && player.supportsLoops && player.supportsProgress).assertTrue();
      player.stopAtProgress(1);
      expect(player.frameIndex).assertEqual(29);
      player.stopAtProgress(0.5);
      expect(player.frameIndex).assertEqual(15);
      player.stopAtProgress(-3);
      expect(player.progress).assertEqual(0);
      expect(frames.join(',')).assertEqual('29,15,0');
      expect(player.isPlaying).assertFalse();
    });

    it('playsFromZeroWithItsSpeedAndLoop', 0, () => {
      const player = new CYLSVGAPlayer(CYLAnimationSource.parse('asset:a.svga'), movie(20, 20));
      player.speed = 2;
      player.loops = true;
      player.stopAtProgress(0.7);
      player.play();
      expect(player.progress).assertEqual(0);
      expect(player.isPlaying).assertTrue();
      expect(player.speed).assertEqual(2);
      player.speed = -1;
      expect(player.speed).assertEqual(1);
      player.destroy();
      expect(player.isPlaying).assertFalse();
    });
  });

  describe('CYLAnimatedItemPlayer', () => {
    it('drivesARiveBuilderThroughTheComponentsProps', 0, () => {
      const calls: string[] = [];
      const host: CYLAnimatedItemPlaybackHost = {
        restart: () => { calls.push('restart'); },
        setLoops: (loops: boolean) => { calls.push(`loops:${loops}`); }
      };
      const source = CYLAnimationSource.parse('asset:rive/house.riv#stateMachine=State%20Machine%201');
      const player = new CYLAnimatedItemPlayer(CYLAnimationEngine.RIVE, source, host);
      expect(player.supportsLoops).assertTrue();
      expect(player.supportsSpeed).assertFalse();
      expect(player.supportsProgress).assertFalse();
      player.loops = true;
      player.play();
      expect(player.isPlaying).assertTrue();
      player.stopAtProgress(1);
      expect(player.isPlaying).assertFalse();
      player.loops = false;
      expect(calls.join(',')).assertEqual('loops:true,restart,loops:false');
    });

    it('givesTheBuilderARawfilePathWithItsOptions', 0, () => {
      const source = CYLAnimationSource.parse('asset:Rive/house.riv#stateMachine=State%20Machine%201');
      expect(cylTagItemBuilderURL(source, 'house.riv')).assertEqual('house.riv#stateMachine=State%20Machine%201');
      expect(cylTagItemBuilderURL(CYLAnimationSource.parse('asset:rive/truck.riv'), 'rive/truck.riv'))
        .assertEqual('rive/truck.riv');
    });
  });

  describe('CYLTagListConfiguration', () => {
    it('buildsAListFromJSON', 0, () => {
      const json = '{"selectionMode":"multiple","selectedItems":["0-1"],"sections":[{"title":"A","items":' +
        '[{"title":"x"},{"title":"y"},"z"]},{"title":"B","items":["p"]}]}';
      const list = CYLTagListState.withConfiguration(JSON.parse(json) as Record<string, Object>);
      expect(list.numberOfSections()).assertEqual(2);
      expect(list.numberOfDisplayedItems(0) >= 3).assertTrue();
      expect(list.titleForItem({ section: 0, item: 2 })).assertEqual('z');
      expect(list.isSelected({ section: 0, item: 1 })).assertTrue();
      expect(list.selectedTitles.join(',')).assertEqual('y');
    });
  });
}
