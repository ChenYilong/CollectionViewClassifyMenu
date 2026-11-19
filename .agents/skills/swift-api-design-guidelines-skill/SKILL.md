---
name: swift-api-design-guidelines-skill
description: Write, review, or improve Swift APIs using Swift API Design Guidelines for naming, argument labels, documentation comments, terminology, and general conventions. Use when designing new APIs, refactoring existing interfaces, or reviewing API clarity and fluency.
---

# Swift API Design Guidelines Skill

## Overview
Use this skill to design and review Swift APIs that are clear at the point of use, fluent in call sites, and aligned with established Swift naming and labeling conventions. Prioritize readability, explicit intent, and consistency across declarations, call sites, and documentation comments.

## Work Decision Tree

### 1) Review existing code
- Inspect declarations and call sites together, not declarations alone.
- Check naming clarity and fluency (see `references/promote-clear-usage.md`, `references/strive-for-fluent-usage.md`).
- Check argument labels and parameter naming (see `references/parameters.md`, `references/argument-labels.md`).
- Check documentation comments and symbol markup (see `references/fundamentals.md`).
- Check conventions and overload safety (see `references/general-conventions.md`, `references/special-instructions.md`).

### 2) Improve existing code
- Rename APIs that are ambiguous, redundant, or role-unclear.
- Refactor labels to improve grammatical call-site reading.
- Replace weakly named parameters with role-based names.
- Resolve overload sets that become ambiguous with weak typing.
- Strengthen documentation summaries to describe behavior and returns precisely.

### 3) Implement new feature
- Start from use-site examples before finalizing declarations.
- Choose base names and labels so calls read as clear English phrases.
- Add defaults only when they simplify common usage.
- Define mutating/nonmutating pairs with consistent naming.
- Add concise documentation comments for every new declaration.

## Core Guidelines

### Fundamentals
- Clarity at the point of use is the top priority.
- Clarity is more important than brevity.
- Every declaration should have a documentation comment.
- Summaries should state what the declaration does, returns, accesses, creates, or is.
- Use recognized Swift symbol markup (`Parameter`, `Returns`, `Throws`, `Note`, etc.).

### Promote Clear Usage
- Include all words needed to avoid ambiguity.
- Omit needless words, especially type repetition.
- Name parameters and associated types by role, not type.
- Add role nouns when type information is weak (`Any`, `NSObject`, `String`, `Int`).

### Strive For Fluent Usage
- Prefer method names that produce grammatical, readable call sites.
- Start factory methods with `make`.
- Name side-effect-free APIs as noun phrases; side-effecting APIs as imperative verbs.
- Keep mutating/nonmutating naming pairs consistent (`sort`/`sorted`, `formUnion`/`union`).
- Boolean APIs should read as assertions (`isEmpty`, `intersects`).

### Use Terminology Well
- Prefer common words unless terms of art are necessary for precision.
- If using a term of art, preserve its established meaning.
- Avoid non-standard abbreviations.
- Embrace established domain precedent when it improves shared understanding.

### Conventions, Parameters, And Labels
- Document complexity for computed properties that are not `O(1)`.
- Prefer methods/properties to free functions except special cases.
- Follow Swift casing conventions, including acronym handling.
- Use parameter names that improve generated documentation readability.
- Prefer default arguments over method families when semantics are shared.
- Place defaulted parameters near the end.
- Apply argument labels based on grammar and meaning, not style preference.

### Special Instructions
- Label tuple members and name closure parameters in public API surfaces.
- Be explicit with unconstrained polymorphism to avoid overload ambiguity.
- Align names with semantics shown in documentation comments.

## Quick Reference

### Name Shape
| Situation | Preferred Pattern |
| --- | --- |
| Mutating verb | `reverse()` |
| Nonmutating verb | `reversed()` / `strippingNewlines()` |
| Nonmutating noun op | `union(_:)` |
| Mutating noun op | `formUnion(_:)` |
| Factory method | `makeWidget(...)` |
| Boolean query | `isEmpty`, `intersects(_:)` |

### Argument Label Rules
| Situation | Rule |
| --- | --- |
| Distinguishable unlabeled args | Omit labels only if distinction is still clear |
| Value-preserving conversion init | Omit first label |
| First arg in prepositional phrase | Usually label from the preposition |
| First arg in grammatical phrase | Omit first label |
| Defaulted arguments | Keep labels (they may be omitted at call sites) |
| All other arguments | Label them |

### Documentation Rules
| Declaration Kind | Summary Should Describe |
| --- | --- |
| Function / method | What it does and what it returns |
| Subscript | What it accesses |
| Initializer | What it creates |
| Other declarations | What it is |

## Review Checklist

### Clarity And Fluency
- [ ] Call sites are clear without reading implementation details.
- [ ] Base names include all words needed to remove ambiguity.
- [ ] Names are concise and avoid repeating type names.
- [ ] Calls read naturally and grammatically where it matters most.

### Naming Semantics
- [ ] Side-effect-free APIs read as nouns/queries.
- [ ] Side-effecting APIs read as imperative verbs.
- [ ] Mutating/nonmutating pairs use consistent naming patterns.
- [ ] Boolean APIs read as assertions.

### Parameters And Labels
- [ ] Parameter names improve docs and role clarity.
- [ ] Default parameters simplify common usage.
- [ ] Defaulted parameters are near the end.
- [ ] First argument labels follow grammar and conversion rules.
- [ ] Remaining arguments are labeled unless omission is clearly justified.

### Documentation And Conventions
- [ ] Every declaration has a useful summary comment.
- [ ] Symbol markup is used where appropriate.
- [ ] Non-`O(1)` computed property complexity is documented.
- [ ] Case conventions and acronym casing follow Swift norms.
- [ ] Overloads avoid return-type-only distinctions and weak-type ambiguities.

## References
- `references/fundamentals.md` - Core principles and documentation comment rules
- `references/promote-clear-usage.md` - Ambiguity reduction and role-based naming
- `references/strive-for-fluent-usage.md` - Fluency, side effects, and mutating pairs
- `references/use-terminology-well.md` - Terms of art, abbreviations, and precedent
- `references/general-conventions.md` - Complexity docs, free function exceptions, casing, overloads
- `references/parameters.md` - Parameter naming and default argument strategy
- `references/argument-labels.md` - First-argument and general label rules
- `references/special-instructions.md` - Tuple/closure naming and unconstrained polymorphism

## Philosophy
- Prefer clear use-site semantics over declaration cleverness.
- Follow established Swift conventions before inventing local style rules.
- Optimize for maintainability and reviewability of public API surfaces.
- Keep guidance practical: apply the smallest change that improves clarity.
