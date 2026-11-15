/**
 * iOS `NSArray+CYLLog.swift` and `NSDictionary+CYLLog.swift`, migrated from Android `CYLGeneralExtensions.kt`:
 * readable descriptions for logs with non-ASCII text (Chinese) as is. ArkTS strings are Unicode already, so there is
 * no `\u` escape to decode; the locale is ignored, as on iOS.
 */

/** `NSArray.cyl_description(withLocale:)`: the count, then one tab-indented element per line. */
export function cylArrayDescriptionWithLocale(array: Object[], locale?: Object): string {
  let description = `${array.length} (\n`;
  for (const element of array) {
    description += `\t${element},\n`;
  }
  return description + ')';
}

/** `NSDictionary.cyl_description(withLocale:)`: "{", one tab-indented "key = value;" per line, then "}". */
export function cylDictionaryDescriptionWithLocale(dictionary: Map<Object, Object>, locale?: Object): string {
  let description = '{\n';
  dictionary.forEach((value: Object, key: Object) => {
    description += `\t${key} = ${value};\n`;
  });
  return description + '}';
}
