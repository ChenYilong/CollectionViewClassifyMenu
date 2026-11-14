# General Conventions

## Document Computed Property Complexity
- If a computed property is not `O(1)`, document its complexity.
- Many readers assume property access is cheap unless told otherwise.

## Prefer Methods/Properties To Free Functions
Use free functions only when:
1. There is no obvious `self`.
2. The function is an unconstrained generic.
3. Function syntax is established domain notation.

## Follow Swift Casing
- Types/protocols: `UpperCamelCase`.
- Other declarations: `lowerCamelCase`.
- Acronyms and initialisms should be cased consistently with style conventions.

```swift
var utf8Bytes: [UTF8.CodeUnit]
var isRepresentableAsASCII = true
var radarDetector: RadarScanner
```

## Overloads
- Methods may share base names when meaning is the same or domains are distinct.
- Do not reuse a base name for semantically different operations.
- Avoid overloading on return type alone; type inference can make calls ambiguous.

## Review Heuristic
- Check that overload sets are readable, semantically coherent, and unambiguous at call sites.
