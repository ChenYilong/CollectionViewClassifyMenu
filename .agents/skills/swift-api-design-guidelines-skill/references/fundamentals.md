# Fundamentals

## Core Priorities
- Clarity at the point of use is the most important design goal.
- Clarity is more important than brevity.
- Evaluate declarations in real call-site context, not in isolation.

## Documentation Is Part Of API Design
- Write a documentation comment for every declaration.
- If the API is hard to describe simply, redesign may be needed.
- Use Swift Markdown and recognized symbol markup.

## Summary Writing Rules
- Start with a summary that can stand on its own.
- Prefer a single sentence fragment ending in a period.
- Describe:
  - Functions/methods: what they do and return.
  - Subscripts: what they access.
  - Initializers: what they create.
  - Other declarations: what they are.

## Suggested Structure
```swift
/// Returns a "view" of `self` containing the same elements in
/// reverse order.
func reversed() -> ReverseCollection
```

```swift
/// Accesses the `index`th element.
subscript(index: Int) -> Element { get set }
```

```swift
/// Creates an instance containing `n` repetitions of `x`.
init(count n: Int, repeatedElement x: Element)
```

## Additional Comment Content
- Add extra paragraphs only when they improve comprehension.
- Use symbol markup bullets when relevant, such as:
  - `Parameter` / `Parameters`
  - `Returns`
  - `Throws`
  - `Note`
  - `Warning`
  - `SeeAlso`

## Practical Check
- Read a use-site snippet and confirm the intent is obvious without external explanation.
