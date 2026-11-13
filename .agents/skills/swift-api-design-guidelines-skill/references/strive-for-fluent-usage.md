# Strive For Fluent Usage

## Build Grammatical Call Sites
- Prefer names that form readable phrases at use sites.
- Fluency matters most for the base name and first arguments.

```swift
x.insert(y, at: z)
x.subviews(havingColor: color)
```

## Factory And Initializer Naming
- Start factory methods with `make`.
- Do not force the first argument into a phrase with the base name.

```swift
factory.makeWidget(gears: 42, spindles: 14)
let link = Link(to: destination)
```

## Name By Side Effects
- No side effects: noun/query style (`distance(to:)`, `isEmpty`).
- With side effects: imperative verb style (`sort()`, `append(_)`, `print(_)`).

## Mutating/Nonmutating Pairs
- If naturally a verb:
  - Mutating: imperative (`sort`, `append`)
  - Nonmutating: participle (`sorted`, `appending`/`stripping...`)
- If naturally a noun:
  - Nonmutating noun (`union`)
  - Mutating `form` prefix (`formUnion`)

## Protocol And Type Naming
- Protocols describing what something is should be nouns (`Collection`).
- Capability protocols should end in `able`, `ible`, or `ing` (`Equatable`, `ProgressReporting`).
- Types, properties, constants, and variables should read as nouns.
