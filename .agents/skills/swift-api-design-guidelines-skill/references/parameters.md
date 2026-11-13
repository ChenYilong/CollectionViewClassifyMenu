# Parameters

## Choose Names For Documentation Quality
- Parameter names do not appear at most call sites, but they drive documentation clarity.
- Select names that read naturally in summaries and parameter descriptions.

```swift
/// Returns the elements of `self` that satisfy `predicate`.
func filter(_ predicate: (Element) -> Bool) -> [Element]
```

## Prefer Defaults For Common Cases
- Use default values when one value is commonly used.
- Defaults reduce noise in common call sites and improve readability.

```swift
lastName.compare(royalFamilyName)
```

## Prefer A Single API With Defaults Over Method Families
- Multiple overloads with mostly shared semantics increase cognitive load.
- One method with defaults is usually easier to learn and maintain.

## Place Defaulted Parameters Near The End
- Non-defaulted parameters typically carry core semantics.
- Keep the call pattern stable and predictable.

## `#fileID`, `#filePath`, `#file`
- Prefer `#fileID` for production APIs to save space and avoid exposing full paths.
- Use `#filePath` where full paths are intentionally useful (e.g., tests/tools).
- Use `#file` for Swift 5.2-and-earlier compatibility needs.
