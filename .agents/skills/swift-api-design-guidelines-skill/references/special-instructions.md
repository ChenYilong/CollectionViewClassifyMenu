# Special Instructions

## Tuple And Closure Naming
- Label tuple members in API signatures.
- Name closure parameters where they appear in the API.
- These names improve call-site readability and documentation usefulness.

```swift
mutating func ensureUniqueStorage(
    minimumCapacity requestedCapacity: Int,
    allocate: (_ byteCount: Int) -> UnsafePointer<Void>
) -> (reallocated: Bool, capacityChanged: Bool)
```

## Be Careful With Unconstrained Polymorphism
- `Any`, `AnyObject`, and unconstrained generics can make overload sets ambiguous.
- Semantic overload families still need explicit naming when weak typing collapses distinctions.

Ambiguous pattern:
```swift
values.append([2, 3, 4]) // element append or sequence append?
```

Preferred disambiguation:
```swift
append(_ newElement: Element)
append(contentsOf newElements: S)
```

## Practical Rule
- If overload meaning is not obvious at the call site for weakly typed values, rename APIs to make intent explicit.
