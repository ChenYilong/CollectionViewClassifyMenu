/**
 * The SVGA 2.x movie (svga.proto's `MovieEntity`) decoded from a `.svga` file: a zlib stream of a protobuf message.
 * Only what drawing needs is kept: the view box, frame rate and count, the bitmaps (PNG bytes by key) and, per sprite,
 * every frame's alpha, layout, transform, clip path and shapes. SVGA 1.x (a zip of JSON) is not supported.
 */
import { cylInflateZlib } from './CYLInflate';

export class CYLSVGATransform {
  a: number = 1;
  b: number = 0;
  c: number = 0;
  d: number = 1;
  tx: number = 0;
  ty: number = 0;
}

export class CYLSVGARect {
  x: number = 0;
  y: number = 0;
  width: number = 0;
  height: number = 0;
}

/** `ShapeEntity.ShapeType`. */
export enum CYLSVGAShapeType {
  SHAPE = 0,
  RECT = 1,
  ELLIPSE = 2,
  KEEP = 3
}

export class CYLSVGAShape {
  type: CYLSVGAShapeType = CYLSVGAShapeType.SHAPE;
  /** SVG path data, for `SHAPE`. */
  d: string = '';
  /** For `RECT`; for `ELLIPSE`: x, y are the center, width, height the radii. */
  rect: CYLSVGARect = new CYLSVGARect();
  cornerRadius: number = 0;
  /** CSS colors, '' for none. */
  fill: string = '';
  stroke: string = '';
  strokeWidth: number = 0;
  /** 'butt', 'round' or 'square'. */
  lineCap: string = 'butt';
  /** 'miter', 'round' or 'bevel'. */
  lineJoin: string = 'miter';
  miterLimit: number = 0;
  lineDash: number[] = [];
  transform?: CYLSVGATransform;
}

export class CYLSVGAFrame {
  /** 0 hides the sprite in this frame (an empty frame). */
  alpha: number = 0;
  layout: CYLSVGARect = new CYLSVGARect();
  transform?: CYLSVGATransform;
  clipPath: string = '';
  shapes: CYLSVGAShape[] = [];
}

export class CYLSVGASprite {
  imageKey: string = '';
  matteKey: string = '';
  frames: CYLSVGAFrame[] = [];
}

class CYLProtoReader {
  private data: Uint8Array;
  private view: DataView;
  position: number;
  readonly end: number;

  constructor(data: Uint8Array, start: number = 0, end: number = data.length) {
    this.data = data;
    this.view = new DataView(data.buffer, data.byteOffset, data.byteLength);
    this.position = start;
    this.end = end;
  }

  get done(): boolean {
    return this.position >= this.end;
  }

  varint(): number {
    let result = 0;
    let factor = 1;
    for (;;) {
      if (this.position >= this.end) {
        throw new Error('SVGA: truncated protobuf');
      }
      const byte = this.data[this.position++];
      result += (byte & 0x7f) * factor;
      if (byte < 0x80) {
        return result;
      }
      factor *= 128;
    }
  }

  float(): number {
    const value = this.view.getFloat32(this.position, true);
    this.position += 4;
    return value;
  }

  /** A length-delimited field as a reader of its own. */
  message(): CYLProtoReader {
    const length = this.varint();
    const start = this.position;
    this.position += length;
    return new CYLProtoReader(this.data, start, start + length);
  }

  bytes(): Uint8Array {
    const length = this.varint();
    const value = this.data.subarray(this.position, this.position + length);
    this.position += length;
    return value;
  }

  string(): string {
    const bytes = this.bytes();
    let text = '';
    let i = 0;
    while (i < bytes.length) {
      const c = bytes[i++];
      if (c < 0x80) {
        text += String.fromCharCode(c);
      } else if (c < 0xe0) {
        text += String.fromCharCode(((c & 0x1f) << 6) | (bytes[i++] & 0x3f));
      } else if (c < 0xf0) {
        text += String.fromCharCode(((c & 0x0f) << 12) | ((bytes[i++] & 0x3f) << 6) | (bytes[i++] & 0x3f));
      } else {
        const point = ((c & 0x07) << 18) | ((bytes[i++] & 0x3f) << 12) | ((bytes[i++] & 0x3f) << 6) |
          (bytes[i++] & 0x3f);
        text += String.fromCodePoint(point);
      }
    }
    return text;
  }

  skip(wireType: number): void {
    if (wireType === 0) {
      this.varint();
    } else if (wireType === 1) {
      this.position += 8;
    } else if (wireType === 2) {
      this.position += this.varint();
    } else if (wireType === 5) {
      this.position += 4;
    } else {
      throw new Error('SVGA: unsupported protobuf wire type');
    }
  }
}

function readRect(r: CYLProtoReader): CYLSVGARect {
  const rect = new CYLSVGARect();
  while (!r.done) {
    const key = r.varint();
    const field = Math.floor(key / 8);
    const wire = key % 8;
    if (wire !== 5) {
      r.skip(wire);
    } else if (field === 1) {
      rect.x = r.float();
    } else if (field === 2) {
      rect.y = r.float();
    } else if (field === 3) {
      rect.width = r.float();
    } else if (field === 4) {
      rect.height = r.float();
    } else {
      r.skip(wire);
    }
  }
  return rect;
}

function readTransform(r: CYLProtoReader): CYLSVGATransform {
  // proto3: an absent field is 0, so a transform message starts from zeros.
  const t = new CYLSVGATransform();
  t.a = 0;
  t.d = 0;
  while (!r.done) {
    const key = r.varint();
    const field = Math.floor(key / 8);
    const wire = key % 8;
    if (wire !== 5) {
      r.skip(wire);
      continue;
    }
    const value = r.float();
    if (field === 1) {
      t.a = value;
    } else if (field === 2) {
      t.b = value;
    } else if (field === 3) {
      t.c = value;
    } else if (field === 4) {
      t.d = value;
    } else if (field === 5) {
      t.tx = value;
    } else if (field === 6) {
      t.ty = value;
    }
  }
  return t;
}

function readColor(r: CYLProtoReader): string {
  const rgba: number[] = [0, 0, 0, 0];
  while (!r.done) {
    const key = r.varint();
    const field = Math.floor(key / 8);
    const wire = key % 8;
    if (wire === 5 && field >= 1 && field <= 4) {
      rgba[field - 1] = r.float();
    } else {
      r.skip(wire);
    }
  }
  const c = (v: number): number => Math.round(Math.min(1, Math.max(0, v)) * 255);
  return `rgba(${c(rgba[0])},${c(rgba[1])},${c(rgba[2])},${Math.min(1, Math.max(0, rgba[3]))})`;
}

const LINE_CAPS: string[] = ['butt', 'round', 'square'];
const LINE_JOINS: string[] = ['miter', 'round', 'bevel'];

function readStyles(r: CYLProtoReader, shape: CYLSVGAShape): void {
  const dash: number[] = [0, 0, 0];
  while (!r.done) {
    const key = r.varint();
    const field = Math.floor(key / 8);
    const wire = key % 8;
    if (field === 1 && wire === 2) {
      shape.fill = readColor(r.message());
    } else if (field === 2 && wire === 2) {
      shape.stroke = readColor(r.message());
    } else if (field === 3 && wire === 5) {
      shape.strokeWidth = r.float();
    } else if (field === 4 && wire === 0) {
      shape.lineCap = LINE_CAPS[r.varint()] ?? 'butt';
    } else if (field === 5 && wire === 0) {
      shape.lineJoin = LINE_JOINS[r.varint()] ?? 'miter';
    } else if (field === 6 && wire === 5) {
      shape.miterLimit = r.float();
    } else if (field >= 7 && field <= 9 && wire === 5) {
      dash[field - 7] = r.float();
    } else {
      r.skip(wire);
    }
  }
  if (dash[0] > 0 || dash[1] > 0) {
    shape.lineDash = [Math.max(1, dash[0]), dash[1]];
  }
}

function readShape(r: CYLProtoReader): CYLSVGAShape {
  const shape = new CYLSVGAShape();
  while (!r.done) {
    const key = r.varint();
    const field = Math.floor(key / 8);
    const wire = key % 8;
    if (field === 1 && wire === 0) {
      shape.type = r.varint() as CYLSVGAShapeType;
    } else if (field === 2 && wire === 2) {
      const m = r.message();
      while (!m.done) {
        const k = m.varint();
        if (Math.floor(k / 8) === 1 && k % 8 === 2) {
          shape.d = m.string();
        } else {
          m.skip(k % 8);
        }
      }
    } else if (field === 3 && wire === 2) {
      const m = r.message();
      while (!m.done) {
        const k = m.varint();
        const f = Math.floor(k / 8);
        if (k % 8 !== 5) {
          m.skip(k % 8);
          continue;
        }
        const v = m.float();
        if (f === 1) {
          shape.rect.x = v;
        } else if (f === 2) {
          shape.rect.y = v;
        } else if (f === 3) {
          shape.rect.width = v;
        } else if (f === 4) {
          shape.rect.height = v;
        } else if (f === 5) {
          shape.cornerRadius = v;
        }
      }
    } else if (field === 4 && wire === 2) {
      shape.rect = readRect(r.message());
    } else if (field === 10 && wire === 2) {
      readStyles(r.message(), shape);
    } else if (field === 11 && wire === 2) {
      shape.transform = readTransform(r.message());
    } else {
      r.skip(wire);
    }
  }
  return shape;
}

function readFrame(r: CYLProtoReader, previous: CYLSVGAFrame | undefined): CYLSVGAFrame {
  const frame = new CYLSVGAFrame();
  let keep = false;
  while (!r.done) {
    const key = r.varint();
    const field = Math.floor(key / 8);
    const wire = key % 8;
    if (field === 1 && wire === 5) {
      frame.alpha = r.float();
    } else if (field === 2 && wire === 2) {
      frame.layout = readRect(r.message());
    } else if (field === 3 && wire === 2) {
      frame.transform = readTransform(r.message());
    } else if (field === 4 && wire === 2) {
      frame.clipPath = r.string();
    } else if (field === 5 && wire === 2) {
      const shape = readShape(r.message());
      if (shape.type === CYLSVGAShapeType.KEEP) {
        keep = true;
      } else {
        frame.shapes.push(shape);
      }
    } else {
      r.skip(wire);
    }
  }
  if (keep && previous !== undefined) {
    frame.shapes = previous.shapes;
  }
  return frame;
}

function readSprite(r: CYLProtoReader): CYLSVGASprite {
  const sprite = new CYLSVGASprite();
  while (!r.done) {
    const key = r.varint();
    const field = Math.floor(key / 8);
    const wire = key % 8;
    if (field === 1 && wire === 2) {
      sprite.imageKey = r.string();
    } else if (field === 2 && wire === 2) {
      const previous = sprite.frames.length > 0 ? sprite.frames[sprite.frames.length - 1] : undefined;
      sprite.frames.push(readFrame(r.message(), previous));
    } else if (field === 3 && wire === 2) {
      sprite.matteKey = r.string();
    } else {
      r.skip(wire);
    }
  }
  return sprite;
}

export class CYLSVGAMovie {
  version: string = '';
  viewBoxWidth: number = 0;
  viewBoxHeight: number = 0;
  fps: number = 20;
  frames: number = 0;
  /** PNG (or other encoded image) bytes by image key. */
  images: Map<string, Uint8Array> = new Map<string, Uint8Array>();
  sprites: CYLSVGASprite[] = [];

  /** One pass at speed 1, in milliseconds. */
  get durationMs(): number {
    return this.fps > 0 ? this.frames * 1000 / this.fps : 0;
  }

  /** The frame shown at `progress` (0...1): 1 is the last frame. */
  frameIndex(progress: number): number {
    if (this.frames <= 0) {
      return -1;
    }
    return Math.min(this.frames - 1, Math.max(0, Math.floor(progress * this.frames)));
  }

  /**
   * Decodes a `.svga` file (SVGA 2.x). Throws for SVGA 1.x (a zip) or a damaged file.
   */
  static decode(file: Uint8Array): CYLSVGAMovie {
    if (file.length >= 2 && file[0] === 0x50 && file[1] === 0x4b) {
      throw new Error('SVGA: version 1.x files (zip) are not supported');
    }
    const r = new CYLProtoReader(cylInflateZlib(file));
    const movie = new CYLSVGAMovie();
    while (!r.done) {
      const key = r.varint();
      const field = Math.floor(key / 8);
      const wire = key % 8;
      if (field === 1 && wire === 2) {
        movie.version = r.string();
      } else if (field === 2 && wire === 2) {
        const p = r.message();
        while (!p.done) {
          const k = p.varint();
          const f = Math.floor(k / 8);
          const w = k % 8;
          if (f === 1 && w === 5) {
            movie.viewBoxWidth = p.float();
          } else if (f === 2 && w === 5) {
            movie.viewBoxHeight = p.float();
          } else if (f === 3 && w === 0) {
            movie.fps = p.varint();
          } else if (f === 4 && w === 0) {
            movie.frames = p.varint();
          } else {
            p.skip(w);
          }
        }
      } else if (field === 3 && wire === 2) {
        const entry = r.message();
        let name = '';
        let bytes = new Uint8Array(0);
        while (!entry.done) {
          const k = entry.varint();
          if (k === 10) {
            name = entry.string();
          } else if (k === 18) {
            bytes = entry.bytes();
          } else {
            entry.skip(k % 8);
          }
        }
        movie.images.set(name, bytes);
      } else if (field === 4 && wire === 2) {
        movie.sprites.push(readSprite(r.message()));
      } else {
        r.skip(wire);
      }
    }
    return movie;
  }
}
