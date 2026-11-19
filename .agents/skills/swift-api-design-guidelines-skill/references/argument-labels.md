# Argument Labels

## Omit Labels Only When It Is Still Clear
- Omit all labels only when unlabeled arguments cannot be usefully distinguished.

Examples:
- `min(x, y)`
- `zip(a, b)`

## Value-Preserving Conversion Initializers
- Omit the first argument label for value-preserving conversions.
- The first argument should be the conversion source.

```swift
let value = Int64(someUInt32)
```

## Prepositional Phrase Rule
- If the first argument is part of a prepositional phrase, usually include the label beginning with the preposition.

```swift
x.removeBoxes(havingLength: 12)
```

Exception:
- When first arguments are parts of one abstraction, move the label boundary after the preposition.

```swift
a.moveTo(x: b, y: c)
a.fadeFrom(red: b, green: c, blue: d)
```

## Grammatical Phrase Rule
- If the first argument forms part of a grammatical phrase, omit its label and move leading words into the base name.

```swift
x.addSubview(y)
```

## Label Everything Else
- If the first argument is not part of a grammatical phrase, label it.
- Label all remaining arguments unless a specific rule justifies omission.

```swift
view.dismiss(animated: false)
words.split(maxSplits: 12)
students.sorted(isOrderedBefore: Student.namePrecedes)
```
