# Promote Clear Usage

## Include Words Needed For Clarity
- Keep all words required to avoid ambiguity at the call site.
- Do not remove words that carry semantic distinction.

```swift
employees.remove(at: index)   // clear position-based removal
employees.remove(index)       // ambiguous
```

## Omit Needless Words
- Remove words that repeat type information and add no meaning.
- Prefer role-focused words over type-focused words.

```swift
allViews.remove(cancelButton)         // preferred
allViews.removeElement(cancelButton)  // redundant
```

## Name By Role, Not Type
- Variables, parameters, and associated types should describe role.
- Avoid reusing type names as identifiers when a role name is better.

```swift
var greeting = "Hello"
func restock(from supplier: WidgetFactory)
associatedtype ContentView: View
```

## Compensate For Weak Type Information
- Weakly typed values (`Any`, `NSObject`, primitives) often need extra role words.
- Add role nouns to disambiguate intent.

```swift
func addObserver(_ observer: NSObject, forKeyPath path: String)
```

## Review Heuristic
- Ask: "Can a reader infer semantics from call-site text alone?"
- If not, add the smallest amount of naming context needed.
