---
name: cyl-swift
description: Swift examples and Swift-friendly Objective-C APIs in the CollectionViewClassifyMenu core (NS_SWIFT_NAME, nullability, cyl_ methods).
---

# Swift examples, Swift-friendly core

Rules in `AGENTS.md` ("Swift examples and a Swift-friendly core"). This skill is the how-to.

## Examples

- New examples and new screens are Swift (`Example-Swift/` is the model: local pod
  `pod 'CollectionViewClassifyMenu', :path => '..'`, `use_frameworks!`, `import CollectionViewClassifyMenu`,
  strings through its own bundle and lookup helper, tests in Swift).
- The Objective-C examples still to port: `Example/CYLMenuExample` (scenarios 1 and 2, styles, animations,
  plus button, database demos), the demo app of `CollectionViewClassifyMenu.xcodeproj` (`CYLMainViewController`,
  `CYLDemoDataSource`, `CYLDBManager`) and `TagCollectionView`. Port the part a change touches, keep its
  screenshots (`scripts/example-screenshots.sh`) and tests, then remove the Objective-C code it replaces.

## Fixing an API for Swift, in the core

When Swift code needs an Objective-C API, read its imported Swift name (Xcode: Generated Interface, or
`swift-ide-test -print-module`), then fix the header, not the call site:

| Problem in Swift | Fix in the Objective-C header |
| --- | --- |
| Unnatural method or type name | `NS_SWIFT_NAME(...)` on a new method (see cyl_ methods below); never rename an existing public API |
| Implicitly unwrapped `!` types | `NS_ASSUME_NONNULL_BEGIN/END` and `nullable` where nil is valid |
| `[Any]`, `[AnyHashable: Any]` | Lightweight generics (`NSArray<NSString *> *`) |
| String constants used as keys | `NS_TYPED_ENUM` / `NS_TYPED_EXTENSIBLE_ENUM` typedef (e.g. configuration keys) |
| Integer constants | `NS_ENUM` / `NS_OPTIONS` |
| A factory instead of an initializer | A designated or convenience `init…` (`NS_DESIGNATED_INITIALIZER`), or `NS_SWIFT_NAME(init(...))` |
| Global state as methods | `@property (class, …)` |
| Error out-parameter | `NSError **` as the last parameter, so Swift imports `throws` |
| An API Swift must not call | `NS_SWIFT_UNAVAILABLE("use …")` / `NS_REFINED_FOR_SWIFT` |

Verify with the Swift example and its tests (`scripts/unit-tests.sh swift`) and the library build
(`scripts/library-warnings.sh`: no warnings in the core).

## cyl_ methods

As CYLTabBarController does (its `AGENTS.md`, "Swift-friendly names for underscored protocol methods";
`docs/Swift-Guide.md`; its newest commit over every branch, see `cyl-dependency`):

1. Swift names have no underscore, but an existing public method keeps its imported name (`cyl_setWidth(_:)`):
   adding `NS_SWIFT_NAME` to it would change a released Swift API.
2. Add a new method with the same name minus the underscore, keeping the `cyl` prefix, and give only the new
   one its Swift name:

   ```objc
   - (void)cyl_setWidth:(CGFloat)width;                                   // unchanged
   - (void)cylSetWidth:(CGFloat)width NS_SWIFT_NAME(cylSetWidth(_:));    // new, same logic
   ```

3. Both spellings run the same code (one calls the other). For a protocol method, the library calls the new
   one when the class implements it, otherwise the old one; an old `@required` method becomes `@optional` so
   a class can implement only the new one.
4. Swift examples call the new spelling.

### Public cyl_ methods of the core still to adapt

| Header | Method |
| --- | --- |
| `ClassifyMenu/Other/Category/UIButton+CYLCollectionCellStyle.h` | `- (void)cyl_generalStyle;` |
| `ClassifyMenu/Other/Category/UIButton+CYLCollectionCellStyle.h` | `- (void)cyl_homeStyle;` |
| `ClassifyMenu/Other/Category/UIButton+CYLCollectionCellStyle.h` | `- (void)cyl_redStyle;` |
| `ClassifyMenu/Other/Category/UIButton+CYLCollectionCellStyle.h` | `- (void)cyl_chengNiStyle;` |
| `ClassifyMenu/View/CYLIndexPathButton.h` | `@property (nonatomic, assign) CGFloat cyl_imageTitleSpacing;` |
| `ClassifyMenu/View/CYLIndexPathButton.h` | `@property (nonatomic, assign) CGFloat cyl_titleLeadingInset;` |
| `MultipleFilter/Other/Category/UIImage+CYLBlur.h` | `- (UIImage *)cyl_blurredImageWithRadius:(CGFloat)radius` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (void)cyl_setWidth:(CGFloat)width;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (void)cyl_setHeight:(CGFloat)height;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (void)cyl_setX:(CGFloat)x;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (void)cyl_setY:(CGFloat)y;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (void)cyl_setSize:(CGSize)size;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (CGFloat)cyl_height;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (CGFloat)cyl_width;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (CGFloat)cyl_x;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (CGFloat)cyl_y;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (CGFloat)cyl_maxY;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (CGFloat)cyl_maxX;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (void)cyl_horizontalCenterWithWidth:(CGFloat)width;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (void)cyl_verticalCenterWithHeight:(CGFloat)height;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (void)cyl_verticalCenterInSuperView;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (void)cyl_horizontalCenterInSuperView;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (void)cyl_setBorderWidth:(CGFloat)width color:(CGColorRef)color;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (void)cyl_setCornerRadius:(CGFloat)radius;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (CALayer *)cyl_addSubLayerWithFrame:(CGRect)frame color:(CGColorRef)colorRef;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (void)cyl_setTarget:(id)target action:(SEL)action;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (UIImage *)cyl_capture;` |
| `MultipleFilter/Other/Category/UIView+CYLGeneral.h` | `- (UIImage *)cyl_captureWithWidth:(CGFloat)width;` |
| `Other/Category/NSArray+CYLLog.h` | `- (NSString *)cyl_descriptionWithLocale:(id)locale;` |
| `Other/Category/NSDictionary+CYLLog.h` | `- (NSString *)cyl_descriptionWithLocale:(id)locale;` |
