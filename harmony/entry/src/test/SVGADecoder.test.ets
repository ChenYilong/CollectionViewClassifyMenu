import { describe, it, expect } from '@ohos/hypium';
import { CYLAnimationEngine, cylAnimationEngine } from '@cyl/classifymenu';
import { CYLSVGAMovie, CYLSVGAShapeType } from '../main/ets/animation/svga/CYLSVGAMovie';

/** Protobuf writer for the test movies: varints, fixed32 floats and length-delimited fields. */
class ProtoWriter {
  bytes: number[] = [];

  varint(value: number): ProtoWriter {
    let v = value;
    while (v >= 0x80) {
      this.bytes.push((v % 0x80) | 0x80);
      v = Math.floor(v / 0x80);
    }
    this.bytes.push(v);
    return this;
  }

  key(field: number, wire: number): ProtoWriter {
    return this.varint(field * 8 + wire);
  }

  float(field: number, value: number): ProtoWriter {
    const view = new DataView(new ArrayBuffer(4));
    view.setFloat32(0, value, true);
    this.key(field, 5);
    for (let i = 0; i < 4; i++) {
      this.bytes.push(view.getUint8(i));
    }
    return this;
  }

  int(field: number, value: number): ProtoWriter {
    return this.key(field, 0).varint(value);
  }

  data(field: number, value: number[]): ProtoWriter {
    this.key(field, 2).varint(value.length);
    value.forEach((b: number) => this.bytes.push(b));
    return this;
  }

  text(field: number, value: string): ProtoWriter {
    const codes: number[] = [];
    for (let i = 0; i < value.length; i++) {
      codes.push(value.charCodeAt(i));
    }
    return this.data(field, codes);
  }

  message(field: number, m: ProtoWriter): ProtoWriter {
    return this.data(field, m.bytes);
  }
}

/** A zlib stream of `payload` in one stored (uncompressed) deflate block; the checksum is not read. */
function zlibStored(payload: number[]): Uint8Array {
  const header: number[] = [0x78, 0x01, 0x01, payload.length & 0xff, payload.length >> 8,
    (~payload.length) & 0xff, ((~payload.length) >> 8) & 0xff];
  return new Uint8Array(header.concat(payload).concat([0, 0, 0, 0]));
}

function testMovie(): Uint8Array {
  const params = new ProtoWriter().float(1, 96).float(2, 48).int(3, 20).int(4, 4);
  const image = new ProtoWriter().text(1, 'img_0').data(2, [0x89, 0x50, 0x4e, 0x47]);
  const layout = new ProtoWriter().float(1, 2).float(2, 3).float(3, 40).float(4, 20);
  const transform = new ProtoWriter().float(1, 1).float(4, 1).float(5, 10).float(6, 5);
  const visible = new ProtoWriter().float(1, 0.5).message(2, layout).message(3, transform).text(4, 'M0 0 L10 10 Z');
  const rect = new ProtoWriter().float(3, 8).float(4, 6).float(5, 2);
  const fill = new ProtoWriter().float(1, 1).float(4, 1);
  const styles = new ProtoWriter().message(1, fill).float(3, 2).int(4, 1);
  const shape = new ProtoWriter().int(1, CYLSVGAShapeType.RECT).message(3, rect).message(10, styles);
  const shaped = new ProtoWriter().float(1, 1).message(5, shape);
  const keep = new ProtoWriter().float(1, 1).message(5, new ProtoWriter().int(1, CYLSVGAShapeType.KEEP));
  const sprite = new ProtoWriter().text(1, 'img_0')
    .message(2, new ProtoWriter())
    .message(2, visible)
    .message(2, shaped)
    .message(2, keep);
  const movie = new ProtoWriter().text(1, '2.0.0').message(2, params).message(3, image).message(4, sprite);
  return zlibStored(movie.bytes);
}

export default function svgaDecoderTest() {
  describe('CYLSVGAMovie', () => {
    it('picksTheSVGAEngineByExtension', 0, () => {
      expect(cylAnimationEngine('asset:svga/tab_home.svga')).assertEqual(CYLAnimationEngine.SVGA);
      expect(cylAnimationEngine('asset:svga/TAB.SVGA#loop=1')).assertEqual(CYLAnimationEngine.SVGA);
      expect(cylAnimationEngine('asset:rive/house.riv')).assertEqual(CYLAnimationEngine.RIVE);
    });

    it('decodesParamsImagesAndSprites', 0, () => {
      const movie = CYLSVGAMovie.decode(testMovie());
      expect(movie.version).assertEqual('2.0.0');
      expect(movie.viewBoxWidth).assertEqual(96);
      expect(movie.viewBoxHeight).assertEqual(48);
      expect(movie.fps).assertEqual(20);
      expect(movie.frames).assertEqual(4);
      expect(movie.durationMs).assertEqual(200);
      expect(movie.images.get('img_0')?.length).assertEqual(4);
      expect(movie.sprites.length).assertEqual(1);
      expect(movie.sprites[0].imageKey).assertEqual('img_0');
      expect(movie.sprites[0].frames.length).assertEqual(4);
    });

    it('decodesFramesAsSVGAPlayerDraws', 0, () => {
      const frames = CYLSVGAMovie.decode(testMovie()).sprites[0].frames;
      // An empty frame hides the sprite (proto3: alpha 0).
      expect(frames[0].alpha).assertEqual(0);
      expect(frames[1].alpha).assertEqual(0.5);
      expect(frames[1].layout.x).assertEqual(2);
      expect(frames[1].layout.width).assertEqual(40);
      expect(frames[1].transform?.tx).assertEqual(10);
      expect(frames[1].transform?.b).assertEqual(0);
      expect(frames[1].clipPath).assertEqual('M0 0 L10 10 Z');
      expect(frames[2].shapes.length).assertEqual(1);
      expect(frames[2].shapes[0].type).assertEqual(CYLSVGAShapeType.RECT);
      expect(frames[2].shapes[0].rect.width).assertEqual(8);
      expect(frames[2].shapes[0].cornerRadius).assertEqual(2);
      expect(frames[2].shapes[0].fill).assertEqual('rgba(255,0,0,1)');
      expect(frames[2].shapes[0].strokeWidth).assertEqual(2);
      expect(frames[2].shapes[0].lineCap).assertEqual('round');
      // KEEP reuses the previous frame's shapes.
      expect(frames[3].shapes.length).assertEqual(1);
    });

    it('mapsProgressToFrames', 0, () => {
      const movie = CYLSVGAMovie.decode(testMovie());
      expect(movie.frameIndex(0)).assertEqual(0);
      expect(movie.frameIndex(0.5)).assertEqual(2);
      expect(movie.frameIndex(1)).assertEqual(3);
    });

    it('rejectsSVGA1AndDamagedFiles', 0, () => {
      let zip = '';
      try {
        CYLSVGAMovie.decode(new Uint8Array([0x50, 0x4b, 3, 4]));
      } catch (e) {
        zip = `${e}`;
      }
      expect(zip.includes('1.x')).assertTrue();
      let damaged = '';
      try {
        CYLSVGAMovie.decode(new Uint8Array([1, 2, 3]));
      } catch (e) {
        damaged = `${e}`;
      }
      expect(damaged.includes('zlib')).assertTrue();
    });
  });
}
