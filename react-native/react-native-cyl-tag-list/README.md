# react-native-cyl-tag-list

CollectionViewClassifyMenu's CYLTagListView as a React Native Fabric view

## Installation


```sh
npm install react-native-cyl-tag-list
```


## Usage


```js
import { CylTagListView } from "react-native-cyl-tag-list";

// ...

<CylTagListView color="#32a852" />
```


## Contributing

- [Development workflow](CONTRIBUTING.md#development-workflow)
- [Sending a pull request](CONTRIBUTING.md#sending-a-pull-request)
- [Code of conduct](CODE_OF_CONDUCT.md)

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)

## Long press, subtitles, folding and title lines

The configuration is the native list's configuration, so these keys work on iOS, Android and HarmonyOS (typed as
`CylTagListConfiguration`):

```tsx
<CylTagListView
  configuration={{
    longPressAction: CylTagLongPressActionName.callout, // a small callout with an arrow showing the item's subtitle
    defaultVisibleRows: 2, // a section with more rows folds behind More / Less; one with fewer shows no control
    foldControl: 'headerTrailing',
    style: { titleMaxLines: 3 }, // or CylTagTitleMaxLinesUnlimited; itemsPerRow left out: tags are content-wide
    sections: [{ title: 'Flows', items: [{ title: 'Switch states', subtitle: 'reloadData #3' }] }],
  }}
  onTagTap={(tag) => {}}
  onTagLongPress={(tag) => {}} // the `report` action (part of the default) and `handler` actions
/>
```
