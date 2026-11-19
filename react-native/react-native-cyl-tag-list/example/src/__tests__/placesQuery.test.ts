import { describe, expect, it, jest } from '@jest/globals';

jest.mock('@op-engineering/op-sqlite', () => ({ moveAssetsDatabase: jest.fn(), open: jest.fn() }));

import { placesQuery } from '../PlacesDatabase';

/**
 * The statement must be the iOS example's (CYLMenuLinkageViewController.query(forTag:regions:dishes:)), so that every
 * platform lists the same places for the same conditions (docs/cross-platform.md).
 */
describe('placesQuery', () => {
  const select = 'SELECT name, region, rating, price FROM places';
  const order = ' ORDER BY rating DESC, id';

  it('lists every place when nothing is selected', () => {
    expect(placesQuery(null, [], [])).toEqual({ sql: select + order, args: [] });
  });

  it('ANDs the tag with the regions and the dishes, with bound values', () => {
    expect(placesQuery('川菜', ['广州', "it's"], ['川菜', '火锅'])).toEqual({
      sql: `${select} WHERE tag = ? AND region IN (?, ?) AND tag IN (?, ?)${order}`,
      args: ['川菜', '广州', "it's", '川菜', '火锅'],
    });
  });

  it('leaves out empty conditions', () => {
    expect(placesQuery(null, ['上海'], []).sql).toBe(`${select} WHERE region IN (?)${order}`);
  });
});
