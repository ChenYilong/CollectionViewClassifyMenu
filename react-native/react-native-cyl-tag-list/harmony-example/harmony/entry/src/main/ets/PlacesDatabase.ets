/*
 * PlacesDatabase.ets
 * Puts the shared database (cyl_places.sqlite, docs/cross-platform.md) where op-sqlite opens it, once: the
 * OpenHarmony port's moveAssetsDatabase copies databaseDir onto itself, so the app copies the rawfile itself.
 */
import { fileIo as fs } from '@kit.CoreFileKit';

export function installPlacesDatabase(context: Context): void {
  const name = 'cyl_places.sqlite';
  const target = `${context.databaseDir}/${name}`;
  if (fs.accessSync(target)) {
    return;
  }
  const bytes = context.resourceManager.getRawFileContentSync(name);
  const file = fs.openSync(target, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
  fs.writeSync(file.fd, bytes.buffer);
  fs.closeSync(file);
}
